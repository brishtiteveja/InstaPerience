import 'package:InstaPerience/main.dart';
import 'package:InstaPerience/models/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../image_post.dart';
import '../profile_page.dart';
import 'dart:math';


class ActionsToolbar extends StatefulWidget {
  final ImagePost content;
  final User user;
  final Function(bool, String) callback;
  ActionsToolbar({this.content, this.user, this.callback});

  @override
  State<StatefulWidget> createState() => _ActionsToolbar(
    content: this.content,
    user: this.user,
    callback: this.callback,
  );
}

class RotateTrans extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;
  RotateTrans(this.child, this.animation);
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        return Container(
          child: Transform.rotate(
            angle: animation.value,
            child: Container(
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class _ActionsToolbar extends State<ActionsToolbar> with AutomaticKeepAliveClientMixin<ActionsToolbar>, TickerProviderStateMixin {

  ImagePost content;
  User user;
  Function(bool, String) callback;

  _ActionsToolbar({this.content, this.user, this.callback});

  AnimationController animationController1;
  AnimationController animationController2;

  Animation<double> animation1;
  Animation<double> animation2;
  int rotateTime = 0;


// Full dimensions of an action
  static const double ActionWidgetSize = 60.0;

// The size of the icon showen for Social Actions
  static const double ActionIconSize = 35.0;

// The size of the share social icon
  static const double ShareActionIconSize = 25.0;

// The size of the profile image in the follow Action
  static const double ProfileImageSize = 50.0;

// The size of the plus icon under the profile image in follow action
  static const double PlusIconSize = 20.0;

  @override
  void initState() {
    animationController1 = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
    animationController2 = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));

    animation1 =
        Tween<double>(begin: 0, end: pi / 2).animate(animationController1);
    animation2 =
        Tween<double>(begin: pi / 2, end: 0).animate(animationController2);

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    animationController1.dispose();
    animationController2.dispose();
  }

  Widget _getSocialAction({
    String title, IconData icon}) {
    return Container(
        margin: EdgeInsets.only(top: 15.0),
        width: 60.0,
        height: 60.0,
        child: Column(
            children: [
              Icon(icon, size: 35.0, color: Colors.grey[300]),
              Padding(
                padding: EdgeInsets.only(top: 2.0),
                child: Text(title, style: TextStyle(fontSize: 12.0)),
              )
            ]
        )
    );
  }

  Widget _getPlusIcon() {
    return Positioned(
        bottom: 0,
        left: ((ActionWidgetSize / 2) - (PlusIconSize / 2)),
        child: Container(
          width: PlusIconSize,
          height: PlusIconSize,
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 255, 43, 84),
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Icon(Icons.add, color: Colors.white, size: 20.0),
        )
    );
  }

  Widget _getProfilePicture() {
    Positioned profileImgContainer = Positioned(
        left: (ActionWidgetSize / 2) - (ProfileImageSize / 2),
        child: Container(
            padding: EdgeInsets.all(1.0),
            height: ProfileImageSize,
            width: ProfileImageSize,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(ProfileImageSize * 0.05),
            ),
            child: CachedNetworkImage(
              imageUrl: user.photoUrl,
              //placeholder: (context, url) => new CircularProgressIndicator(),
              errorWidget: (context, url, error) => new Icon(Icons.error),
            )
        )
    );

    return profileImgContainer;
  }

  Widget _getFollowAction({
    String pictureUrl}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      width: 60.0,
      height: 60.0,
      child: GestureDetector(
        child: Stack(children: [
          _getProfilePicture(),
          _getPlusIcon()]),
        onTap: () {
          openProfile(context, content.ownerId);
        },
      ),
    );
  }

  LinearGradient get musicGradient =>
      LinearGradient(
          colors: [
            Colors.grey[800],
            Colors.grey[900],
            Colors.grey[900],
            Colors.grey[800]
          ],
          stops: [0.0, 0.4, 0.6, 1.0],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight
      );

  _rotateChildContinuously() {
    setState(() {
      rotateTime++;
      if (rotateTime == 1) {
        animationController1.forward(from: 0);
        this.callback(true, "autoSwipeButton");
      } else if (rotateTime == 2) {
        rotateTime = 0;
        animationController2.forward(from: pi / 2);
        this.callback(false, "autoSwipeButton");
      }
    });
    print(rotateTime);
  }

  Animation buildAnimation() {
    if (rotateTime == 1 ) {
      return animation1;
    } else if (rotateTime == 0) {
      return animation2;
    }
  }

  Widget _getMusicPlayerAction() {
    return Container(
        margin: EdgeInsets.only(top: 10.0),
        width: ActionWidgetSize,
        height: ActionWidgetSize,
        child: Column(children: [
          Container(
            padding: EdgeInsets.all(11.0),
            height: ProfileImageSize,
            width: ProfileImageSize,
            decoration: BoxDecoration(
                    gradient: musicGradient,
                    borderRadius: BorderRadius.circular(ProfileImageSize / 2)
            ),
            child: GestureDetector(
              child: RotateTrans(
                CachedNetworkImage(
                  imageUrl: "https://secure.gravatar.com/avatar/ef4a9338dca42372f15427cdb4595ef7",
                  //placeholder: (context, url) => new CircularProgressIndicator(),
                  errorWidget: (context, url, error) => new Icon(Icons.error),
                ),
                buildAnimation()
              ),
              onTap: _rotateChildContinuously,
            ),
          ),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // reloads state when opened again

    this.content = super.widget.content;
    this.user = super.widget.user;

    return Container(
      width: 100.0,
      padding: EdgeInsets.only(left: 20.0),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _getFollowAction(),
            _getSocialAction(icon: Icons.insert_comment, title: ""),
//            _getSocialAction(icon: Icons.mobile_screen_share, title: ""),
            _getMusicPlayerAction(),
          ]
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../image_post.dart';


class ActionsToolbar extends StatefulWidget {
  final ImagePost content;
  ActionsToolbar({this.content});

  @override
  State<StatefulWidget> createState() => _ActionsToolbar(
    content: this.content,
  );
}

class _ActionsToolbar extends State<ActionsToolbar> with AutomaticKeepAliveClientMixin<ActionsToolbar> {
  ImagePost content;
  _ActionsToolbar({this.content});

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
    return Positioned(
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
          imageUrl: content.mediaUrl,//"https://scontent-sjc3-1.cdninstagram.com/v/t51.2885-19/s320x320/40226446_316182435628302_1679274917872271360_n.jpg?_nc_ht=scontent-sjc3-1.cdninstagram.com&_nc_ohc=p9bNylfbuSoAX9FJ4Fa&oh=cd48a85fde4d5affeadc697f49337761&oe=5F944DD4",
          placeholder: (context, url) => new CircularProgressIndicator(),
          errorWidget: (context, url, error) => new Icon(Icons.error),
        )
      )
    );
  }

  Widget _getFollowAction({
    String pictureUrl}) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 10.0),
        width: 60.0,
        height: 60.0,
        child: Stack( children: [
          _getProfilePicture(),
          _getPlusIcon()])
    );
  }

  LinearGradient get musicGradient => LinearGradient(
      colors: [
        Colors.grey[800],
        Colors.grey[900],
        Colors.grey[900],
        Colors.grey[800]
      ],
      stops: [0.0,0.4, 0.6,1.0],
      begin: Alignment.bottomLeft,
      end: Alignment.topRight
  );


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
            child: CachedNetworkImage(
              imageUrl: "https://secure.gravatar.com/avatar/ef4a9338dca42372f15427cdb4595ef7",
              placeholder: (context, url) => new CircularProgressIndicator(),
              errorWidget: (context, url, error) => new Icon(Icons.error),
            ),
          ),

        ]));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // reloads state when opened again

    this.content = super.widget.content;

    return Container(
      width: 100.0,
      padding: EdgeInsets.only(left: 20.0),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _getFollowAction(),
            _getSocialAction(icon: Icons.insert_comment, title: ""),
            _getSocialAction(icon: Icons.mobile_screen_share, title: ""),
            _getMusicPlayerAction(),
          ]
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
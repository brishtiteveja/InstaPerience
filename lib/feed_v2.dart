import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'models/user.dart';
import 'widgets/content_description.dart';
import 'widgets/actions_toolbar.dart';
import 'widgets/bottom_toolbar.dart';
import 'image_post.dart';
import 'dart:async';
import 'main.dart';
import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Feed extends StatefulWidget {
  _Feed createState() => _Feed();
}

class _Feed extends State<Feed> with AutomaticKeepAliveClientMixin<Feed> {
  List<ImagePost> feedData;
  Map<String, User> users;
  Map<String, String> displayNameToUserName;
  Map<String, String> userNameToDisplayName;

  static int prevContentId = 0;
  static int curContentId = 0;
  static bool contentUpdated = false;
  static ImagePost content;
  ContentDescription contentDescription;

  static double screenWidth;
  static double screenHeight;
  static double screenHeight2;

  static double mainContentWidth = 350.0;
  static double mainContentHeight = 500.0;

  BuildContext context;

  @override
  void initState() {
    this._getUser();
    this._loadFeed();
    super.initState();
  }

  buildFeed() {
    if (feedData != null) {
      return ListView(
        children: feedData,
      );
    } else {
      return Container(
          alignment: FractionalOffset.center,
          child: CircularProgressIndicator());
    }
  }

  int getRandomInt(int min, int max) {
    Random rnd;
    rnd = new Random();
    int res = min + rnd.nextInt(max - min);

    return res;
  }
  void getPreviousContentBySwipe() {
    if (prevContentId == curContentId) {
      curContentId = curContentId - 1;
    }

    if (curContentId == feedData.length) {
      curContentId = 0;
    }else if (curContentId == -1) {
      curContentId = feedData.length - 1;
    } else {}

    if (contentUpdated == false && (curContentId == prevContentId - 1 || prevContentId == 0)) {
      content = feedData[curContentId];
      contentUpdated = true;
      setState(() {
      });
    }
  }

  void getNextContentBySwipe() {
    if (prevContentId == curContentId) {
      curContentId = curContentId + 1;
    }

    if (curContentId == feedData.length) {
      curContentId = 0;
    }else if (curContentId == -1) {
      curContentId = feedData.length - 1;
    } else {}

    if (contentUpdated == false && (curContentId == prevContentId + 1 || curContentId == 0)) {
      content = feedData[curContentId];
      contentUpdated = true;
      setState(() {
      });
    }
  }

  void getNextContentByTap() {
//    curContentId = getRandomInt(0, feedData.length);
    if (prevContentId == curContentId)
      curContentId = curContentId + 1;

    if (curContentId == feedData.length) {
      curContentId = 0;
    }else if (curContentId == -1) {
      curContentId = feedData.length - 1;
    } else {}

    if (contentUpdated == false && (curContentId == prevContentId + 1 || curContentId == 0)) {
      content = feedData[curContentId];
      setState(() {
      });
    }
  }

  Widget _mainContent() {
    content = feedData[curContentId];

    mainContentWidth = screenWidth * 0.8;
    mainContentHeight = screenHeight * 0.7;

    Container mainContainer = Container(
         padding: EdgeInsets.only(left:10.0, bottom: 10.0, right: 10.0, top:0.0),
//         decoration: BoxDecoration(
//           color: Color.alphaBlend(Colors.black26, Colors.blueGrey),
//           borderRadius: BorderRadius.circular(mainContentWidth * 0.05),
//        ),
        child: GestureDetector(
          onTap: getNextContentByTap,
          onPanUpdate: (details) {
            if (details.delta.dx > 0) {
              // swiping in right direction
              getPreviousContentBySwipe();
            } else {
              getNextContentBySwipe();
            }
          },
          child: CachedNetworkImage(
            width: mainContentWidth,
            height: mainContentHeight * 0.9,
            imageUrl: content.mediaUrl, //"https://scontent-ort2-2.cdninstagram.com/v/t51.2885-15/e35/119069697_185870479586445_7414306451367379982_n.jpg?_nc_ht=scontent-ort2-2.cdninstagram.com&_nc_cat=109&_nc_ohc=e5KswmGyJ4IAX-lImQ4&_nc_tp=18&oh=9e3352926043d756465f5c3bb87461c5&oe=5F968134",
            placeholder: (context, url) => new CircularProgressIndicator(),
            errorWidget: (context, url, error) => new Icon(Icons.error),
          ),
        ),

     );

    contentUpdated = false;
    prevContentId = curContentId;

    return mainContainer;
  }

  List<Widget> _getContent() {
    List<Widget> stackLayers = new List<Widget>();

    if (feedData != null && feedData.length != 0) {
      content = feedData[curContentId];

      stackLayers.add(_mainContent());

      stackLayers.add(
          Padding(
            padding: EdgeInsets.fromLTRB(0, mainContentHeight * 0.90, 0.0, 0.0),
            child: ContentDescription(content: content),
          )
      );
      stackLayers.add(
          Padding(
            padding: EdgeInsets.fromLTRB(mainContentWidth, mainContentHeight * 0.5, 0.0, 0.0),
            child: ActionsToolbar(content: content, user: users[userNameToDisplayName[content.username]]),
          )
      );
    }
    return stackLayers;
  }

  Widget get topSection => Container(
    height: 100.0,
    padding: EdgeInsets.only(bottom: 15.0),
    alignment: Alignment(0.0, 1.0),
    child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Following'),
          Container(
            width: 15.0,
          ),
          Text('For you',
              style: TextStyle(
                  fontSize: 17.0, fontWeight: FontWeight.bold))
        ]),
  );

  Widget get middleSection => Stack(
    children: _getContent()
  );

  @override
  Widget build(BuildContext context) {
    context = context;
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

//    EdgeInsets padding = MediaQuery.of(context).padding;
//    screenHeight2 = screenHeight2 - padding.top - padding.bottom;

    super.build(context); // reloads state when opened again
    // source code from https://medium.com/filledstacks/breaking-down-tiktoks-ui-using-flutter-8489fe4ad944
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget> [
          Container(
            child: topSection,
            padding: EdgeInsets.all(10),
          ),
          // Middle expanded
          Container(
            child: middleSection,
          ),
          //BottomToolbar(),
        ]
      )
    );
  }

  Future<Null> _refresh() async {
    await _getUser();
    await _getFeed();

    setState(() {});

    return;
  }

  _loadFeed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String json = prefs.getString("feed");

    if (json != null) {
      List<Map<String, dynamic>> data =
          jsonDecode(json).cast<Map<String, dynamic>>();
      List<ImagePost> listOfPosts = _generateFeed(data);
      setState(() {
        feedData = listOfPosts;
      });
    } else {
      _getFeed();
    }
  }

  _getUser() async {
    var snap = await Firestore.instance.collection("insta_users").getDocuments();

    users = new Map<String, User>();
    displayNameToUserName = new Map<String, String>();
    userNameToDisplayName = new Map<String, String>();
    for (var doc in snap.documents) {
      User user = User.fromDocument(doc);
      users[user.displayName] = user;
      displayNameToUserName[user.displayName] = user.username;
      userNameToDisplayName[user.username] = user.displayName;
    }
    return null;
  }

  _getFeed() async {
    print("Starting getFeed");

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String userId = googleSignIn.currentUser.id.toString();
    var url =
		'https://us-central1-fluttergram-firebase-functions.cloudfunctions.net/getFeed?uid=' + userId;
    var httpClient = HttpClient();

    List<ImagePost> listOfPosts;
    String result;
    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        String json = await response.transform(utf8.decoder).join();
        prefs.setString("feed", json);
        List<Map<String, dynamic>> data =
            jsonDecode(json).cast<Map<String, dynamic>>();
        listOfPosts = _generateFeed(data);
        result = "Success in http request for feed";
      } else {
        result =
            'Error getting a feed: Http status ${response.statusCode} | userId $userId';
      }
    } catch (exception) {
      result = 'Failed invoking the getFeed function. Exception: $exception';
    }
    print(result);

    setState(() {
      feedData = listOfPosts;
    });
  }

  List<ImagePost> _generateFeed(List<Map<String, dynamic>> feedData) {
    List<ImagePost> listOfPosts = [];

    for (var postData in feedData) {
      listOfPosts.add(ImagePost.fromJSON(postData));
    }

    return listOfPosts;
  }

  // ensures state is kept when switching pages
  @override
  bool get wantKeepAlive => true;
}

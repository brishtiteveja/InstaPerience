import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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
  static int curContentId = 0;
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
  int getPreviousContent() {
//    curContentId = getRandomInt(0, feedData.length);
    curContentId = curContentId <= 0 ? feedData.length - 1 : curContentId - 1;
    content = feedData.getRange(curContentId, feedData.length-1).first;

    setState(() {
    });

    return curContentId;
  }

  int getNextContent() {
//    curContentId = getRandomInt(0, feedData.length);
    curContentId = curContentId >= feedData.length ? 0 : curContentId + 1;
    content = feedData.getRange(curContentId, feedData.length-1).first;

    setState(() {
    });

    return curContentId;
  }

  Widget _mainContent() {
    content = feedData.getRange(curContentId, feedData.length-1).first;

    mainContentWidth = screenWidth * 0.8;
    mainContentHeight = screenHeight * 0.7;

    return Container(
         padding: EdgeInsets.only(left:10.0, bottom: 30.0, right: 10.0, top:0.0),
//         decoration: BoxDecoration(
//           color: Color.alphaBlend(Colors.black26, Colors.blueGrey),
//           borderRadius: BorderRadius.circular(mainContentWidth * 0.05),
//        ),
        child: GestureDetector(
          onTap: getNextContent,
          onPanUpdate: (details) {
            if (details.delta.dx > 0) {
              // swiping in right direction
              getNextContent();
            } else {
              getPreviousContent();
            }
          },
          child: CachedNetworkImage(
            width: mainContentWidth,
            height: mainContentHeight,
            imageUrl: content.mediaUrl, //"https://scontent-ort2-2.cdninstagram.com/v/t51.2885-15/e35/119069697_185870479586445_7414306451367379982_n.jpg?_nc_ht=scontent-ort2-2.cdninstagram.com&_nc_cat=109&_nc_ohc=e5KswmGyJ4IAX-lImQ4&_nc_tp=18&oh=9e3352926043d756465f5c3bb87461c5&oe=5F968134",
            placeholder: (context, url) => new CircularProgressIndicator(),
            errorWidget: (context, url, error) => new Icon(Icons.error),
          ),
        ),

     );
  }

  List<Widget> _getContent() {
    List<Widget> stackLayers = new List<Widget>();

    if (feedData != null && feedData.length != 0) {
      content = feedData.getRange(curContentId, curContentId+1).first;

      stackLayers.add(_mainContent());

      stackLayers.add(
          Padding(
            padding: EdgeInsets.fromLTRB(0, mainContentHeight * 0.98, 0.0, 0.0),
            child: ContentDescription(content: content),
          )
      );
      stackLayers.add(
          Padding(
            padding: EdgeInsets.fromLTRB(mainContentWidth, mainContentHeight * 0.5, 0.0, 0.0),
            child: ActionsToolbar(content: content),
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
          topSection,
          // Middle expanded
          middleSection,

          //BottomToolbar(),
        ]
      )
    );
  }

  Future<Null> _refresh() async {
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

  _getFeed() async {
    print("Staring getFeed");

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

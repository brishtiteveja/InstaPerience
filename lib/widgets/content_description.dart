import 'package:InstaPerience/profile_page.dart';
import 'package:flutter/material.dart';
import '../image_post.dart';

class ContentDescription extends StatefulWidget {
  final ImagePost content;
  final Function(bool, String) callback;
  ContentDescription({this.content, this.callback});

  @override
  State<StatefulWidget> createState() => _ContentDescription(
    content: this.content,
    callback: this.callback
  );
}

class _ContentDescription extends State<ContentDescription> with AutomaticKeepAliveClientMixin<ContentDescription> {
  ImagePost content;
  Function(bool, String) callback;

  _ContentDescription({this.content, this.callback});

  @override
  Widget build(BuildContext context) {
    super.build(context);

    this.content = super.widget.content;

    return Container(
      height: 70.0,
      padding: EdgeInsets.only(left: 20.0, top: 5.0),
      child:
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              child: Padding(
                padding: EdgeInsets.only(bottom: 5.0),
                child: Text("@" + content.username, style: TextStyle(fontWeight: FontWeight.bold),),
              ),
              onTap: () {
                openProfile(context, content.ownerId);
              },
            ),
            GestureDetector(
              child: Padding (
                padding: EdgeInsets.all(0.0),
                child: Text(" " + content.location),
              ),
              onTap: () {
              },
            ),
            GestureDetector(
              child: Padding (
                padding: EdgeInsets.all(1.0),
                child: Text(" -- " + content.description),
              ),
              onTap: () {
              },
            ),
//            Row(children: [
//              Icon(Icons.music_note,  size: 15.0),
//              Text('Artist name - Album name - song', style: TextStyle(fontSize: 12.0))]
//            ),
          ]),
      );
  }

  @override
  bool get wantKeepAlive => false;

}
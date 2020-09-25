import 'package:flutter/material.dart';
import '../image_post.dart';

class ContentDescription extends StatefulWidget {
  final ImagePost content;
  ContentDescription({this.content});

  @override
  State<StatefulWidget> createState() => _ContentDescription(
    content: this.content
  );
}

class _ContentDescription extends State<ContentDescription> with AutomaticKeepAliveClientMixin<ContentDescription> {
  ImagePost content;

  _ContentDescription({this.content});

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
            Text("@" + content.username, style: TextStyle(fontWeight: FontWeight.bold),),
            Text(" " + content.location),
            Text(" -- " + content.description),
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
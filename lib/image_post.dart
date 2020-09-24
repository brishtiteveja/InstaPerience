import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'main.dart';
import 'dart:async';
import 'profile_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'comment_screen.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:secp256k1/secp256k1.dart';
import 'package:pascaldart/pascaldart.dart';

class ImagePost extends StatefulWidget {
  const ImagePost(
      {this.mediaUrl,
      this.username,
      this.location,
      this.description,
      this.likes,
      this.postId,
      this.ownerId});

  factory ImagePost.fromDocument(DocumentSnapshot document) {
    return ImagePost(
      username: document['username'],
      location: document['location'],
      mediaUrl: document['mediaUrl'],
      likes: document['likes'],
      description: document['description'],
      postId: document.documentID,
      ownerId: document['ownerId'],
    );
  }

  factory ImagePost.fromJSON(Map data) {
    return ImagePost(
      username: data['username'],
      location: data['location'],
      mediaUrl: data['mediaUrl'],
      likes: data['likes'],
      description: data['description'],
      ownerId: data['ownerId'],
      postId: data['postId'],
    );
  }

  int getLikeCount(var likes) {
    if (likes == null) {
      return 0;
    }
// issue is below
    var vals = likes.values;
    int count = 0;
    for (var val in vals) {
      if (val == true) {
        count = count + 1;
      }
    }

    return count;
  }

  final String mediaUrl;
  final String username;
  final String location;
  final String description;
  final likes;
  final String postId;
  final String ownerId;

  _ImagePost createState() => _ImagePost(
        mediaUrl: this.mediaUrl,
        username: this.username,
        location: this.location,
        description: this.description,
        likes: this.likes,
        likeCount: getLikeCount(this.likes),
        ownerId: this.ownerId,
        postId: this.postId,
      );
}

class _ImagePost extends State<ImagePost> {
  final String mediaUrl;
  final String username;
  final String location;
  final String description;
  Map likes;
  int likeCount;
  final String postId;
  bool liked;
  final String ownerId;

  bool showHeart = false;

  TextStyle boldStyle = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
  );

  var reference = Firestore.instance.collection('insta_posts');

  _ImagePost(
      {this.mediaUrl,
      this.username,
      this.location,
      this.description,
      this.likes,
      this.postId,
      this.likeCount,
      this.ownerId});

  GestureDetector buildLikeIcon() {
    Color color;
    IconData icon;

    if (liked) {
      color = Colors.pink;
      icon = FontAwesomeIcons.solidHeart;
    } else {
      icon = FontAwesomeIcons.heart;
    }

    return GestureDetector(
        child: Icon(
          icon,
          size: 25.0,
          color: color,
        ),
        onTap: () {
          _likePost(postId);
        });
  }

  GestureDetector buildLikeableImage() {
    return GestureDetector(
      onDoubleTap: () => _likePost(postId),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          CachedNetworkImage(
            imageUrl: mediaUrl,
            fit: BoxFit.fitWidth,
            placeholder: (context, url) => loadingPlaceHolder,
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
          showHeart
              ? Positioned(
                  child: Container(
                    width: 100,
                    height: 100,
                    child:  Opacity(
                        opacity: 0.85,
                        child: FlareActor("assets/flare/Like.flr",
                          animation: "Like",
                        )),
                  ),
                )
              : Container()
        ],
      ),
    );
  }

  buildPostHeader({String ownerId}) {
    if (ownerId == null) {
      return Text("owner error");
    }

    return FutureBuilder(
        future: Firestore.instance
            .collection('insta_users')
            .document(ownerId)
            .get(),
        builder: (context, snapshot) {

          if (snapshot.data != null) {
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(snapshot.data.data['photoUrl']),
                backgroundColor: Colors.grey,
              ),
              title: GestureDetector(
                child: Text(snapshot.data.data['username'], style: boldStyle),

              ),
              subtitle: Text(this.location),
              trailing: const Icon(Icons.more_vert),
              onTap: () {
                openProfile(context, ownerId);
              },
            );
          }

          // snapshot data is null here
          return Container();
        });
  }

  Container loadingPlaceHolder = Container(
    height: 400.0,
    child: Center(child: CircularProgressIndicator()),
  );

  @override
  Widget build(BuildContext context) {
    liked = (likes[googleSignIn.currentUser.id.toString()] == true);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Ink (
          color: Colors.amberAccent.withOpacity(0.65),
          child: buildPostHeader(ownerId: ownerId)
        ),
        Ink(
          color: Colors.amberAccent.withOpacity(0.5),
          child: buildLikeableImage(),
        ),
        Ink(
          color: Colors.amberAccent.withOpacity(0.65),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(padding: const EdgeInsets.only(left: 20.0, top: 40.0)),
              buildLikeIcon(),
              Padding(padding: const EdgeInsets.only(right: 20.0)),
              GestureDetector(
                  child: const Icon(
                    FontAwesomeIcons.comment,
                    size: 25.0,
                  ),
                  onTap: () {
                    goToComments(
                        context: context,
                        postId: postId,
                        ownerId: ownerId,
                        mediaUrl: mediaUrl);
                  }),
            ],
          ),
        ),
        Ink(
          color: Colors.amberAccent.withOpacity(0.5),
          child: Row(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(left: 20.0),
                child: Text(
                  "$likeCount likes",
                  style: boldStyle,
                ),
              )
            ],
          ),
        ),
        Ink(
          color: Colors.amberAccent.withOpacity(0.5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                  margin: const EdgeInsets.only(left: 20.0),
                  child: Text(
                    "$username ",
                    style: boldStyle,
                  )),
              Expanded(child: Text(description)),
            ],
          )
        ),
      ],
    );
  }

  /*
  String sign2(String privKey, String sender, String tx) {
    tx.sender = sender;
    tx.ts = ;
    tx.hash = ;
    var msg = tx.hash;
    var pk = hexToPrivateKey(privKey);
    var signature = Base58.encode(pk);

    var signature = sign(pk, msg);
    tx.signature = ;



    return tx;
  }

  void sendTransaction() {

  }


   */

  void _likePost(String postId2) {
    var userId = googleSignIn.currentUser.id;
    bool _liked = likes[userId] == true;

    if (_liked) {
      print('removing like');
      reference.document(postId).updateData({
        'likes.$userId': false
        //firestore plugin doesnt support deleting, so it must be nulled / falsed
      });

      setState(() {
        likeCount = likeCount - 1;
        liked = false;
        likes[userId] = false;
      });

      removeActivityFeedItem();
    }

    if (!_liked) {
      reference.document(postId).updateData({'likes.$userId': true});

      // send vote to instalon blockchain
      var voter = "instacoin"; //username;
      var wif = "21jo2MF2LfZPJGg2ahkLXYPiSfWeuqJPxiM2xzzvZAPU"; // private key
      var weight = 1;
      var tag = "entertainment";
      var vt = 5;
      var tx = {
        "type" : 5,
        "data" : {
          "author" : ownerId,
          "link" : mediaUrl,
          "vt" : vt,
          "tag" : tag,

        }
      };


      addActivityFeedItem();

      setState(() {
        likeCount = likeCount + 1;
        liked = true;
        likes[userId] = true;
        showHeart = true;
      });
      Timer(const Duration(milliseconds: 2000), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  void addActivityFeedItem() {
    Firestore.instance
        .collection("insta_a_feed")
        .document(ownerId)
        .collection("items")
        .document(postId)
        .setData({
          "username": currentUserModel.username,
          "userId": currentUserModel.id,
          "type": "like",
          "userProfileImg": currentUserModel.photoUrl,
          "mediaUrl": mediaUrl,
          "timestamp": DateTime.now(),
          "postId": postId,
        });
  }

  void removeActivityFeedItem() {
    Firestore.instance
        .collection("insta_a_feed")
        .document(ownerId)
        .collection("items")
        .document(postId)
        .delete();
  }
}

class ImagePostFromId extends StatelessWidget {
  final String id;

  const ImagePostFromId({this.id});

  getImagePost() async {
    var document =
        await Firestore.instance.collection('insta_posts').document(id).get();
    return ImagePost.fromDocument(document);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getImagePost(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Container(
                alignment: FractionalOffset.center,
                padding: const EdgeInsets.only(top: 10.0),
                child: CircularProgressIndicator());
          return snapshot.data;
        });
  }
}

void goToComments(
    {BuildContext context, String postId, String ownerId, String mediaUrl}) {
  Navigator.of(context)
      .push(MaterialPageRoute<bool>(builder: (BuildContext context) {
    return CommentScreen(
      postId: postId,
      postOwner: ownerId,
      postMediaUrl: mediaUrl,
    );
  }));
}

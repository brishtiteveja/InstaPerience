import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:fast_base58/fast_base58.dart';
import 'package:flutter/cupertino.dart';
import 'package:secp256k1/secp256k1.dart';
//import 'package:flutter_test/flutter_test.dart';
import 'package:convert/convert.dart';
import 'package:http/http.dart' as http;

enum TransactionType {
  NEW_ACCOUNT,
  APPROVE_NODE_OWNER,
  DISAPPROVE_NODE_OWNER,
  TRANSFER,
  COMMENT,
  VOTE,
  USER_JSON,
  FOLLOW,
  UNFOLLOW,
  // RESHARE
  NEW_KEY,
  REMOVE_KEY,
  CHANGE_PASSWORD,
  PROMOTED_COMMENT,
  TRANSFER_VT,
  TRANSFER_BW
}

class ECKey {
  String _privKey;
  String _pubKey;

  String get privKey {
    return _privKey;
  }

  void set privKey(String privKey) {
    _privKey = privKey;
  }

  String get pubKey {
    return _pubKey;
  }

  void set pubKey(String pubKey) {
    _pubKey = pubKey;
  }

  ECKey(String privKey, String pubKey) {
   this.privKey = privKey;
   this.pubKey = pubKey;
  }
}

class Avalon {
  final config = {};

  Avalon() {
    config["api"] = ["http://18.218.250.68:3002", "http://18.218.250.68:3003", "http://18.218.250.68:3004"];
    return;
  }

  void getAccount(String name) {
    return;
  }

  void getAccountHistory(String name, String lastBlock) {

  }

  void getVotesByAccount(String name, double lastTs) {
    return;
  }

  void getAccounts(List<String> names) {
    return;
  }

  void getContent(String name, String link) {

  }

  void getFollowing(String name) {

  }

  void getFollowers(String name) {

  }

  void generateCommentTree(String root, String author, String link) {

  }

  void getDiscussionByAuthor(String username, String author, String link) {

  }

  void getNewDiscussions(String author, String link) {

  }

  void getHotDiscussions(String author, String link) {

  }

  void getTrendingDiscussions(String author, String link) {

  }

  void getFeedDiscussions(String username, String author, String link) {

  }

  void getNotifications(String username) {

  }

  void getSchedule() {

  }

  void getLeaders() {

  }

  void getRewardPool() {

  }

  void getRewards() {

  }

  ByteData bigIntToByteData(BigInt bigInt) {
    final data = ByteData((bigInt.bitLength / 8).ceil());
    var _bigInt = bigInt;

    for (var i = 1; i <= data.lengthInBytes; i++) {
      data.setUint8(data.lengthInBytes - i, _bigInt.toUnsigned(8).toInt());
      _bigInt = _bigInt >> 8;
    }

    return data;
  }

  Uint8List bigIntToUint8List(BigInt bigInt) {
    return bigIntToByteData(bigInt).buffer.asUint8List();
  }

  String getPrivteKeyByRand(BigInt n, int bitSize) {
    var nHex = n.toRadixString(16);
    var privteKeyList = <String>[];
    var isZero = true;
    var random = Random.secure();

    for (var i = 0; i < nHex.length; i++) {
      var rand16Num =
      BigInt.from(random.nextInt(100) / 100 * int.parse(nHex[i], radix: 16));
      int l = (bitSize/(64*4)).ceil();
      privteKeyList.add(rand16Num.toRadixString(16).padLeft(64, '0').substring(64-l,64));
      if (rand16Num > BigInt.zero) {
        isZero = false;
      }
    }

    if (isZero) {
      return getPrivteKeyByRand(n, bitSize);
    }
    var privKeyHex = privteKeyList.join('');
    return privKeyHex;
  }

  String generatePrivateKeyWithBitSize(int bitSize) {
    const secp256k1Params = {
      'n': 'fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141',
    };
    BigInt n = BigInt.parse(secp256k1Params['n'], radix: 16);
    var privKey = getPrivteKeyByRand(n, bitSize);
    return privKey;
  }

  String randomNode() {
    int numAPI = config["api"].length;
    final _random = new Random();
    int apiID = 0;//_random.nextInt(numAPI);

    String api = config["api"][apiID];

    return api;
  }

  ECKey keypair() {
    var bitSize = 256;
    var privKeyHex =  generatePrivateKeyWithBitSize(bitSize);
    var privKeyBytes = hex.decode(privKeyHex);
    var privKey = Base58Encode(privKeyBytes);

    var privKeyB = BigInt.parse(privKeyHex, radix: 16);
    var pubKeyB = getPublic(privKeyB);
    var pubHexCompressed = publicKeyToCompressHex(pubKeyB);
    var pubHexDecoded = hex.decode(pubHexCompressed);
    var pubKey = Base58Encode(pubHexDecoded);

    ECKey keypair = new ECKey(privKey, pubKey);

    return keypair;
  }

  String privToPub(String privKey) {
    var privKeyDecoded = Base58Decode(privKey);
    var privKeyHexList = byteArrayToHexList(privKeyDecoded);
    var privKeyHex = hexListToHexString(privKeyHexList);
    var privKeyB = BigInt.parse(privKeyHex, radix: 16);

    var pubKeyBList = getPublic(privKeyB);
    var pubKeyHexCompressed = publicKeyToCompressHex(pubKeyBList);
    var pubKeyHex = hex.decode(pubKeyHexCompressed);
    var pubKey = Base58Encode(pubKeyHex);

    return pubKey;
  }

  String createSignature(String privKey, String txHexHash) {
    // Decode private key
    var privKeyDecoded = Base58Decode(privKey);
    var privKeyHexString = byteArrayToHexList(privKeyDecoded);
    var hexPrivKeyString = hexListToHexString(privKeyHexString);
    // Convert into big int for signing
    var privKeyBigInt = BigInt.parse(hexPrivKeyString, radix: 16);

    // Sign tx hash string with priv key
    var R_S = sign(privKeyBigInt, txHexHash);
    // Get the R and S of the signature
    var R=R_S[0].toRadixString(16);
    var S=R_S[1].toRadixString(16);
    // Concatenate R and S of the signature
    var RS = R+S;
    // Convert into byte array
    var RSByteArray = hex.decode(RS);
    // Encode signature byte array into signature hex string
    var signature = Base58Encode(RSByteArray);

    print("verify signature");
    var pub = getPublic(privKeyBigInt);
    print(pub);
    print(privToPub(privKey));
    print(txHexHash);
    var isVerified = verify(pub, R_S, txHexHash);
    print(isVerified);

    return signature;
  }

  String signTx(String privKey, String sender, String tx) {
    // decode the tx string to add sender and time stamp
    var txJson = jsonDecode(tx);
    txJson["sender"] = sender;
    txJson["ts"] = DateTime.now().millisecondsSinceEpoch; //test ts..1602967752296

    // Convert into string again
    var txString = json.encode(txJson).toString();
    // UTF-8 encoding of the tx string in case non utf8 character is present in the string
    var txEncodedBytes = utf8.encode(txString);
    // Hash with Sha-256 func
    var txHashInSha = sha256.convert(txEncodedBytes);
    var txHashBytes = txHashInSha.bytes;
    // Convert tx hash byte array into list
    var txHashHexList = byteArrayToHexList(txHashBytes);
    var txHexHash = hexListToHexString(txHashHexList);
    // Create signature
    var signature = createSignature(privKey, txHexHash);

    // Add tx hex hash to tx Json
    txJson["hash"] = txHexHash;
    // add signature to tx Json
    txJson["signature"] = signature;

    // convert tx Json to txString
    txString = json.encode(txJson).toString();
    return txString;
  }

  void sendTransaction(String tx) {

  }

  void sendRawTransaction(String tx) {

  }

  void sendTransactionDeprecated(String tx) {

  }

  void verifyTransaction(String tx, String headBlock, int retries) {

  }

  void encrypt(String pub, String message, String ephemPriv) {

  }

  void decrypt(String priv, String encrypted) {

  }

  void votingPower(String account) {

  }

  void bandwidth(String account) {

  }

  void signTransaction() {

  }

  void signAndSendTransaction() {
    signTransaction();

    String tx;
    sendTransaction(tx);
  }

}

List<String> byteArrayToHexList(List<int> list) {
  var hList = new List<String>();
  for (int i=0; i<list.length; i++) {
    var h = list[i].toRadixString(16);
    if (h.length == 1) {
      h = "0" + h[0];
    }
    hList.add(h);
  }

  return hList;
}

String hexListToHexString(List<String> hList) {
  var hexString = "";
  for (int i=0; i<hList.length; i++) {
    hexString += hList[i];
  }

  return hexString;
}

List<String> hexStringToHexList(String hex) {
  var hexString = new List<String>();
  for (int i=0; i<hex.length-1; i+=2) {
    var h = hex.substring(i, i+2);
    hexString.add(h);
  }

  return hexString;
}

List<int> hexStringToByteArray(String hexString) {
  return hex.decode(hexString);
}

String createExampleTx() {
  var tx =  {};
  tx["type"] = 4;
  tx["data"] = {};

  //var voter = "instacoin";
  var voter = "miner1";
  var ownerId = "instacoin";
  //var link = "QmNbY2qmU8cAkjJrxz22XZAmza687w692nXnsnvh5heSiN";
  var link = "QmNbY2qmU8cAkjJrxz22XZAmza687w692nXnsnvh5heSiN";
  var weight = 1;
  var vt = 18;
  var tag = "";

  tx["type"] = 5;  // upvote:5, post/comment: 4
  tx["data"] = {};
  tx["data"]["link"] = link;
  tx["data"]["vt"] = vt;
  tx["data"]["tag"] = tag;

  // for upvote
  if (tx["type"] == 5) {
    tx["data"]["author"] = ownerId;
    tx['sender'] = voter;
    tx["ts"] = 1602967752396;
  }

  // for post/comment
  if (tx["type"] == 4) {
    tx["data"]["json"] = {};
    tx["data"]["json"]["title"] = "d";
    tx["data"]["json"]["description"] = "hi how are you";
    tx["data"]["json"]["quality"] = 2;
  }

  return json.encode(tx).toString();
}

Future<void> main() async {
  //var privKey = "21jo2MF2LfZPJGg2ahkLXYPiSfWeuqJPxiM2xzzvZAPU";//"H1RQWnctx6SyEbz2a6MWAAXEVbaCCSoS848z2vvtLFym";
  //var sender = "instacoin";
  var privKey = "6WTT3RWvWbPeQT1kafjBEkchdxYHwvJxtys42HrhNxKB";
  var sender = "miner1";

  var avalon = new Avalon();
  print(avalon.randomNode());


  var tx = createExampleTx();

  var txSigned = avalon.signTx(privKey, sender, tx);
  print(txSigned);

  //avalon.sendTransaction(tx);

  var _httpClient = http.Client();

  var uri = avalon.randomNode();
  uri = uri + '/transactWaitConfirm';
  var response = _httpClient.post(uri,
                                  headers : {
                                          'Accept': 'application/json, text/plain, */*',
                                          'Content-Type': 'application/json'},
                                  body: txSigned);

  var value = await response;
  var res = utf8.decode(value.bodyBytes);
  print(res);








//  var pkRaw = Base58Decode(privKey);
//  var pkRawString = Base58Encode(pkRaw);
//
//  var pkRawHex = byteArrayToHexList(pkRaw);
//
//  // <Buffer a7 03 35 3d 2f 8f 3d 89 b6 80 3f 6a c6 f7 41 44 2a 06 c5 4e 30 f2 25 84 e5 df 4d c9 98 67 e4 7f>
//  var hashHex = byteArrayToHexList(hashB);
//  var hexHash = hexListToHexString(hashHex);
//
//  var hexPrivKeyString = hexListToHexString(pkRawHex);
//
//  var privKeyB = BigInt.parse(hexPrivKeyString, radix: 16);//hexToPrivateKey(hexPrivKeyString);
//  var R_S = sign(privKeyB, hexHash);
//  var R=R_S[0].toRadixString(16); // r
//  var S=R_S[1].toRadixString(16); // s
//  var RS = R+S;
//
//  var RSByteArray = hex.decode(RS);
//  var signature = Base58Encode(RSByteArray);
//
//  print("verify signature");
//  var pub = getPublic(privKeyB);
//  var isVerified = verify(pub, R_S, hexHash);
//
//  var a = T.privToPub(privKey);
//  print(a);
//
//  ECKey newKey = T.keypair();
//  print("\nNew key");
//  print(newKey.privKey);
//  print(newKey.pubKey);
//  print("");
//
//  var pk = T.privToPub(newKey.privKey);
//  print(pk);
//  if (pk == newKey.pubKey) {
//    print("correct key");
//  }


}

import 'dart:async';
import 'dart:io';
import 'package:BKZalo/config/url.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:BKZalo/widget/messtitle.dart';
import 'package:BKZalo/model/user.dart';
import 'package:BKZalo/model/message.dart';
import 'package:BKZalo/model/chat.dart';
import 'package:BKZalo/view/callscreen.dart';
import 'package:firebase_core/firebase_core.dart' as f_core;
import 'package:firebase_storage/firebase_storage.dart' as f_storage;
import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

class Chat extends StatelessWidget {
  final User friend;
  final ChatModel model;
  final String myid;
  Chat(this.friend, this.model, this.myid);
  @override
  Widget build(BuildContext context) {
    return ScopedModel(
        model: model,
        child: Scaffold(
          appBar: AppBar(
            elevation: 3.0,
            title: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(friend.linkAvatar),
                ),
                SizedBox(
                  width: 20.0,
                ),
                Text(
                  friend.name,
                  style: TextStyle(fontSize: 18.0),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.info),
                onPressed: () {},
                color: Theme.of(context).primaryColor,
              ),
              IconButton(
                  icon: Icon(Icons.video_call_rounded),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          print("Tag CALL" + myid);
                          return CallScreen(
                            ip: Url.url,
                            id: friend.chatID,
                            myId: myid,
                          );
                        },
                      ),
                    );
                  },
                  color: Theme.of(context).primaryColor)
            ],
          ),
          body: ChatScreen(
            friend: friend,
            model: model,
          ),
        ));
  }
}

class ChatScreen extends StatefulWidget {
  final User friend;
  final ChatModel model;
  ChatScreen({Key key, @required this.friend, @required this.model})
      : super(key: key);
  @override
  State createState() => ChatScreenState(friend: friend, model: model);
}

class ChatScreenState extends State<ChatScreen> {
  ChatModel model;
  User friend;
  ChatScreenState({Key key, @required this.friend, @required this.model});

  String fileType = '';
  File file;
  String fileName = '';
  String operationText = '';
  bool isUploaded = true;
  String result = '';

  String id;
  int _limit = 20;
  final int _limitIncrement = 20;
  String groupChatId;

  bool isLoading;
  bool isShowSticker;
  String imageUrl;

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  final snackBar = SnackBar(content: Text('Uploading....'));
  _scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      print("reach the bottom");
      setState(() {
        print("reach the bottom");
        _limit += _limitIncrement;
      });
    }
    if (listScrollController.offset <=
            listScrollController.position.minScrollExtent &&
        !listScrollController.position.outOfRange) {
      print("reach the top");
      setState(() {
        print("reach the top");
      });
    }
  }

  @override
  void initState() {
    super.initState();
    f_core.Firebase.initializeApp();
    focusNode.addListener(onFocusChange);
    listScrollController.addListener(_scrollListener);

    isLoading = false;
    isShowSticker = false;
    imageUrl = '';
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      setState(() {
        isShowSticker = false;
      });
    }
  }

  void getSticker() {
    focusNode.unfocus();
    setState(() {
      isShowSticker = !isShowSticker;
    });
  }

  void pickImage() {
    this.setState(() {
      fileType = 'image';
    });
    filePicker(context);
  }

  void pickAttach() {
    this.setState(() {
      fileType = 'others';
    });
    filePicker(context);
  }

  void pickVideo() {
    this.setState(() {
      fileType = 'video';
    });
    filePicker(context);
  }

  void onSendMessage(String content, int type) {
    // type: 0 = text, 1 = image, 2 = sticker
    if (type == 0) {
      if (content.trim() != '') {
        widget.model.sendMessage(type, content, widget.friend.chatID);
        textEditingController.text = '';
        listScrollController.animateTo(0.0,
            duration: Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    } else {
      widget.model.sendMessage(type, content, widget.friend.chatID);
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  Future<void> _uploadFile(File file, String filename) async {
    Scaffold.of(context).showSnackBar(snackBar);
    f_storage.Reference storageReference;
    if (fileType == 'image') {
      storageReference =
          f_storage.FirebaseStorage.instance.ref().child("images/$filename");
     
      final f_storage.UploadTask uploadTask = storageReference.putFile(file);
      imageUrl = await (await uploadTask).ref.getDownloadURL();
      String url = imageUrl.toString();
      print("URL is $url");
      onSendMessage(url, 1);
    }

    if (fileType == 'video') {
      storageReference =
          f_storage.FirebaseStorage.instance.ref().child("videos/$filename");
      
      final f_storage.UploadTask uploadTask = storageReference.putFile(file);
      imageUrl = await (await uploadTask).ref.getDownloadURL();
      String url = imageUrl.toString();
      print("URL is $url");
      onSendMessage(url, 2);
    }

    if (fileType == 'others') {
      storageReference =
          f_storage.FirebaseStorage.instance.ref().child("others/$filename");
     
      final f_storage.UploadTask uploadTask = storageReference.putFile(file);
      imageUrl = await (await uploadTask).ref.getDownloadURL();
      String url = imageUrl.toString();
      print("URL is $url");
      onSendMessage(url, 3);
    }
  }

  Future filePicker(BuildContext context) async {
    try {
      if (fileType == 'image') {
        file = await FilePicker.getFile(type: FileType.IMAGE);
        setState(() {
          fileName = p.basename(file.path);
        });
        print(fileName);
        _uploadFile(file, fileName);
      }

      if (fileType == 'video') {
        file = await FilePicker.getFile(type: FileType.VIDEO);
        fileName = p.basename(file.path);
        setState(() {
          fileName = p.basename(file.path);
        });
        print(fileName);
        _uploadFile(file, fileName);
      }

      if (fileType == 'others') {
        file = await FilePicker.getFile(type: FileType.ANY);
        fileName = p.basename(file.path);
        setState(() {
          fileName = p.basename(file.path);
        });
        print(fileName);
        _uploadFile(file, fileName);
      }
    } on PlatformException catch (e) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Sorry...'),
              content: Text('Unsupported exception: $e'),
              actions: <Widget>[
                FlatButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    }
  }

  Future<bool> onBackPress() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      Navigator.pop(context);
    }
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<ChatModel>(builder: (context, child, model) {
      return WillPopScope(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                // List of messages
                buildListMessage(model),
                // Sticker
                buildInput(model),
                (isShowSticker ? buildSticker(model) : Container()),
                // Input content
              ],
            ),
          ],
        ),
        onWillPop: onBackPress,
      );
    });
  }

  Matrix4 matrix = Matrix4.identity();
  List<Widget> buildImageWidget(lengthList) {
    final generator = (int index) {
      final name = "asset/sticker/sticker${index + 1}.gif";
      return GestureDetector(
          onTap: () {
            onSendMessage('${index + 1}', 4);
          },
          child: Container(
            child: Image.asset(
              name,
              fit: BoxFit.cover,
            ),
          ));
    };
    List<GestureDetector> imageContainer =
        List<GestureDetector>.generate(lengthList, generator);
    return imageContainer;
  }

  Widget buildSticker(ChatModel model) {
    return Container(
      height: 250.0,
      child: GridView.extent(
          maxCrossAxisExtent: 100,
          children: buildImageWidget(12),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          padding: EdgeInsets.all(10)),
    );
  }

  Widget buildInput(ChatModel model) {
    return Container(
      child: Row(
        children: <Widget>[
          // Button send image
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.image),
                onPressed: pickImage,
                color: Colors.blue,
              ),
            ),
            color: Colors.white,
          ),
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.video_label),
                onPressed: pickVideo,
                color: Colors.blue,
              ),
            ),
            color: Colors.white,
          ),
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.attach_file_sharp),
                onPressed: pickAttach,
                color: Colors.blue,
              ),
            ),
            color: Colors.white,
          ),
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.tag_faces_outlined),
                onPressed: getSticker,
                color: Colors.blue,
              ),
            ),
            color: Colors.white,
          ),

          // Edit text
          Flexible(
            child: Container(
              child: TextField(
                onSubmitted: (value) {
                  // onSendMessage(textEditingController.text, 0);
                },
                style: TextStyle(color: Colors.black, fontSize: 15.0),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Message...',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                focusNode: focusNode,
              ),
            ),
          ),
          // Button send message
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  onSendMessage(textEditingController.text, 0);
                },
                color: Colors.blue,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
          color: Colors.white),
    );
  }

  Widget buildSingleMessage(Message message, User friend) {
    return MessageTile(
        type: message.type,
        message: message.text,
        sendByMe: !(message.senderID == widget.friend.chatID),
        avatar: friend.linkAvatar);
  }

  Widget buildListMessage(ChatModel model) {
    List<Message> messages = model.getMessagesForChatID(widget.friend.chatID);
    return Flexible(
        child: groupChatId == ''
            ? Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)))
            : ListView.builder(
                cacheExtent: 1000,
                itemCount: messages.length,
                itemBuilder: (BuildContext context, int index) {
                  return buildSingleMessage(messages[index], friend);
                },
                reverse: true,
                controller: listScrollController,
              ));
  }
}

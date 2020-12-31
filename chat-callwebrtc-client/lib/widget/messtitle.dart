import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:BKZalo/widget/video-player.dart';
import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:flutter/material.dart';
import 'package:BKZalo/widget/full-photo.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

class MessageTile extends StatelessWidget {
  final String message;
  final bool sendByMe;
  int type;
  String avatar;
  MessageTile(
      {@required this.type,
      @required this.message,
      @required this.sendByMe,
      this.avatar});

  @override
  Widget build(BuildContext context) {
    if (type == 1)
      return Container(
          padding: EdgeInsets.only(
              top: 2,
              bottom: 2,
              left: sendByMe ? 0 : 15,
              right: sendByMe ? 24 : 0),
          alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
          child: sendByMe
              ? Container(
                  margin: EdgeInsets.only(left: 0),
                  padding:
                      EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
                  child: ImageTitle(url: message))
              : Row(children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(avatar),
                    radius: 15,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Container(
                      margin: EdgeInsets.only(right: 30),
                      padding: EdgeInsets.only(
                          top: 10, bottom: 10, left: 20, right: 20),
                      child: ImageTitle(url: message))
                ]));
    if (type == 2) {
      return Container(
          padding: EdgeInsets.only(
              top: 2,
              bottom: 2,
              left: sendByMe ? 0 : 15,
              right: sendByMe ? 24 : 0),
          alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
          child: sendByMe
              ? Container(
                  margin: EdgeInsets.only(left: 0),
                  padding:
                      EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 0),
                  child: VideoTitle(url: message))
              : Row(children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(avatar),
                    radius: 15,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Container(
                      margin: EdgeInsets.only(right: 30),
                      padding: EdgeInsets.only(
                          top: 10, bottom: 10, left: 20, right: 20),
                      child: VideoTitle(url: message))
                ]));
    }
    if (type == 3) {
      return Container(
          padding: EdgeInsets.only(
              top: 2,
              bottom: 2,
              left: sendByMe ? 0 : 15,
              right: sendByMe ? 24 : 0),
          alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
          child: sendByMe
              ? Container(
                  margin: EdgeInsets.only(left: 0),
                  padding:
                      EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
                  child: FileTitle(url: message))
              : Row(children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(avatar),
                    radius: 15,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Container(
                      margin: EdgeInsets.only(right: 30),
                      padding: EdgeInsets.only(
                          top: 10, bottom: 10, left: 20, right: 20),
                      child: FileTitle(url: message))
                ]));
    }
    if (type == 4) {
      return Container(
          padding: EdgeInsets.only(
              top: 2,
              bottom: 2,
              left: sendByMe ? 0 : 15,
              right: sendByMe ? 24 : 0),
          alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
          child: sendByMe
              ? Container(
                  margin: EdgeInsets.only(left: 0),
                  padding:
                      EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
                  child: Container(
                    child: Image.asset(
                      'asset/sticker/sticker$message.gif',
                      width: 100.0,
                      height: 100.0,
                      fit: BoxFit.cover,
                    ),
                  ))
              : Row(children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(avatar),
                    radius: 15,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Container(
                      margin: EdgeInsets.only(right: 30),
                      padding: EdgeInsets.only(
                          top: 10, bottom: 10, left: 20, right: 20),
                      child: Container(
                        child: Image.asset(
                          'asset/sticker/sticker$message.gif',
                          width: 100.0,
                          height: 100.0,
                          fit: BoxFit.cover,
                        ),
                      ))
                ]));
    }
    return Container(
        padding: EdgeInsets.only(
            top: 2,
            bottom: 2,
            left: sendByMe ? 0 : 15,
            right: sendByMe ? 24 : 0),
        alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
        child: sendByMe
            ? Container(
                margin: EdgeInsets.only(left: 10),
                padding:
                    EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(23),
                        topRight: Radius.circular(23),
                        bottomLeft: Radius.circular(23)),
                    color: Colors.blue),
                child: Text(message,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    )))
            : Row(children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(avatar),
                  radius: 15,
                ),
                SizedBox(
                  width: 5,
                ),
                Container(
                    margin: EdgeInsets.only(right: 30),
                    padding: EdgeInsets.only(
                        top: 10, bottom: 10, left: 20, right: 20),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(23),
                            topRight: Radius.circular(23),
                            bottomRight: Radius.circular(23)),
                        color: Colors.grey[300]),
                    child: Text(message,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        )))
              ]));
  }
}

class VideoTitle extends StatelessWidget {
  String url;

  VideoTitle({@required this.url});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onLongPress: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => VideoApp(url: url)));
        },
        child: Container(
            width: 260,
            height: 350,
            child: VideoWidget(
              url: url,
              play: true,
            )));
  }
}

class FileTitle extends StatelessWidget {
  String url;

  FileTitle({@required this.url});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Stack(
            alignment: AlignmentDirectional.center,
            children: <Widget>[
              Container(
                width: 130,
                color: Colors.redAccent,
                height: 80,
              ),
              Column(
                children: <Widget>[
                  Icon(
                    Icons.insert_drive_file,
                    color: Colors.white,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    'File',
                    style: TextStyle(fontSize: 20, color: Color(0xff3f3f3f)),
                  ),
                ],
              ),
            ],
          ),
          Container(
              color: Colors.grey[600],
              height: 40,
              width: 130,
              child: IconButton(
                  icon: Icon(
                    Icons.file_download,
                    color: Color(0xff3f3f3f),
                  ),
              onPressed: () => downloadFile(url)
              )
            )
        ],
      ),
    );
  }

  downloadFile(String fileUrl) async {
    final Directory downloadsDirectory =
        await DownloadsPathProvider.downloadsDirectory;
    final String downloadsPath = downloadsDirectory.path;
    await FlutterDownloader.enqueue(
      url: fileUrl,
      savedDir: downloadsPath,
      showNotification:
          true, // show download progress in status bar (for Android)
      openFileFromNotification:
          true, // click on notification to open downloaded file (for Android)
    );
  }
}

class ImageTitle extends StatelessWidget {
  String url;
  ImageTitle({@required this.url});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: FlatButton(
        child: Material(
          child: CachedNetworkImage(
            placeholder: (context, url) => Container(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[300]),
              ),
              width: 200.0,
              height: 200.0,
              padding: EdgeInsets.all(70.0),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Material(
              child: Image.asset(
                'asset/images/img_not_available.jpeg',
                width: 200.0,
                height: 200.0,
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
              clipBehavior: Clip.hardEdge,
            ),
            imageUrl: url,
            width: 200.0,
            height: 200.0,
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          clipBehavior: Clip.hardEdge,
        ),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => FullPhoto(url: url)));
        },
        padding: EdgeInsets.all(0),
      ),
    );
  }
}

import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/webrtc.dart';
import 'package:BKZalo/services/signalling.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';

class CallScreen extends StatelessWidget {
  final String ip;
  final String id;
  final String myId;
  const CallScreen({@required this.ip, @required this.id, @required this.myId});

  @override
  Widget build(BuildContext context) {
    return CallBody(
      ip: ip,
      id: id,
      myId: myId,
    );
  }
}

class CallBody extends StatefulWidget {
  static String tag = 'call_sample';

  final String ip;
  final String id;
  final String myId;
  CallBody({@required this.ip, @required this.id, @required this.myId});

  @override
  _CallBodyState createState() =>
      _CallBodyState(serverIP: ip, peerChatId: id, myId: myId);
}

class _CallBodyState extends State<CallBody> {
  Signaling _signaling;
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  bool _inCalling = false;

  var selfId;
  final String myId;
  final String serverIP;
  final String peerChatId;
  final TextEditingController textEditingController = TextEditingController();

  _CallBodyState({
    @required this.serverIP,
    @required this.peerChatId,
    @required this.myId,
  });

  @override
  initState() {
    super.initState();
    initRenderers();
    _connect();
  }

  initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  @override
  deactivate() {
    super.deactivate();
    if (_signaling != null) _signaling.close();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
  }

  void _connect() async {
    if (_signaling == null) {
      _signaling = Signaling(serverIP, myId)..connect();
      _signaling.onStateChange = (SignalingState state) {
        switch (state) {
          case SignalingState.CallStateNew:
            this.setState(() {
              _inCalling = true;
            });
            break;
          case SignalingState.CallStateBye:
            this.setState(() {
              _localRenderer.srcObject = null;
              _remoteRenderer.srcObject = null;
              _inCalling = false;
            });
            break;
          case SignalingState.CallStateInvite:
          case SignalingState.CallStateConnected:
          case SignalingState.CallStateRinging:
          case SignalingState.ConnectionClosed:
          case SignalingState.ConnectionError:
          case SignalingState.ConnectionOpen:
            break;
        }
      };

      _signaling.onPeersUpdate = ((event) {
        this.setState(() {
          selfId = event['self'];
        });
      });
      _signaling.onPeersUpdate = ((event) {
        this.setState(() {
          selfId = event['self'];
        });
      });

      _signaling.onLocalStream = ((stream) {
        _localRenderer.srcObject = stream;
      });

      _signaling.onAddRemoteStream = ((stream) {
        _remoteRenderer.srcObject = stream;
      });

      _signaling.onRemoveRemoteStream = ((stream) {
        _remoteRenderer.srcObject = null;
      });
    }
  }

  _invitePeer(context, peerId, useScreen) async {
    if (_signaling != null && peerChatId != myId) {
      print("AAAAAAAAAAAAAAAAAAA " + peerChatId + " " + myId);
      _signaling.invite(peerChatId, 'video', useScreen);
      this.setState(() {
        _inCalling = true;
      });
    }
  }

  _hangUp() {
    if (_signaling != null) {
      _signaling.bye();
      _signaling.close();
    }
    Navigator.of(context).pop();
  }

  _switchCamera() {
    _signaling.switchCamera();
  }

  _muteMic() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _inCalling
          ? SizedBox(
              width: 200.0,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    FloatingActionButton(
                      child: const Icon(
                        Icons.switch_camera,
                        color: Colors.black,
                      ),
                      onPressed: _switchCamera,
                      backgroundColor: Colors.white,
                    ),
                    FloatingActionButton(
                      onPressed: _hangUp,
                      tooltip: 'Hangup',
                      child: Icon(Icons.call_end),
                      backgroundColor: Colors.red,
                    ),
                    FloatingActionButton(
                      child: const Icon(
                        Icons.mic_off,
                        color: Colors.black,
                      ),
                      onPressed: _muteMic,
                      backgroundColor: Colors.white,
                    )
                  ]))
          : null,
      body: _inCalling
          ? OrientationBuilder(builder: (context, orientation) {
              return Container(
                child: Stack(children: <Widget>[
                  Positioned(
                      left: 0.0,
                      right: 0.0,
                      top: 0.0,
                      bottom: 0.0,
                      child: Container(
                        margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: RTCVideoView(_remoteRenderer),
                        decoration: BoxDecoration(color: Colors.black54),
                      )),
                  Positioned(
                    right: 20.0,
                    top: 40.0,
                    child: Container(
                      width:
                          orientation == Orientation.portrait ? 110.0 : 150.0,
                      height:
                          orientation == Orientation.portrait ? 150.0 : 110.0,
                      child: RTCVideoView(_localRenderer),
                      decoration: BoxDecoration(color: Colors.black54),
                    ),
                  ),
                ]),
              );
            })
          : Container(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 150,
                  ),
                  Container(
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          _invitePeer(context, peerChatId, false);
                          print('clicky');
                        },
                        child: ClipOval(
                          child: Container(
                            width: 80,
                            height: 80,
                            child: IconButton(
                              iconSize: 50,
                              icon: Icon(
                                Icons.call_end,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                _invitePeer(context, peerChatId, false);
                              },
                            ),
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

import 'dart:async';
import 'package:flutter_webrtc/webrtc.dart';
import 'device_info.dart';
import 'turn.dart';
import 'websocket.dart';
import 'package:BKZalo/config/url.dart';

enum SignalingState {
  CallStateNew,
  CallStateRinging,
  CallStateInvite,
  CallStateConnected,
  CallStateBye,
  ConnectionOpen,
  ConnectionClosed,
  ConnectionError,
}

typedef void SignalingStateCallback(SignalingState state);
typedef void StreamStateCallback(MediaStream stream);
typedef void OtherEventCallback(dynamic event);
typedef void DataChannelMessageCallback(
    RTCDataChannel dc, RTCDataChannelMessage data);
typedef void DataChannelCallback(RTCDataChannel dc);

class Signaling {
  SimpleWebSocket _socket;
  String myId;
  var _host;
  var _port = 3000;
  RTCPeerConnection peerConnection;
  RTCDataChannel dataChannel;
  var _remoteCandidates = [];
  var _turnCredential;

  MediaStream _localStream;
  List<MediaStream> _remoteStreams;
  SignalingStateCallback onStateChange;
  StreamStateCallback onLocalStream;
  StreamStateCallback onAddRemoteStream;
  StreamStateCallback onRemoveRemoteStream;
  OtherEventCallback onPeersUpdate;
  OtherEventCallback onEventUpdate;
  DataChannelMessageCallback onDataChannelMessage;
  DataChannelCallback onDataChannel;

  Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'url': 'stun:stun.l.google.com:19302'},
      /*
       * turn server configuration example.
      {
        'url': 'turn:123.45.67.89:3478',
        'username': 'change_to_real_user',
        'credential': 'change_to_real_secret'
      },
       */
    ]
  };

  final Map<String, dynamic> _config = {
    'mandatory': {},
    'optional': [
      {'DtlsSrtpKeyAgreement': true},
    ],
  };

  final Map<String, dynamic> _constraints = {
    'mandatory': {
      'OfferToReceiveAudio': true,
      'OfferToReceiveVideo': true,
    },
    'optional': [],
  };

  final Map<String, dynamic> _dcConstraints = {
    'mandatory': {
      'OfferToReceiveAudio': false,
      'OfferToReceiveVideo': false,
    },
    'optional': [],
  };

  Signaling(this._host, this.myId);

  close() {
    if (_localStream != null) {
      _localStream.dispose();
      _localStream = null;
    }

    if (peerConnection != null) {
      peerConnection.close();
    }
    if (_socket != null) _socket.close();
  }

  void switchCamera() {
    if (_localStream != null) {
      _localStream.getVideoTracks()[0].switchCamera();
    }
  }

  void invite(String peerId, String media, useScreen) {
    if (this.onStateChange != null) {
      this.onStateChange(SignalingState.CallStateNew);
    }

    _createPeerConnection(peerId, media, useScreen, isHost: true).then((pc) {
      peerConnection = pc;
      if (media == 'data') {
        _createDataChannel(peerId, pc);
      }
      _createOffer(peerId, pc, media);
    });
  }

  void bye() {
    if (_localStream != null) {
      _localStream.dispose();
      _localStream = null;
    }

    if (dataChannel != null) {
      dataChannel.close();
    }
    if (peerConnection != null) {
      peerConnection.close();
    }

    if (this.onStateChange != null) {
      this.onStateChange(SignalingState.CallStateBye);
    }
    _remoteCandidates.clear();
    _socket.close();
  }

  void onMessage(tag, message) async {
    switch (tag) {
      case OFFER_EVENT:
        {
          var id = 'caller';
          var description = message;
          var media = 'call';

          if (this.onStateChange != null) {
            this.onStateChange(SignalingState.CallStateNew);
          }

          var pc = await _createPeerConnection(id, media, false);
          peerConnection = pc;
          await pc.setRemoteDescription(
              RTCSessionDescription(description['sdp'], description['type']));
          await _createAnswer(id, pc, media);
          if (this._remoteCandidates.length > 0) {
            _remoteCandidates.forEach((candidate) async {
              await pc.addCandidate(candidate);
            });
            _remoteCandidates.clear();
          }
        }
        break;
      case ANSWER_EVENT:
        {
          var description = message;
          var pc = peerConnection;
          if (pc != null) {
            await pc.setRemoteDescription(
                RTCSessionDescription(description['sdp'], description['type']));
          }
        }
        break;
      case ICE_CANDIDATE_EVENT:
        {
          var candidateMap = message;
          if (candidateMap != null) {
            var pc = peerConnection;
            RTCIceCandidate candidate = RTCIceCandidate(
                candidateMap['candidate'],
                candidateMap['sdpMid'],
                candidateMap['sdpMLineIndex']);
            if (pc != null) {
              await pc.addCandidate(candidate);
            } else {
              _remoteCandidates.add(candidate);
            }
          }
        }
        break;
      case CLIENT_ID_EVENT:
        {
          if (this.onEventUpdate != null) {
            this.onEventUpdate({'clientId': 'Id: $message'});
          }
        }
        break;
      default:
        break;
    }
  }

  void connect() async {
    var url = '$_host';
    _socket = SimpleWebSocket(url, myId);

    print('connect to $url');

    if (_turnCredential == null) {
      try {
       // _turnCredential = await getTurnCredential(Url.url, _port);
        /*{
            "username": "1584195784:mbzrxpgjys",
            "password": "isyl6FF6nqMTB9/ig5MrMRUXqZg",
            "ttl": 86400,
            "uris": ["turn:127.0.0.1:19302?transport=udp"]
          }
        */
        _iceServers = {
          'iceServers': [
            {
              'url': 'turn:numb.viagenie.ca',
              'username': 'huyhunhngc@gmail.com',
              'credential': 'huyhuynh99'
            },
          ]
        };
      } catch (e) {}
    }

    _socket.onOpen = () {
      print('onOpen');
      this?.onStateChange(SignalingState.ConnectionOpen);
      print({'name': DeviceInfo.label, 'user_agent': DeviceInfo.userAgent});
    };

    _socket.onMessage = (tag, message) {
      print('Received data: $tag - $message');
      this.onMessage(tag, message);
    };

    _socket.onClose = (int code, String reason) {
      print('Closed by server [$code => $reason]!');
      if (this.onStateChange != null) {
        this.onStateChange(SignalingState.ConnectionClosed);
      }
    };

    await _socket.connect();
  }

  Future<MediaStream> createStream(media, userScreen) async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'mandatory': {
          'minWidth':
              '640', // Provide your own width, height and frame rate here
          'minHeight': '480',
          'minFrameRate': '30',
        },
        'facingMode': 'user',
        'optional': [],
      }
    };

    MediaStream stream = userScreen
        ? await navigator.getDisplayMedia(mediaConstraints)
        : await navigator.getUserMedia(mediaConstraints);
    if (this.onLocalStream != null) {
      this.onLocalStream(stream);
    }
    return stream;
  }

  _createPeerConnection(id, media, userScreen, {isHost = false}) async {
    if (media != 'data') _localStream = await createStream(media, userScreen);
    RTCPeerConnection pc = await createPeerConnection(_iceServers, _config);
    if (media != 'data') pc.addStream(_localStream);
    pc.onIceCandidate = (candidate) {
      final iceCandidate = {
        'sdpMLineIndex': candidate.sdpMlineIndex,
        'sdpMid': candidate.sdpMid,
        'candidate': candidate.candidate,
      };
      emitIceCandidateEvent(isHost, iceCandidate);
    };

    print('Turn on speaker phone');
    _localStream.getAudioTracks()[0].enableSpeakerphone(true);

    pc.onIceConnectionState = (state) {
      print('onIceConnectionState $state');
      if (state == RTCIceConnectionState.RTCIceConnectionStateClosed ||
          state == RTCIceConnectionState.RTCIceConnectionStateFailed) {
        bye();
      }
    };

    pc.onAddStream = (stream) {
      if (this.onAddRemoteStream != null) this.onAddRemoteStream(stream);
      //_remoteStreams.add(stream);
    };

    pc.onRemoveStream = (stream) {
      if (this.onRemoveRemoteStream != null) this.onRemoveRemoteStream(stream);
      _remoteStreams.removeWhere((it) {
        return (it.id == stream.id);
      });
    };

    pc.onDataChannel = (channel) {
      _addDataChannel(id, channel);
    };

    return pc;
  }

  _addDataChannel(id, RTCDataChannel channel) {
    channel.onDataChannelState = (e) {};
    channel.onMessage = (RTCDataChannelMessage data) {
      if (this.onDataChannelMessage != null)
        this.onDataChannelMessage(channel, data);
    };
    dataChannel = channel;

    if (this.onDataChannel != null) this.onDataChannel(channel);
  }

  _createDataChannel(id, RTCPeerConnection pc, {label: 'fileTransfer'}) async {
    RTCDataChannelInit dataChannelDict = RTCDataChannelInit();
    RTCDataChannel channel = await pc.createDataChannel(label, dataChannelDict);
    _addDataChannel(id, channel);
  }

  _createOffer(String id, RTCPeerConnection pc, String media) async {
    try {
      RTCSessionDescription s =
          await pc.createOffer(media == 'data' ? _dcConstraints : _constraints);
      pc.setLocalDescription(s);

      final description = {'sdp': s.sdp, 'type': s.type};
      emitOfferEvent(id, description);
    } catch (e) {
      print(e.toString());
    }
  }

  _createAnswer(String id, RTCPeerConnection pc, media) async {
    try {
      RTCSessionDescription s = await pc
          .createAnswer(media == 'data' ? _dcConstraints : _constraints);
      pc.setLocalDescription(s);

      final description = {'sdp': s.sdp, 'type': s.type};
      emitAnswerEvent(description);
    } catch (e) {
      print(e.toString());
    }
  }

  _send(event, data) {
    _socket.send(event, data);
  }

  emitOfferEvent(peerId, description) {
    _send(OFFER_EVENT, {'peerId': peerId, 'description': description});
  }

  emitAnswerEvent(description) {
    _send(ANSWER_EVENT, {'description': description});
  }

  emitIceCandidateEvent(isHost, candidate) {
    _send(ICE_CANDIDATE_EVENT, {'isHost': isHost, 'candidate': candidate});
  }
}

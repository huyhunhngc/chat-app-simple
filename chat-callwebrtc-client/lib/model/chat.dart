import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import './user.dart';
import './message.dart';
import '../config/url.dart';

class ChatModel extends Model {
  List<User> users ;

  String currentID;
  User currentUser;

  List<User> friendList = List<User>();
  List<Message> messages = List<Message>();
  SocketIO socket;

  ChatModel(this.currentID);
  getUsers() async {
    http.Response response = await http.get(Url.url + '/getUser');
    List data = json.decode(response.body);
    for (int i = 0; i < data.length; i++) {
      print(data[i]);
      users.add(User(data[i]['name'], data[i]['id'], data[i]['avatar']));
    }
    currentUser = users.singleWhere((user) => user.chatID == currentID);
    notifyListeners();
    //event();
  }

  getMessages() async {
    http.Response response = await http.get(Url.url + '/getMessage');
    List data = json.decode(response.body);
    for (int i = 0; i < data.length; i++) {
      print(data[i]);

      messages.insert(
          0,
          Message(data[i]['type'], data[i]['content'], data[i]['senderChatID'],
              data[i]['receiverChatID']));
    }
    notifyListeners();
  }

  void init() async {
    currentUser = User("No Name", currentID,
        "https://png.pngitem.com/pimgs/s/130-1300400_user-hd-png-download.png");
    getUsers();
    getMessages();
    friendList =
        users.where((user) => user.chatID != currentUser.chatID).toList();
    event();
  }

  void event() async {
    socket = SocketIOManager()
        .createSocketIO(Url.url, '/', query: 'chatID=${currentUser.chatID}');
    socket.init();

    socket.subscribe('receive_message', (jsonData) {
      Map<String, dynamic> data = json.decode(jsonData);
      messages.insert(
          0,
          Message(data['type'], data['content'], data['senderChatID'],
              data['receiverChatID']));
      notifyListeners();
    });
    socket.connect();
  }

  void sendMessage(int type, String text, String receiverChatID) {
    messages.insert(0, Message(type, text, currentUser.chatID, receiverChatID));
    socket.sendMessage(
      'send_message',
      json.encode({
        'receiverChatID': receiverChatID,
        'senderChatID': currentUser.chatID,
        'content': text,
        'type': type,
      }),
    );
    notifyListeners();
  }

  List<User> getFriendUser() {
    return users.where((user) => user.chatID != currentUser.chatID).toList();
  }

  List<Message> getMessagesForChatID(String chatID) {
    List<Message> mess = messages
        .where((msg) => msg.senderID == chatID || msg.receiverID == chatID)
        .toList();
    return mess;
  }
}

import 'package:BKZalo/view/loginui.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import './chatscreen.dart';
import 'package:BKZalo/model/user.dart';
import 'package:BKZalo/model/chat.dart';
import 'package:BKZalo/widget/search_widget.dart';

// ignore: must_be_immutable
class AllChatsPage extends StatefulWidget {
  final ChatModel model;
  AllChatsPage(this.model);
  @override
  _AllChatsPageState createState() => _AllChatsPageState(model);
}

class _AllChatsPageState extends State<AllChatsPage> {
  ChatModel chatModel;
  _AllChatsPageState(this.chatModel);
  void initState() {
    // chatModel = ChatModel(widget.id);
    // chatModel.init();
    super.initState();
  }

  void friendClicked(User friend) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          print(widget.model.currentID);
          return Chat(friend, chatModel, widget.model.currentID);
        },
      ),
    );
  }

  Widget buildAllChatList(ChatModel model) {
    List<User> users = model.getFriendUser();
    return ListView.builder(
        itemCount: users.length,
        itemBuilder: (BuildContext context, int index) {
          User friend = users[index];
          return ListTile(
            contentPadding: EdgeInsets.only(left: 15, top: 10),
            title: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(friend.linkAvatar),
                ),
                SizedBox(
                  width: 8.0,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      friend.name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text("ID: " + friend.chatID)
                  ],
                )
              ],
            ),
            onTap: () => friendClicked(friend),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
        model: chatModel,
        child: ScopedModelDescendant<ChatModel>(
          builder: (context, child, model) {
            return Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                title: Row(children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(model.currentUser.linkAvatar),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Chats',
                    style: TextStyle(
                      fontSize: 26.0,
                    ),
                  ),
                ]),
                actions: [
                  GestureDetector(
                    onTap: () {
                      //Navigator.of(context).pushNamed('/camera');
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xffeeeeee),
                        shape: BoxShape.circle,
                      ),
                      padding: EdgeInsets.all(10.0),
                      child: Icon(
                        Icons.camera_alt,
                        size: 20.0,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      model = null;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return Login();
                          },
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xffeeeeee),
                        shape: BoxShape.circle,
                      ),
                      padding: EdgeInsets.all(10.0),
                      child: Icon(
                        Icons.logout,
                        size: 20.0,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                ],
              ),
              body: Container(
                child: Column(
                  children: [
                    SearchWidget(),
                    Expanded(
                      child: buildAllChatList(model),
                    )
                  ],
                ),
              ),
              bottomNavigationBar: BottomAppBar(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: BottomNavigationBar(
                    elevation: 0.0,
                    iconSize: 30.0,
                    showUnselectedLabels: false,
                    showSelectedLabels: false,
                    unselectedItemColor: Colors.black54,
                    backgroundColor: Colors.white,
                    selectedItemColor: Colors.black,
                    //currentIndex: current,
                    onTap: (index) {
                      setState(() {
                        //current=index;
                      });
                    },
                    items: [
                      Option(title: "Chats", iconData: Icons.message),
                      Option(title: "People", iconData: Icons.group),
                      Option(title: "Explore", iconData: Icons.explore),
                    ]
                        .map((item) => BottomNavigationBarItem(
                            icon: Icon(item.iconData), title: Text(item.title)))
                        .toList(),
                  ),
                ),
              ),
            );
          },
        ));
  }
}

class Option {
  final String title;
  final IconData iconData;

  Option({this.title, this.iconData});
}

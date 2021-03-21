import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zopek/Services/Constants.dart';
import 'package:zopek/Services/Utils.dart';
import 'package:zopek/Services/database.dart';
import 'package:zopek/Screens/ChatScreens/ChatsView.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchTextTEC = TextEditingController();
  QuerySnapshot snap;
  int searchlength;
  DataBaseServices dataBaseServices = new DataBaseServices();
  Utils utils = new Utils();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      Container(
        padding:
            EdgeInsets.fromLTRB(15, MediaQuery.of(context).padding.top, 15, 0),
        alignment: Alignment.center,
        height: 100,
        color: Colors.black.withBlue(40),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: TextField(
            onSubmitted: onSubmitted,
            controller: searchTextTEC,
            cursorHeight: 20,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Search",
              hintStyle: TextStyle(
                fontSize: 20,
              ),
              prefixIcon: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(Icons.arrow_back),
              ),
              suffixIcon:
                  GestureDetector(onTap: onClear, child: Icon(Icons.clear)),
            ),
          ),
        ),
      ),
      getUsersList(),
    ]));
  }

  void onClear() {
    setState(() {
      searchTextTEC.clear();
    });
  }

  void onSubmitted(String value) async {
    setState(() {});
    await dataBaseServices.getUserBySearchText(value).then((val) {
      setState(() {
        snap = val;
        searchlength = val.docs.length;
      });
    });
  }

  Widget getUsersList() {
    if (searchlength == null || searchlength == 0) {
      return Container();
    } else {
      return Expanded(
        child: Container(
          color: Colors.white,
          child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: searchlength,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () {
                    onTapSearchUsersListTile(index);
                  },
                  leading: CircleAvatar(
                    backgroundImage:
                        NetworkImage(snap.docs[index].get("PhotoURL")),
                  ),
                  title: Text(snap.docs[index].get("UserName")),
                  subtitle: Text(
                    snap.docs[index].get("Bio"),
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 13,
                    ),
                  ),
                );
              }),
        ),
      );
    }
  }

  void onTapSearchUsersListTile(int index) {
    String chatRoomID = utils.getChatRoomID(snap.docs[index].id, Constants.uid);
    List<String> users = [snap.docs[index].id, Constants.uid];
    users.sort();
    DataBaseServices().createChatRoom(
        chatRoomID, utils.mapForChatRoom(users, Timestamp.now()));
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => Chats(
                  uid: snap.docs[index].id,
                  chatRoomID: chatRoomID,
                  incognito: false,
                )));
  }
}

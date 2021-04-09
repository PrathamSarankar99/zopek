import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:zopek/Modals/Constants.dart';
import 'package:zopek/Screens/ChatScreens/ChatsView.dart';
import 'package:zopek/Services/Utils.dart';
import 'package:zopek/Services/database.dart';

class About extends StatefulWidget {
  final String uid;

  const About({Key key, this.uid}) : super(key: key);
  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  DataBaseServices dbs = new DataBaseServices();
  String photoURL="";
  String username="";
  String email="";
  String status = "";
  String fullName = "";
  String age = "";
  @override
  void initState() {
    super.initState();
    getUserInfo();
  }
   
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
          brightness: Brightness.dark,
          backgroundColor: Colors.black.withBlue(40),
          title: Text(username),
        ),
      body: Column(
        children:[
          Expanded(
            flex:3,
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: (){
                      
                    },
                    child: CircleAvatar(
                       minRadius: width*0.22,
                       foregroundImage:photoURL.isNotEmpty? NetworkImage(photoURL):null,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.only(left:width*0.05),
                        width: width*0.45,
                        child: Text(username,style:TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'NotoSerif'
                        )),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left:width*0.05,top: height*0.01),
                        child: TextButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.green),
                            minimumSize: MaterialStateProperty.all(Size(width*0.20,height*0.05))
                          ),
                        
                          onPressed: (){
                            Navigator.of(context).popUntil((route) => route.isFirst);
                            Navigator.pushReplacement(context,  PageTransition(child: Chats(incognito: false,chatRoomID: Utils().getChatRoomID(widget.uid, Constants.uid),uid: widget.uid, ), type:  PageTransitionType.fade) );
                          },
                          child: Row(
                            children: [
                              Icon(Icons.message,color: Colors.white,size: height*0.025,),
                              SizedBox(
                                width: width*0.010,
                              ),
                               Text('Message',style: TextStyle(
                                 color: Colors.white,
                                 fontSize: width*0.050,
                                 
                               ),)
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          Expanded(
            flex:7,
              child: Container(
              child:Column(
                children:[
                  Padding(
                    padding:  EdgeInsets.only(right:width*0.05,left:width*0.05),
                    child: Divider(
                      color: Colors.black.withOpacity(0.3),
                      height: 1,
                      thickness: 1,
                    ),
                  ),
                  Container(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:[
                        Expanded(
                          flex:2,
                          child:Container(
                            padding: EdgeInsets.only(top:height*0.03,left:width*0.06),
                            alignment:Alignment.centerLeft,
                            child: Text("Status",style:TextStyle(
                              color:Colors.black.withOpacity(0.6),
                              fontSize:height*0.025
                            ),),
                          )
                        ),
                        Expanded(
                          flex:3,
                          child:Container(
                            padding: EdgeInsets.only(left:width*0.1,top: height*0.03,bottom:height*0.03,right:width*0.05),
                            alignment:Alignment.centerLeft,
                            child: Text(status.isNotEmpty?status:"- - - - - - -",style: TextStyle(
                              color:Colors.black,
                              fontSize:height*0.025,
                            )),
                          )
                        )
                      ]
                    ),
                  ),
                  Padding(
                    padding:  EdgeInsets.only(right:width*0.05,left:width*0.05),
                    child: Divider(
                      color: Colors.black.withOpacity(0.3),
                      height: 1,
                      thickness: 1,
                    ),
                  ),
                  Container(
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:[
                            Expanded(
                              flex:2,
                              child:Container(
                                padding: EdgeInsets.only(top:height*0.03,left:width*0.06),
                                alignment:Alignment.centerLeft,
                                child: Text("Username",style:TextStyle(
                                  color:Colors.black.withOpacity(0.6),
                                  fontSize:height*0.025
                                ),),
                              )
                            ),
                            Expanded(
                              flex:3,
                              child:Container(
                                padding: EdgeInsets.only(left:width*0.1,top: height*0.03,bottom:height*0.03,right:width*0.05),
                                alignment:Alignment.centerLeft,
                                child: Text(username,style: TextStyle(
                                  color:Colors.black,
                                  fontSize:height*0.025,
                                )),
                              )
                            )
                          ]
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:[
                            Expanded(
                              flex:2,
                              child:Container(
                                padding: EdgeInsets.only(top:height*0.03,left:width*0.06),
                                alignment:Alignment.centerLeft,
                                child: Text("Full Name",style:TextStyle(
                                  color:Colors.black.withOpacity(0.6),
                                  fontSize:height*0.025
                                ),),
                              )
                            ),
                            Expanded(
                              flex:3,
                              child:Container(
                                padding: EdgeInsets.only(left:width*0.1,top: height*0.03,bottom:height*0.03,right:width*0.05),
                                alignment:Alignment.centerLeft,
                                child: Text(fullName,style: TextStyle(
                                  color:Colors.black,
                                  fontSize:height*0.025,
                                )),
                              )
                            )
                          ]
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:[
                            Expanded(
                              flex:2,
                              child:Container(
                                padding: EdgeInsets.only(top:height*0.03,left:width*0.06),
                                alignment:Alignment.centerLeft,
                                child: Text("Email",style:TextStyle(
                                  color:Colors.black.withOpacity(0.6),
                                  fontSize:height*0.025
                                ),),
                              )
                            ),
                            Expanded(
                              flex:3,
                              child:Container(
                                padding: EdgeInsets.only(left:width*0.1,top: height*0.03,bottom:height*0.03,right:width*0.05),
                                alignment:Alignment.centerLeft,
                                child: Text(email,style: TextStyle(
                                  color:Colors.black,
                                  fontSize:height*0.025,
                                )),
                              )
                            )
                          ]
                        ),
                      ],
                    ),
                  ),
                ]
              )
            ),
          ),
        ]
      ),
    );
    
  }
 
  Future getUserInfo() async {
    Stream<DocumentSnapshot> snap = dbs.getUserByID(widget.uid);
    await snap.first.then((value) {
      setState(() {
        photoURL = value.get("PhotoURL");
        username = value.get("UserName").toString().length > 15
            ? '${value.get("UserName").toString().substring(0, 15)}...'
            : value.get("UserName").toString();

        email = value.get("Email");
        status = value.get("Status");
        fullName = value.get("FullName");
      });
    });
  }
}
const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const fcm = admin.messaging();
const db = admin.firestore();
exports.message_notification=functions.firestore.document("ChatRooms"+
    "/{ChatRoomID}/{Messages}/{MessageID}")
    .onCreate(async (snapshot) => {
      try {
        const message = snapshot.data();
        const sendersnap = await db.collection("Users")
            .doc(message.Sender).get();
        const recieversnap = await db.collection("Users")
            .doc(message.Reciever).get();
        const senderName = sendersnap.get("UserName");
        const messageToken = recieversnap.get("MessagingTokens");
        const payload = {
          notification: {
            title: senderName,
            body: message.Message,
            click_action: "FLUTTER_NOTIFICATION_CLICK",
          },
          data: {
            "sender_id": message.Sender,
            "receiver_id": message.Reciever,
          },
        };
        return fcm.sendToDevice(messageToken, payload);
      } catch (err) {
        console.log("Couldn't sent the message"+err);
      }
    });

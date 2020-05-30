import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String id;
  String firebaseId;
  String displayName;
  String photoUrl;

  User.fromDocument(DocumentSnapshot documentSnapshot) {
    var data = documentSnapshot.data;
    id = documentSnapshot.documentID;
    firebaseId = data['uid'];
  }

  User.fromMap(Map<String, dynamic> userData, String documentId) {
    this.id = documentId;
    this.firebaseId = userData['uid'];
  }

  void addFirebaseInfo(String displayName, String photoUrl) {
    this.displayName = displayName;
    this.photoUrl = photoUrl;
  }
}

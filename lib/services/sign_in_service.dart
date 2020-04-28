import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:newspector_flutter/models/user.dart';
import 'package:newspector_flutter/services/firestore_database_service.dart';
import 'package:newspector_flutter/services/news_feed_service.dart';
import 'package:newspector_flutter/services/news_group_service.dart';
import 'package:newspector_flutter/services/news_source_service.dart';
import 'package:newspector_flutter/services/user_service.dart';

import 'news_article_service.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

Future<FirebaseUser> signInWithGoogle() async {
  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  final AuthResult authResult = await _auth.signInWithCredential(credential);
  final FirebaseUser user = authResult.user;

  assert(!user.isAnonymous);
  assert(await user.getIdToken() != null);

  final FirebaseUser currentUser = await _auth.currentUser();
  assert(user.uid == currentUser.uid);

  await createOrGetUserFromDatabase(user.uid);

  return user;
}

void signOutGoogle() async {
  var googleSignOut = googleSignIn.signOut();
  var firebaseSignOut = _auth.signOut();
  await Future.wait([googleSignOut, firebaseSignOut]);

  NewsArticleService.clearStore();
  NewsFeedService.clearFeed();
  NewsGroupService.clearStore();
  NewsSourceService.clearFeed();
  NewsSourceService.clearStore();
  UserService.clearUser();
}

Future<bool> hasSignedInUser() async {
  var firebaseUser = await _auth.currentUser();
  var hasSignedInUser = firebaseUser != null;

  return hasSignedInUser;
}

// with the given uid, check the database for a matching user,
// if there is no user, create a new user,
// fetch the user from the database
Future<User> createOrGetUserFromDatabase(String firebaseUserId) async {
  var userDocument =
      await FirestoreService.getUserWithFirebaseId(firebaseUserId);
  User user;

  // no matching user in the database
  if (userDocument == null) {
    user = await FirestoreService.createUser(firebaseUserId);
  } else {
    user = User.fromDocument(userDocument);
  }

  UserService.assingUser(user);

  return user;
}

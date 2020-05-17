import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:newspector_flutter/models/user.dart';
import 'package:newspector_flutter/services/news_feed_service.dart';
import 'package:newspector_flutter/services/news_group_service.dart';
import 'package:newspector_flutter/services/news_source_service.dart';
import 'package:newspector_flutter/services/user_service.dart';
import 'firestore/firestore_service.dart' as firestore;
import 'news_article_service.dart';

final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

/// Signs in the user using the Google sign in feature.
///
/// First the google sign in will be completed.
/// After that the firebase authentication will be completed using the google sign in authentication.
/// Finally, a user will be created by [createOrGetUserFromDatabase] in firestore.
Future<FirebaseUser> signInWithGoogle() async {
  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  final AuthResult authResult =
      await _firebaseAuth.signInWithCredential(credential);
  final FirebaseUser user = authResult.user;

  assert(!user.isAnonymous);
  assert(await user.getIdToken() != null);

  final FirebaseUser currentUser = await _firebaseAuth.currentUser();
  assert(user.uid == currentUser.uid);

  await createOrGetUserFromDatabase(user.uid);

  return user;
}

/// Signs out the user from both google and firebase.
void signOutGoogle() async {
  var googleSignOut = googleSignIn.signOut();
  var firebaseSignOut = _firebaseAuth.signOut();
  await Future.wait([googleSignOut, firebaseSignOut]);

  NewsArticleService.clearStore();
  NewsFeedService.clearFeed();
  NewsGroupService.clearStore();
  NewsSourceService.clearFeed();
  NewsSourceService.clearStore();
  UserService.clearUser();
}

/// Returns `true` if there is signed in firebase user.
Future<bool> hasSignedInUser() async {
  var firebaseUser = await _firebaseAuth.currentUser();
  var hasSignedInUser = firebaseUser != null;

  if (hasSignedInUser) UserService.userFirebaseId = firebaseUser.uid;

  return hasSignedInUser;
}

/// With the given uid checks the database for a matching user,
/// if there is no existing user creates a new user, otherwise just
/// fetches the user from the database.
Future<User> createOrGetUserFromDatabase(String firebaseUserId) async {
  var userDocument = await firestore.getUserWithFirebaseId(firebaseUserId);
  User user;

  // no matching user in the database
  if (userDocument == null) {
    user = await firestore.createUser(firebaseUserId);
  } else {
    user = User.fromDocument(userDocument);
  }

  UserService.assingUser(user, firebaseUserId);

  return user;
}

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:newspector_flutter/models/user.dart';
import 'package:newspector_flutter/services/user_service.dart';
import 'package:newspector_flutter/utilities.dart';
import 'firestore/firestore_service.dart' as firestore;

final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

/// Signs in the user using the Google sign in feature.
///
/// First the google sign in will be completed.
/// After that the firebase authentication will be completed using the google sign in authentication.
/// Finally, a user will be created by [createOrGetUserFromDatabase] in firestore.
Future<FirebaseUser> signInWithGoogle() async {
  GoogleSignInAccount googleSignInAccount;
  try {
    googleSignInAccount = await googleSignIn.signIn();
  } catch (err) {
    return null;
  }

  if (googleSignInAccount == null) return null;

  final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  final AuthResult authResult =
      await _firebaseAuth.signInWithCredential(credential);
  final FirebaseUser user = authResult.user;

  if (user.isAnonymous) return null;
  if (await user.getIdToken() == null) return null;

  final FirebaseUser currentUser = await _firebaseAuth.currentUser();
  if (user.uid != currentUser.uid) return null;

  await createOrGetUserFromDatabase(user);

  return user;
}

// Future<void> debugSignIn() async {
//   await createOrGetUserFromDatabase('JexMFfY4vTV33Gk60Ldu3vAVICt1');
// }

/// Signs out the user from both google and firebase.
Future<void> signOutGoogle() async {
  await _firebaseAuth.signOut();
  await googleSignIn.signOut();

  clearStoresAndServices();
}

/// Returns `true` if there is signed in firebase user.
Future<bool> hasSignedInUser() async {
  var hasGoogleUser = await googleSignIn.isSignedIn();
  var firebaseUser = await _firebaseAuth.currentUser();
  var hasSignedInUser = hasGoogleUser != null && firebaseUser != null;

  if (hasSignedInUser) UserService.userFirebaseId = firebaseUser.uid;

  return hasSignedInUser;
}

/// With the given uid checks the database for a matching user,
/// if there is no existing user creates a new user, otherwise just
/// fetches the user from the database.
Future<User> createOrGetUserFromDatabase(FirebaseUser firebaseUser) async {
  var firebaseUserId = firebaseUser.uid;
  var userDocument = await firestore.getUserWithFirebaseId(firebaseUserId);
  User user;

  // no matching user in the database
  if (userDocument == null) {
    user = await firestore.createUser(firebaseUserId);
  } else {
    user = User.fromDocument(userDocument);
  }

  user.addFirebaseInfo(firebaseUser.displayName, firebaseUser.photoUrl);

  UserService.assingUser(user, firebaseUserId);

  return user;
}

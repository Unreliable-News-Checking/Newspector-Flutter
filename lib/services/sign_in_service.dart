import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:newspector_flutter/models/user.dart';
import 'package:newspector_flutter/services/firestore_database_service.dart';
import 'package:newspector_flutter/services/user_service.dart';

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

  return user;
}

void signOutGoogle() async {
  await googleSignIn.signOut();
}

Future<bool> hasSignedInUser() async {
  var firebaseUser = await _auth.currentUser();
  var hasSignedInUser = firebaseUser != null;

  if (hasSignedInUser) {
    var user = await createOrGetUserFromDatabase(firebaseUser.uid);
    UserService.assingUser(user);
  }

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
    // create a new user document
    // push the new user to the database
  }

  user = User.fromDocument(userDocument);
  return user;
}

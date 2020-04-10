import 'package:newspector_flutter/mock_database.dart';
import 'package:newspector_flutter/models/user.dart';

class UserService {
  static User user;

  static User getUser() {
    return user;
  }

  static bool hasUser() {
    return user != null;
  }

  static Future<User> updateAndGetUser() async {
    // normalde burda userin ID si ile cekcez
    // userin ID si ile hem user bilgileri cekilcek
    // hemde userin takip ettigi clusterlar
    User _user = await MockDatabase.getUser();
    print(_user.followedGroupIDs);
    print(_user.id);
    print(_user.notificationToken);
    user = _user;
    return _user;
  }
}

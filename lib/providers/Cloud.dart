import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toa_flutter/models/User.dart';

class Cloud {

  final String baseURL = "https://functions.theorangealliance.org";


  Future<User> getUser() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (user != null) {
      String token = await user.getIdToken();
      print(token);
      Map<String, String> headers = {
        'authorization': 'Bearer $token',
        'data': 'basic'
      };
      print('Loading user...');
      Response res = await http.get(baseURL + '/user', headers: headers);
      print(res.body);
      print(User.fromResponse(res.body));

      return User.fromResponse(res.body);
    } else {
      return null;
    }
  }


  Future<String> getUID() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (user != null) {
      return user.uid;
    } else {
      return null;
    }
  }

  Future<bool> isFavEvent(String eventKey) async {
    String uid = await getUID();
    if (uid == null) {
      return false;
    }
    return false; // TODO
  }

  setFavEvent(String eventKey, bool fav) async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (user != null) {
      // TODO: save in myTOA
    }
  }

  Future<bool> isFavTeam(String teamKey) async {
    String uid = await getUID();
    if (uid == null) {
      return false;
    }
    return false; // TODO
  }

  setFavTeam(String teamKey, bool fav) async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (user != null) {
      // TODO: save in myTOA
    }
  }
}
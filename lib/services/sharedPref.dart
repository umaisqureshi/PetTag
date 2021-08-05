import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static SharedPreferences _sharedPrefs;

  init() async {
    if (_sharedPrefs == null) {
      _sharedPrefs = await SharedPreferences.getInstance();
    }
  }

  bool get isSeen => _sharedPrefs.getBool("seen") ?? false;
  String get petType => _sharedPrefs.getString("PetType") ?? null;
  String get currentUserPetType => _sharedPrefs.getString('CurrentUserPetType') ?? null;

  set currentUserPetType(String value){
    _sharedPrefs.setString("CurrentUserPetType", value);
  }

  set petType(String value) {
    _sharedPrefs.setString("PetType", value);
  }

  set isSeen(bool value) {
    _sharedPrefs.setBool("seen", value);
  }

  clearPetType(){
    _sharedPrefs.remove("PetType");
  }


}
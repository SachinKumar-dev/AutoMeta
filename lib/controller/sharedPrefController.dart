import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthManager extends GetxService {

  static const String _loginKey = 'isLoggedIn';

  // Set login key during login
  Future<void> login() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loginKey, true);
  }

  // Retrieve login status
  Future<bool?> getLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loginKey) ?? false;
  }

  // Clear login key during logout
  Future<void> clearLoginKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loginKey);
  }

  //setName
  Future<void> setName({required String name})async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("name", name);
  }

  //getName
  Future<String> getName()async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("name") ?? "User";
  }

  //clear name
  Future<void> deleteName()async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("name");
  }

}

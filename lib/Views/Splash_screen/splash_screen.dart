import 'dart:async';
import 'package:auto_meta/Views/auth_pages/login_page/login_page.dart';
import 'package:auto_meta/Views/home_page/Home_page.dart';
import 'package:auto_meta/controller/sharedPrefController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final AuthManager authService = Get.find<AuthManager>();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    bool? isLoggedIn = await authService.getLoginStatus();
    print("does user logged in $isLoggedIn");
    //Navigate based on the login status
    Timer(const Duration(seconds: 1), () {
      if(isLoggedIn!=null) {
        if (isLoggedIn) {
          Get.to(() => const HomePage(), transition: Transition.rightToLeft);
        } else {
          Get.to(() => LoginPage(), transition: Transition.rightToLeft);
        }
      }
      else{
        Get.to(() => LoginPage(), transition: Transition.rightToLeft);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Center(child: Image.asset("assets/logos/Splash.png", fit: BoxFit.cover)),
    );
  }
}


import 'package:auto_meta/Views/Splash_screen/splash_screen.dart';
import 'package:auto_meta/controller/fileHandlerController.dart';
import 'package:auto_meta/controller/sharedPrefController.dart';
import 'package:auto_meta/services/firebaseOptions/firebaseOptions.dart';
import 'package:auto_meta/utility/app_theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'controller/AuthController.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseOptions);
  Get.put(AuthController());
  Get.put(FileHandlerController());
  await Get.put(AuthManager()).getLoginStatus();
  await Get.put(AuthManager()).getName();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return ScreenUtilInit(
      minTextAdapt: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.themeData(),
          home: const SplashScreen(),
        );
      },
    );
  }
}

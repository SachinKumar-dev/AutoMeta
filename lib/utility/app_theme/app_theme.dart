import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static var primaryColor = const Color(0xffBD32FE);
  static var formFields = const Color(0xff232326);
  static var bgColor = const Color(0xff0E0E0E);
  static var inactiveIcons = const Color(0xff424345);
  static var secondaryText = const Color(0xffBEBEC3);
  static var primaryText = const Color(0xffFFFFFF);
  static var errors = const Color(0xffFF4A4A);
  static var disabledAction = const Color(0xffBD32FE).withOpacity(0.4);

  static Widget headingText({required String heading}) {
    return Text(heading,
        style: GoogleFonts.rubik(
            fontSize: 30.sp, color: primaryText, fontWeight: FontWeight.bold));
  }

  static Widget subHeadingText({required String subHeading}) {
    return Text(subHeading,
        style: GoogleFonts.rubik(
            fontSize: 16.sp,
            color: secondaryText,
            fontWeight: FontWeight.bold));
  }

  static Widget bodyText({required String bodyText}) {
    return Text(bodyText,
        style: GoogleFonts.rubik(fontSize: 16.sp, color: primaryText));
  }

  static Widget buttonLarge({required String largeButtonText}) {
    return Text(largeButtonText,
        style: GoogleFonts.rubik(fontSize: 18.sp, color: primaryText));
  }

  static Widget smallButton({required String smallButtonText}) {
    return Text(smallButtonText,
        style: GoogleFonts.rubik(fontSize: 16.sp, color: primaryText));
  }

  //theme
  static ThemeData themeData() {
    return ThemeData(
      scaffoldBackgroundColor: bgColor,
      primaryColor: primaryText,
      brightness: Brightness.dark,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}

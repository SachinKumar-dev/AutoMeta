import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class WidgetHelper{

  //snack bar
  static SnackbarController snackBar(String title, String message,
      {required Color color}) {
    return Get.snackbar(title, message, colorText: color);
  }

  //text design
  static Text styleText(
      {required String text,
        double size = 20.0,
        txtColor = Colors.white,
        FontWeight weight = FontWeight.normal}) {
    return Text(
      text,
      style: GoogleFonts.poppins(
          fontSize: size, color: txtColor, fontWeight: weight),
    );
  }


  //height
 static double height({required BuildContext context, var value}) {
    var height = MediaQuery.of(context).size.height * value;
    return height;
  }

//width
  static double width({required BuildContext context, var value}) {
    var width = MediaQuery.of(context).size.width * value;
    return width;
  }

}

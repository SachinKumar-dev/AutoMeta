import 'package:auto_meta/Views/auth_pages/otp_page/pin_page.dart';
import 'package:auto_meta/Views/home_page/Homepage.dart';
import 'package:auto_meta/controller/sharedPrefController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controller/AuthController.dart';
import '../../../utility/app_theme/app_theme.dart';
import '../../../utility/widget_helper/pop_ups.dart';
import '../../home_page/Home_page.dart';

class OtpPage extends StatelessWidget {
  OtpPage({super.key});

  final ctrl = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Expanded(
              child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(18.h),
                  child: AppTheme.bodyText(
                      bodyText:
                          "Otp sent to ${ctrl.numberController.text.trim()}"),
                ),
                PinInputWidget(
                  onCompleted: (pin) {
                    print("Pin entered: $pin");
                  },
                ),
                SizedBox(
                  height: WidgetHelper.height(context: context, value: 0.04),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        Get.dialog(
                            Center(
                                child: CircularProgressIndicator(
                                    color: AppTheme.primaryColor)),
                            barrierDismissible: false);
                        await ctrl.resendOTP(onSuccess: () {
                          Get.back();
                          ctrl.showSnackBar(
                              title: "Success!",
                              message: "Otp sent successfully",
                              bgColor: Colors.green.shade300);
                        }, onError: (errorMessage) {
                          Get.back();
                          ctrl.showSnackBar(
                              title: "Oops!",
                              message: errorMessage,
                              bgColor: Colors.red.shade300);
                        });
                      },
                      child: SizedBox(
                          child: Text(
                        "Resend OTP",
                        style: GoogleFonts.rubik(
                            fontSize: 16.sp, color: AppTheme.primaryColor),
                      )),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 20),
                  child: TextFormField(
                    controller: ctrl.nameCtrl,
                    keyboardType: TextInputType.text,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(20),
                    ],
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppTheme.formFields,
                      hintText: 'Enter your name',
                      hintStyle: GoogleFonts.rubik(
                        fontSize: 16.sp,
                        color: AppTheme.secondaryText,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(60.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),
          //button login
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            child: Container(
              margin: EdgeInsets.only(bottom: 40.h),
              height: WidgetHelper.height(context: context, value: 0.07),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async{
                  if (ctrl.isSuccessOtp &&
                      ctrl.nameCtrl.text.trim().isNotEmpty) {
                    await Get.find<AuthManager>().setName(name: ctrl.nameCtrl.text.trim());
                    await Get.find<AuthManager>().login();
                    Get.off(() => const HomePage(),
                        transition: Transition.rightToLeft);
                    ctrl.nameCtrl.clear();
                    FocusManager.instance.primaryFocus?.unfocus();
                    ctrl.numberController.clear();
                    ctrl.otpController.clear();
                    await ctrl.toggleOtpLoginType(true);
                  }
                },
                child: AppTheme.smallButton(smallButtonText: "Login"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

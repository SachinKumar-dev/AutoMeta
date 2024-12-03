import 'package:auto_meta/Views/home_page/Home_page.dart';
import 'package:auto_meta/Views/home_page/Homepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controller/AuthController.dart';
import '../../../controller/sharedPrefController.dart';
import '../../../utility/app_theme/app_theme.dart';
import '../../../utility/widget_helper/pop_ups.dart';
import '../otp_page/otp_page.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final ctrl = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AppTheme.headingText(heading: "Login"),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        controller: ctrl.numberController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppTheme.formFields,
                          hintText: 'Enter your mobile number',
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
                    SizedBox(
                      height:
                      WidgetHelper.height(context: context, value: 0.04),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            await ctrl.signInWithGoogle();
                            print(ctrl.user.value?.name);
                            print(ctrl.user.value?.photoUrl);
                              Get.to(() => const HomePage());
                              await Get.find<AuthManager>().login();
                          },
                          child: Container(
                            height: WidgetHelper.height(
                                context: context, value: 0.08),
                            width: WidgetHelper.width(
                                context: context, value: 0.15),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                "assets/logos/google.svg",
                                height: 50,
                                width: 50,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10.0, vertical: 20.0),
                child: Container(
                  margin: EdgeInsets.only(bottom: 40.h),
                  height: WidgetHelper.height(context: context, value: 0.07),
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      Get.dialog(
                        Center(
                          child: CircularProgressIndicator(
                              color: AppTheme.primaryColor),
                        ),
                        barrierDismissible: false,
                      );
                      await ctrl.sendOTP(onSuccess: () {
                        Get.back();
                        Get.to(() => OtpPage(),
                            transition: Transition.rightToLeft);
                      }, onError: (String errorMessage) {
                        Get.back();
                        ctrl.showSnackBar(title: "Warning",message: errorMessage,bgColor: Colors.red.shade300);
                        print(errorMessage);
                      });
                    },
                    child: AppTheme.smallButton(smallButtonText: "Send OTP"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

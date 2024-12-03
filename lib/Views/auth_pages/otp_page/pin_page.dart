import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import '../../../controller/AuthController.dart';
import '../../../utility/app_theme/app_theme.dart';

class PinInputWidget extends StatefulWidget {
  final void Function(String) onCompleted;

  const PinInputWidget({super.key, required this.onCompleted});

  @override
  State<PinInputWidget> createState() => _PinInputWidgetState();
}

class _PinInputWidgetState extends State<PinInputWidget> {
  Color messageColor = Colors.grey;
  String message = '';

  final ctrl = Get.find<AuthController>();


  @override
  Widget build(BuildContext context) {
    // Default PIN theme
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: GoogleFonts.rubik(
        fontSize: 16.sp,
        color: AppTheme.primaryText,
      ),
      decoration: BoxDecoration(
        color: AppTheme.bgColor,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10.r),
      ),
    );

    // Focused PIN theme
    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border:ctrl.isOtpLocked? Border.all(color: Colors.grey):Border.all(color: AppTheme.primaryColor),
      borderRadius: BorderRadius.circular(12),
    );

    // Submitted PIN theme
    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: AppTheme.bgColor,
      ),
    );

    return Column(
      children: [
        Pinput(
          controller:ctrl.otpController,
          length: 6,
          readOnly: ctrl.isOtpLocked,
          defaultPinTheme: defaultPinTheme,
          focusedPinTheme:focusedPinTheme,
          submittedPinTheme: submittedPinTheme,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Enter OTP';
            }
            return null;
          },
          pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
          showCursor: true,
          cursor: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 2,
                height: 20,
                color: AppTheme.primaryColor,
              ),
            ],
          ),
          onCompleted: (pin) async {
            print("Entered PIN: $pin");
            await ctrl.verifyOTP(
              otp: pin,
              onSuccess: () {
                setState(() {
                  messageColor = Colors.green;
                  message = 'Success! OTP is correct.';
                  ctrl.isOtpLocked=true;
                });
              },
              onError: (error) {
                setState(() {
                  messageColor = Colors.red;
                  message = 'Invalid OTP';
                });
              },
            );
          },
        ),
        SizedBox(height: 28.h),
        Text(
          message,
          style: GoogleFonts.rubik(
            color: messageColor,
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
          ),
        ),
      ],
    );
  }
}

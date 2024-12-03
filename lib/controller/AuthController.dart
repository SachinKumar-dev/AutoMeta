import 'dart:convert';
import 'package:auto_meta/models/userModel.dart';
import 'package:auto_meta/utility/app_theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {

  final numberController = TextEditingController();
  final otpController = TextEditingController();
  final nameCtrl = TextEditingController();
  bool isOtpLocked = false;

  bool isLoggedIn = false;

  var isLoading = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;
  int? _resendToken;
  String otp = '';
  bool isSuccessOtp = false;

  var otpLogInType = false.obs;

  late String name;

  @override
  void onInit() {
    loadUserFromCache();
    initializeOtpLoginType();
    super.onInit();
  }

  //cache the login type bool
  Future<void> toggleOtpLoginType(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    otpLogInType.value = value;
    prefs.setBool('otpLogInType', value); // Save the value
  }

  //read the bool
  Future<void> initializeOtpLoginType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    otpLogInType.value = prefs.getBool('otpLogInType') ?? false;
  }

  //clear bool cache
  Future<void> clearBool()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('otpLogInType');
  }

  //stores signIn user details
  var user = Rxn<UserModel>();

  // Sends an OTP to the given phone number
  Future<void> sendOTP({
    required Function() onSuccess,
    required Function(String errorMessage) onError,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: "+91${numberController.text.trim()}",
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          update();
        },
        verificationFailed: (FirebaseAuthException e) {
          String errorMessage = "Something went wrong.";
          if (e.code == 'invalid-phone-number') {
            errorMessage = "The phone number entered is invalid.";
          } else if (e.code == 'quota-exceeded') {
            errorMessage = "Quota exceeded. Please try again later.";
          }
          onError(errorMessage);
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          onSuccess();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      onError("An unexpected error occurred");
      print("An unexpected error occurred: $e");
    }
  }

  // Resend OTP to the same phone number
  Future<void> resendOTP({
    required Function() onSuccess,
    required Function(String errorMessage) onError,
  }) async {
    try {
      if (_resendToken == null) {
        onError("Please try sending OTP again.");
        return;
      }
      await _auth.verifyPhoneNumber(
        phoneNumber: "+91${numberController.text.trim()}",
        timeout: const Duration(seconds: 60),
        forceResendingToken: _resendToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Automatically verify the phone number if possible
          await _auth.signInWithCredential(credential);
          onSuccess();
        },
        verificationFailed: (FirebaseAuthException e) {
          String errorMessage = "Resend failed.";
          if (e.code == 'invalid-phone-number') {
            errorMessage = "The phone number entered is invalid.";
          }
          onError(errorMessage);
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          onSuccess();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      onError("An unexpected error occurred");
      print("An unexpected error occurred: $e");
    }
  }

  // Verify the OTP entered by the user
  Future<void> verifyOTP({
    required String otp,
    required Function() onSuccess,
    required Function(String errorMessage) onError,
  }) async {
    try {
      if (_verificationId == null) {
        onError("Verification ID is null. Please request a new OTP.");
        return;
      }
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      await _auth.signInWithCredential(credential);
      onSuccess();
      isSuccessOtp = true;
    } catch (e) {
      onError("Invalid OTP. Please try again.");
    }
  }

  // google direct login
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      // Initiate Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Check if login was successful
      if (googleUser != null) {
        var model=UserModel.fromJson({
          'name': googleUser.displayName,
          'profilePicture': googleUser.photoUrl,
        });
        user.value=model;
        await saveUserToCache(model);
      } else {
        throw Exception("Login process canceled by the user.");
      }
    } catch (error) {
      print("Google Sign-In Error: $error");
    } finally {
      isLoading.value = false;
    }
  }

  // Logout from Google
  Future<void> signOut() async {
    try {
      // Show loading dialog
      Get.dialog(
        Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
        barrierDismissible: false,
      );

      // Check login type and handle logout
      if (otpLogInType.value) {
        // Handle OTP-based logout
        print("Performing logout for OTP login user");
        await clearUserCache();
      } else {
        // Handle Google Sign-In logout
        print("Performing logout for Google login user");
        await _googleSignIn.signOut();
      }

      print("User successfully logged out");
    } catch (error) {
      Get.back();
      showSnackBar(
        title: "Oops!",
        message: "Unable to logout",
        bgColor: Colors.red.shade300,
      );
      print("Sign-Out Error: $error");
    } finally {
      Get.back();
    }
  }


  //snackBar
  SnackbarController showSnackBar({
    required String title,
    required String message,
    required Color bgColor,
  }) {
    return Get.snackbar(
      '',
      '',
      titleText: AppTheme.bodyText(bodyText: title),
      messageText: Text(message,
          style: GoogleFonts.rubik(
              fontSize: 14.sp,
              color: Colors.white,
              fontWeight: FontWeight.w500)),
      backgroundColor: bgColor,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  // Save user data to SharedPreferences
  Future<void> saveUserToCache(UserModel userModel) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(userModel.toJson()));
  }

  // Load user data from SharedPreferences
  Future<void> loadUserFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('user');
    if (userData != null) {
      user.value = UserModel.fromJson(jsonDecode(userData));
      print("Loaded user data: ${user.value?.name}, ${user.value?.photoUrl}");
    } else {
      print("No cached user data found.");
    }
  }

  // Clear user data from SharedPreferences
  Future<void> clearUserCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    user.value = null;
    user.refresh();
  }

}

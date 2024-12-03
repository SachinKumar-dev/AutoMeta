import 'package:auto_meta/controller/AuthController.dart';
import 'package:auto_meta/controller/sharedPrefController.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controller/fileHandlerController.dart';
import '../../utility/app_theme/app_theme.dart';
import '../../utility/widget_helper/pop_ups.dart';
import '../auth_pages/login_page/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ctrl = Get.find<FileHandlerController>();
  final authController = Get.find<AuthController>();
  final sharedPrefController = Get.find<AuthManager>();
  final FirebaseAuth auth = FirebaseAuth.instance;
  String userName = "";

  @override
  void initState() {
    super.initState();
    initializeUserName();
  }

  //get userName
  Future<void> initializeUserName() async {
    if (authController.otpLogInType.value) {
      // If OTP login, get name from shared preferences
      userName = await sharedPrefController.getName();
    } else {
      // If Google login, get name from AuthController
      final user = authController.user.value;
      userName = user?.name ?? "No User";
    }
    setState(() {});
  }

  //json fun
  void loadJsonData() async {
    final messageData = await ctrl.pickAndParseJson();
    if (messageData != null) {
      setState(() {
        ctrl.nameController.text = messageData.customerName;
        ctrl.mobileController.text = messageData.mobileNumber;
        ctrl.messageController.text = messageData.message;
      });
    }
  }

  // Upload PDF and update the state
  void uploadPdfFile() async {
    ctrl.pdfUrl = await ctrl.uploadPdf();
    if (ctrl.pdfUrl != null) {
      print("PDF uploaded: ${ctrl.pdfUrl}");
    }
  }

  // Send message with or without PDF
  void sendDetails(bool viaWhatsApp) async {
    final Map<String, dynamic> data = {
      "customerName": ctrl.nameController.text.trim(),
      "mobileNumber": ctrl.mobileController.text.trim(),
      "message": ctrl.messageController.text.trim(),
      if (ctrl.pdfUrl != null) "pdf": ctrl.pdfUrl,
    };

    print("Sending data: $data");

    await ctrl.sendMessage(viaWhatsApp: viaWhatsApp);
    ctrl.clearFields();
    setState(() {
      ctrl.pdfUrl = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: GestureDetector(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: Container(
                        height:
                            WidgetHelper.height(context: context, value: 0.08),
                        width: WidgetHelper.width(context: context, value: 1),
                        decoration: BoxDecoration(
                          color: AppTheme.inactiveIcons,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GetBuilder<AuthController>(
                              builder: (ctrl) {
                                if (ctrl.otpLogInType.value) {
                                  return Row(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Icon(Icons.person_2_rounded),
                                      ),
                                      AppTheme.bodyText(bodyText: userName),
                                    ],
                                  );
                                } else if (ctrl.isLoading.value) {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      color: AppTheme.primaryColor,
                                    ),
                                  );
                                } else if (ctrl.user.value != null) {
                                  return Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Image.network(
                                          ctrl.user.value!.photoUrl,
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      AppTheme.bodyText(
                                        bodyText: userName,
                                      ),
                                    ],
                                  );
                                } else {
                                  return const Center(child: Text("No User"));
                                }
                              },
                            ),
                            IconButton(
                              onPressed: () async {
                                // Show loading dialog
                                Get.dialog(
                                  Center(
                                    child: CircularProgressIndicator(
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                  barrierDismissible: false,
                                );

                                // Perform logout operations
                                await authController.signOut();
                                await sharedPrefController.clearLoginKey();
                                await authController.clearBool();
                                await authController.clearUserCache();
                                await sharedPrefController.deleteName();
                                // Navigate to Login Page
                                Get.off(() => LoginPage());
                              },
                              icon: SvgPicture.asset(
                                "assets/logos/logout.svg",
                                height: 20,
                                colorFilter: ColorFilter.mode(
                                  AppTheme.primaryColor,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.03,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          minLines: 1,
                          maxLines: 10,
                          controller: ctrl.nameController,
                          decoration: InputDecoration(
                              hintText: "User Name",
                              hintStyle: GoogleFonts.rubik(),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide:
                                      const BorderSide(color: Colors.white54)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: AppTheme.primaryColor),
                                  borderRadius: BorderRadius.circular(12.r))),
                        ),
                        SizedBox(height: 20.h),
                        TextField(
                          minLines: 1,
                          maxLength: 13,
                          controller: ctrl.mobileController,
                          decoration: InputDecoration(
                              hintText: "Mobile Number",
                              hintStyle: GoogleFonts.rubik(),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide:
                                      const BorderSide(color: Colors.white54)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: AppTheme.primaryColor),
                                  borderRadius: BorderRadius.circular(12.r))),
                        ),
                        SizedBox(height: 20.h),
                        TextField(
                          minLines: 1,
                          maxLines: 1000,
                          controller: ctrl.messageController,
                          decoration: InputDecoration(
                              hintText: "Message",
                              hintStyle: GoogleFonts.rubik(),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide:
                                      const BorderSide(color: Colors.white54)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: AppTheme.primaryColor),
                                  borderRadius: BorderRadius.circular(12.r))),
                        ),
                        SizedBox(height: 25.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                minimumSize: const Size(150, 50),
                              ),
                              onPressed: loadJsonData,
                              child: AppTheme.smallButton(
                                  smallButtonText: "Load Json"),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                minimumSize: const Size(150, 50),
                              ),
                              onPressed: uploadPdfFile,
                              child: AppTheme.smallButton(
                                  smallButtonText: "Upload Pdf"),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 30.h, left: 15.w),
                          child:
                              AppTheme.bodyText(bodyText: "Select Send Type"),
                        ),
                        SizedBox(height: 20.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    minimumSize: const Size(150, 50),
                                  ),
                                  onPressed: () => sendDetails(true),
                                  child: AppTheme.smallButton(
                                      smallButtonText: "Whatsapp"),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    minimumSize: const Size(150, 50),
                                  ),
                                  onPressed: () => sendDetails(false),
                                  child: AppTheme.smallButton(
                                      smallButtonText: "SMS"),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

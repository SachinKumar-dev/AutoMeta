import 'dart:convert';
import 'dart:io';

import 'package:auto_meta/controller/AuthController.dart';
import 'package:auto_meta/models/messageData.dart';
import 'package:auto_meta/utility/widget_helper/pop_ups.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utility/app_theme/app_theme.dart';

class FileHandlerController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  String? pdfUrl;

  final ctrl = Get.find<AuthController>();

  //pick and parse json file
  Future<MessageData?> pickAndParseJson() async {
    try {
      // Pick the JSON file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        final json = jsonDecode(content);
        return MessageData.fromJson(json);
      } else {
        return null;
      }
    } catch (e) {
      print("Error picking or parsing JSON: $e");
      return null;
    }
  }

  // Send message via WhatsApp or SMS
  Future<void> sendMessage({required bool viaWhatsApp}) async {
    // Construct the message
    String message =
        "Hello, ${nameController.text.trim()} ${messageController.text.trim()}";

    // Append PDF URL if it exists
    if (pdfUrl != null) {
      message += "\nFile: $pdfUrl";
    }

    // Construct the URI based on the selected method
    final Uri url = viaWhatsApp
        ? Uri.parse(
            "https://wa.me/${mobileController.text.trim()}?text=${Uri.encodeComponent(message)}")
        : Uri.parse(
            "sms:${mobileController.text.trim()}?body=${Uri.encodeComponent(message)}");

    // Launch the URL
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      print("Could not launch URL.");
    }
  }

  // Upload PDF to Firebase Storage
  Future<String?> uploadPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'img', 'jpg', 'jpeg'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;

      try {
        Get.dialog(
          Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
            ),
          ),
          barrierDismissible: false,
        );

        // Upload the file
        final ref = FirebaseStorage.instance.ref().child('pdfs/$fileName');
        await ref.putFile(file);

        // Close the loading indicator
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }

        // Show success snackbar
        ctrl.showSnackBar(
          title: "Success",
          message: "File uploaded successfully",
          bgColor: Colors.green.shade300,
        );

        return await ref.getDownloadURL();
      } catch (e) {
        // Close the loading indicator in case of an error
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }

        ctrl.showSnackBar(
            title: "Oops!",
            message: "Unable to upload file",
            bgColor: Colors.red.shade300);
        print("Error uploading PDF: $e");
      }
    } else {
      ctrl.showSnackBar(
        title: "No File Selected",
        message: "Please select a valid file to upload",
        bgColor: Colors.red.shade300,
      );
    }
    return null;
  }

  // Clear fields
  void clearFields() {
    nameController.clear();
    mobileController.clear();
    messageController.clear();
  }
}

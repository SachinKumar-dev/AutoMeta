import 'package:auto_meta/Views/auth_pages/login_page/login_page.dart';
import 'package:auto_meta/controller/AuthController.dart';
import 'package:auto_meta/controller/fileHandlerController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerForm extends StatefulWidget {
  const CustomerForm({super.key});

  @override
  _CustomerFormState createState() => _CustomerFormState();
}

class _CustomerFormState extends State<CustomerForm> {

  final ctrl = Get.find<FileHandlerController>();
  final ctrlTwo = Get.find<AuthController>();


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
      appBar: AppBar(title: const Text("JSON and PDF Uploader"),
      actions: [
        IconButton(onPressed: ()async{
          await ctrlTwo.signOut();
           Get.off(()=>LoginPage());
           ctrlTwo.isOtpLocked=false;


        }, icon:const Icon(Icons.logout_rounded))
      ],),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: ctrl.nameController,
              decoration: const InputDecoration(labelText: "Customer Name"),
            ),
            TextField(
              controller: ctrl.mobileController,
              decoration: const InputDecoration(labelText: "Mobile Number"),
            ),
            TextField(
              controller: ctrl.messageController,
              decoration: const InputDecoration(labelText: "Message"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loadJsonData,
              child: const Text("Load JSON"),
            ),
            ElevatedButton(
              onPressed: uploadPdfFile,
              child: const Text("Upload PDF"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => sendDetails(true),
              child: const Text("Send via WhatsApp"),
            ),
            ElevatedButton(
              onPressed: () => sendDetails(false),
              child: const Text("Send via SMS"),
            ),
          ],
        ),
      ),
    );
  }
}

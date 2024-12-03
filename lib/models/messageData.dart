class MessageData {
  final String message;
  final String mobileNumber;
  final String? pdf;
  final String customerName;


  MessageData(
      {required this.message,
      required this.mobileNumber,
      required this.customerName,
      this.pdf});

  //from json
  factory MessageData.fromJson(Map<String, dynamic> map) {
    return MessageData(
      message: map['message'],
      mobileNumber: map['mobileNumber'],
      customerName: map['customerName'],
      pdf: map['pdf'],
    );
  }

  //toJson
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'mobileNumber': mobileNumber,
      'customerName': customerName,
      'pdf': pdf
    };
  }
}

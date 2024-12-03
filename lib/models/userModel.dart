class UserModel {
  final String name;
  final String photoUrl;

  UserModel({required this.name,required this.photoUrl});

  //from json
  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
      photoUrl: map['profilePicture'],
      name: map['name'],
    );
  }

  //to json
  Map<String,dynamic> toJson(){
    return{
      'profilePicture':photoUrl,
      'name':name,
    };
  }
}

class UserModel {
  UserModel({
      this.id,
      this.email,
      this.uid,
      this.provider,
      this.name,
      this.phoneNumber,
      this.role,
      this.addressId,
      this.picBlok,
      this.avatar
  });

  int id;
  String email;
  String uid;
  String provider;
  String name;
  String phoneNumber;
  int role;
  int addressId;
  dynamic picBlok;
  String avatar;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    print("UserModel from model");
    print(json);
    return UserModel(
      id: json["id"],
      email: json["email"],
      uid: json["uid"],
      provider: json["provider"],
      name: json["name"],
      phoneNumber: json["phone_number"],
      role: json["role"],
      addressId: json["address_id"],
      picBlok: json["pic_blok"],
      avatar: json["avatar"]
    );
  }
}
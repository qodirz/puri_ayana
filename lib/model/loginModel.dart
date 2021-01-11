class LoginModel {
  String accessToken;
  String uid;
  String expiry;
  String client;

  LoginModel({
    this.accessToken,
    this.uid,
    this.expiry,   
    this.client
  });

  factory LoginModel.api(Map<String, String> json) {
    print("LoginModel from model");
    print(json);
    return LoginModel(
      accessToken: json['access-token'],
      uid: json["uid"],
      expiry: json["expiry"],
      client: json["client"]
    );
  }
}

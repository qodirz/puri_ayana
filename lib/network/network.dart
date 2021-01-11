class NetworkURL {
  static String server = "http://103.41.204.225";

  static String registrasi() {
    return "$server/api/v1/auth";
  }

  static String login() {
    return "$server/api/v1/auth/sign_in";
  }

  static String logOut() {
    return "$server/api/v1/auth/sign_out";
  }

  static String resetPasswordToken() {
    return "$server/api/v1/user/reset_password_token";
  }

  static String homePage() {
    return "$server/api/v1/home_page";
  }
  
  static String resetPassword() {
    return "$server/api/v1/user/reset_password";
  }
  
  static String updatePassword(){
    return "$server/api/v1/auth/password";
  }

  static String getProfile() {
    return "$server/api/v1/profile";
  }

  static String updateProfile() {
    return "$server/api/v1/user/profile/update";
  }

  static String cashFlow(String year) {
    return "$server/api/v1/cash_flows/$year";
  }

  static String contributions() {
    return "$server/api/v1/contributions";
  }

  static String blockDetail(String blok) {
    return "$server/api/v1/address/info/$blok";
  }
  
  static String payContribution(){
    return "$server/api/v1/pay_contribution";
  }

  static String addTransaction(){
    return "$server/api/v1/add_transaction";
  }

  static String pengumuman(){
    return "$server/api/v1/notifications";
  }
  
  
}

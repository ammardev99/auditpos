class LoginResponseModel {
  final bool success;
  final String token;

  LoginResponseModel({
    required this.success,
    required this.token,
  });

  factory LoginResponseModel.fromJson(
      Map<String, dynamic> json) {
    return LoginResponseModel(
      success: json['success'],
      token: json['token'],
    );
  }
}
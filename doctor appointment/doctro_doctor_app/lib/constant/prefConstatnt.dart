class Preferences {
  Preferences._();

  //Set Data in Preferences
  static const String is_logged_in = "isLoggedIn";
  static const String name = "name";
  static const String dob = "dob";
  static const String gender = "gender";
  static const String image = "image";
  static const String phone_no = "phone no";
  static const String email = "email";
  static const String subscription_status = "subscription_status";
  static const String auth_token = "authToken";
  static const String is_filled = "is_filled";
  static const String device_token = "device_token";
  static const String notificationPermissionDialog = "notificationPermissionDialog";

  // static const String patientVCall="PatientVCall";
  static const String current_language_code = "current_language_code";
  static const String language_name = "language name ";
  static const String patient_name = "patient_name";
  static const String messageToken = "messageToken";

  //PaymentGateWay
  static const String COD = "COD";
  static const String PayPal = "payPal";
  static const String RazorPay = "RazorPay";
  static const String PayStack = "PayStack";
  static const String Stripe = "Stripe";
  static const String FlutterWave = "FlutterWave";

  //get public and secret key
  static const String stripPublicKey = "publicKey";
  static const String stripeSecretKey = "secretKey";
  static const String razor_key = "razor_key";
  static const String agoraAppId = "agoraAppId";
  static const String flutterWave_key = "flutterWave_key";
  static const String flutterWave_encryption_key = "flutterWave_encryption_key";
  static const String payStack_public_key = "payStack_public_key";
  static const String payPal_sandbox_key = "payPal_sandbox_key";
  static const String payPal_production_key = "payPal_production_key";
  static const String paypal_client_key = "client_key";
  static const String paypal_secret_key = "secret_key";

  static const String doctorAppId = "doctorAppId";
  static const String currency_symbol = "Currency Symbol";
  static const String currency_code = "Currency Code";
  static const String device_platform = "device_platform";

  //Set Hospital Name & Address In Bar
  static const String hospital_name = "hospital_name";
  static const String hospital_address = "hospital_address";

  //update Image Link
  static const String imageLink = "imageLink";

  //Upload pdf
  static String filePath = "";

  static String fileName = "";

  static const String hospitalId = "hospitalId";
  static const String userId = "userId";
  static const String doctorId = "doctorId";

  static const String user_email = "user_email";
  static const String user_name = "user_name";
  static const String password = "password";
  static const String chat_profile = "profile";
}

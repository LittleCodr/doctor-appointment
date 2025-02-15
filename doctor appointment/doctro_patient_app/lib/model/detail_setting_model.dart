class DetailSetting {
  bool? success;
  Data? data;
  String? msg;

  DetailSetting({this.success, this.data, this.msg});

  DetailSetting.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['msg'] = this.msg;
    return data;
  }
}

class Data {
  int? id;
  String? businessName;
  String? email;
  String? phone;
  String? companyWhiteLogo;
  String? companyLogo;
  String? companyFavicon;
  String? currencySymbol;
  String? currencyCode;
  String? color;
  String? websiteColor;
  int? cod;
  int? stripe;
  int? paypal;
  int? razor;
  int? flutterwave;
  int? payStack;
  String? stripePublicKey;
  String? stripeSecretKey;
  String? paypalSandboxKey;
  String? paypalProductionKey;
  String? razorKey;
  String? flutterwaveKey;
  String? flutterwaveEncryptionKey;
  String? payStackPublicKey;
  String? timezone;
  int? defaultCommission;
  int? pharmacyCommission;
  String? defaultBaseOn;
  String? mapKey;
  int? verification;
  int? usingMail;
  int? usingMsg;
  String? twilioAuthToken;
  String? twilioAccId;
  String? twilioPhoneNo;
  String? mailMailer;
  String? mailHost;
  String? mailPort;
  String? mailUsername;
  String? mailPassword;
  String? mailEncryption;
  String? mailFromAddress;
  String? mailFromName;
  String? cancelReason;
  int? radius;
  String? clinicContent;
  String? doctorContent;
  String? footerContent;
  String? doctorMail;
  String? patientMail;
  String? patientNotification;
  String? doctorNotification;
  String? patientAppId;
  String? licenseCode;
  String? clientName;
  int? licenseVerify;
  String? language;
  String? autoCancel;
  dynamic playStore;
  dynamic appstore;
  String? privacyPolicy;
  String? aboutUs;
  String? createdAt;
  String? updatedAt;
  String? companyWhite;
  String? logo;
  String? favicon;
  String? agoraAppId;
  String? agoraAppCertificate;
  int? isLiveKey;
  String? paypalClientId;
  String? paypalSecretKey;

  Data(
      {this.id,
      this.businessName,
      this.email,
      this.phone,
      this.companyWhiteLogo,
      this.companyLogo,
      this.companyFavicon,
      this.currencySymbol,
      this.currencyCode,
      this.color,
      this.websiteColor,
      this.cod,
      this.stripe,
      this.paypal,
      this.razor,
      this.flutterwave,
      this.payStack,
      this.stripePublicKey,
      this.stripeSecretKey,
      this.paypalSandboxKey,
      this.paypalProductionKey,
      this.razorKey,
      this.flutterwaveKey,
      this.flutterwaveEncryptionKey,
      this.payStackPublicKey,
      this.timezone,
      this.defaultCommission,
      this.pharmacyCommission,
      this.defaultBaseOn,
      this.mapKey,
      this.verification,
      this.usingMail,
      this.usingMsg,
      this.twilioAuthToken,
      this.twilioAccId,
      this.twilioPhoneNo,
      this.mailMailer,
      this.mailHost,
      this.mailPort,
      this.mailUsername,
      this.mailPassword,
      this.mailEncryption,
      this.mailFromAddress,
      this.mailFromName,
      this.cancelReason,
      this.radius,
      this.clinicContent,
      this.doctorContent,
      this.footerContent,
      this.doctorMail,
      this.patientMail,
      this.patientNotification,
      this.doctorNotification,
      this.patientAppId,
      this.licenseCode,
      this.clientName,
      this.licenseVerify,
      this.language,
      this.autoCancel,
      this.playStore,
      this.appstore,
      this.privacyPolicy,
      this.aboutUs,
      this.createdAt,
      this.updatedAt,
      this.companyWhite,
      this.logo,
      this.favicon,
      this.agoraAppId,
      this.agoraAppCertificate,
      this.isLiveKey,
      this.paypalClientId,
      this.paypalSecretKey});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    businessName = json['business_name'];
    email = json['email'];
    phone = json['phone'];
    companyWhiteLogo = json['company_white_logo'];
    companyLogo = json['company_logo'];
    companyFavicon = json['company_favicon'];
    currencySymbol = json['currency_symbol'];
    currencyCode = json['currency_code'];
    color = json['color'];
    websiteColor = json['website_color'];
    cod = json['cod'];
    stripe = json['stripe'];
    paypal = json['paypal'];
    razor = json['razor'];
    flutterwave = json['flutterwave'];
    payStack = json['paystack'];
    stripePublicKey = json['stripe_public_key'];
    stripeSecretKey = json['stripe_secret_key'];
    paypalSandboxKey = json['paypal_sandbox_key'];
    paypalProductionKey = json['paypal_producation_key'];
    razorKey = json['razor_key'];
    flutterwaveKey = json['flutterwave_key'];
    flutterwaveEncryptionKey = json['flutterwave_encryption_key'];
    payStackPublicKey = json['paystack_public_key'];
    timezone = json['timezone'];
    defaultCommission = json['default_commission'];
    pharmacyCommission = json['pharmacy_commission'];
    defaultBaseOn = json['default_base_on'];
    mapKey = json['map_key'];
    verification = json['verification'];
    usingMail = json['using_mail'];
    usingMsg = json['using_msg'];
    twilioAuthToken = json['twilio_auth_token'];
    twilioAccId = json['twilio_acc_id'];
    twilioPhoneNo = json['twilio_phone_no'];
    mailMailer = json['mail_mailer'];
    mailHost = json['mail_host'];
    mailPort = json['mail_port'];
    mailUsername = json['mail_username'];
    mailPassword = json['mail_password'];
    mailEncryption = json['mail_encryption'];
    mailFromAddress = json['mail_from_address'];
    mailFromName = json['mail_from_name'];
    cancelReason = json['cancel_reason'];
    radius = json['radius'];
    clinicContent = json['clinic_content'];
    doctorContent = json['doctor_content'];
    footerContent = json['footer_content'];
    doctorMail = json['doctor_mail'];
    patientMail = json['patient_mail'];
    patientNotification = json['patient_notification'];
    doctorNotification = json['doctor_notification'];
    patientAppId = json['patient_app_id'];
    licenseCode = json['license_code'];
    clientName = json['client_name'];
    licenseVerify = json['license_verify'];
    language = json['language'];
    autoCancel = json['auto_cancel'];
    playStore = json['playstore'];
    appstore = json['appstore'];
    privacyPolicy = json['privacy_policy'];
    aboutUs = json['about_us'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    companyWhite = json['companyWhite'];
    logo = json['logo'];
    favicon = json['favicon'];
    agoraAppId = json['agora_app_id'];
    agoraAppCertificate = json['agora_app_certificate'];
    isLiveKey = json['isLiveKey'];
    paypalClientId = json['paypal_client_id'];
    paypalSecretKey = json['paypal_secret_key'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['business_name'] = this.businessName;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['company_white_logo'] = this.companyWhiteLogo;
    data['company_logo'] = this.companyLogo;
    data['company_favicon'] = this.companyFavicon;
    data['currency_symbol'] = this.currencySymbol;
    data['currency_code'] = this.currencyCode;
    data['color'] = this.color;
    data['website_color'] = this.websiteColor;
    data['cod'] = this.cod;
    data['stripe'] = this.stripe;
    data['paypal'] = this.paypal;
    data['razor'] = this.razor;
    data['flutterwave'] = this.flutterwave;
    data['paystack'] = this.payStack;
    data['stripe_public_key'] = this.stripePublicKey;
    data['stripe_secret_key'] = this.stripeSecretKey;
    data['paypal_sandbox_key'] = this.paypalSandboxKey;
    data['paypal_producation_key'] = this.paypalProductionKey;
    data['razor_key'] = this.razorKey;
    data['flutterwave_key'] = this.flutterwaveKey;
    data['flutterwave_encryption_key'] = this.flutterwaveEncryptionKey;
    data['paystack_public_key'] = this.payStackPublicKey;
    data['timezone'] = this.timezone;
    data['default_commission'] = this.defaultCommission;
    data['pharmacy_commission'] = this.pharmacyCommission;
    data['default_base_on'] = this.defaultBaseOn;
    data['map_key'] = this.mapKey;
    data['verification'] = this.verification;
    data['using_mail'] = this.usingMail;
    data['using_msg'] = this.usingMsg;
    data['twilio_auth_token'] = this.twilioAuthToken;
    data['twilio_acc_id'] = this.twilioAccId;
    data['twilio_phone_no'] = this.twilioPhoneNo;
    data['mail_mailer'] = this.mailMailer;
    data['mail_host'] = this.mailHost;
    data['mail_port'] = this.mailPort;
    data['mail_username'] = this.mailUsername;
    data['mail_password'] = this.mailPassword;
    data['mail_encryption'] = this.mailEncryption;
    data['mail_from_address'] = this.mailFromAddress;
    data['mail_from_name'] = this.mailFromName;
    data['cancel_reason'] = this.cancelReason;
    data['radius'] = this.radius;
    data['clinic_content'] = this.clinicContent;
    data['doctor_content'] = this.doctorContent;
    data['footer_content'] = this.footerContent;
    data['doctor_mail'] = this.doctorMail;
    data['patient_mail'] = this.patientMail;
    data['patient_notification'] = this.patientNotification;
    data['doctor_notification'] = this.doctorNotification;
    data['patient_app_id'] = this.patientAppId;
    data['license_code'] = this.licenseCode;
    data['client_name'] = this.clientName;
    data['license_verify'] = this.licenseVerify;
    data['language'] = this.language;
    data['auto_cancel'] = this.autoCancel;
    data['playstore'] = this.playStore;
    data['appstore'] = this.appstore;
    data['privacy_policy'] = this.privacyPolicy;
    data['about_us'] = this.aboutUs;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['companyWhite'] = this.companyWhite;
    data['logo'] = this.logo;
    data['favicon'] = this.favicon;
    data['agora_app_id'] = this.agoraAppId;
    data['agora_app_certificate'] = this.agoraAppCertificate;
    data['isLiveKey'] = this.isLiveKey;
    data['paypal_client_id'] = this.paypalClientId;
    data['paypal_secret_key'] = this.paypalSecretKey;
    return data;
  }
}

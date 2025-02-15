class Setting {
  bool? success;
  Data? data;
  String? msg;

  Setting({this.success, this.data, this.msg});

  Setting.fromJson(Map<String, dynamic> json) {
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
  int? paystack;
  String? stripePublicKey;
  String? stripeSecretKey;
  String? paypalSandboxKey;
  String? paypalProducationKey;
  String? razorKey;
  String? flutterwaveKey;
  String? paystackPublicKey;
  String? timezone;
  int? defaultCommission;
  int? pharamacyCommission;
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
  String? createdAt;
  String? updatedAt;
  String? companyWhite;
  String? logo;
  String? favicon;

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
      this.paystack,
      this.stripePublicKey,
      this.stripeSecretKey,
      this.paypalSandboxKey,
      this.paypalProducationKey,
      this.razorKey,
      this.flutterwaveKey,
      this.paystackPublicKey,
      this.timezone,
      this.defaultCommission,
      this.pharamacyCommission,
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
      this.createdAt,
      this.updatedAt,
      this.companyWhite,
      this.logo,
      this.favicon});

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
    paystack = json['paystack'];
    stripePublicKey = json['stripe_public_key'];
    stripeSecretKey = json['stripe_secret_key'];
    paypalSandboxKey = json['paypal_sandbox_key'];
    paypalProducationKey = json['paypal_producation_key'];
    razorKey = json['razor_key'];
    flutterwaveKey = json['flutterwave_key'];
    paystackPublicKey = json['paystack_public_key'];
    timezone = json['timezone'];
    defaultCommission = json['default_commission'];
    pharamacyCommission = json['pharamacy_commission'];
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
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    companyWhite = json['companyWhite'];
    logo = json['logo'];
    favicon = json['favicon'];
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
    data['paystack'] = this.paystack;
    data['stripe_public_key'] = this.stripePublicKey;
    data['stripe_secret_key'] = this.stripeSecretKey;
    data['paypal_sandbox_key'] = this.paypalSandboxKey;
    data['paypal_producation_key'] = this.paypalProducationKey;
    data['razor_key'] = this.razorKey;
    data['flutterwave_key'] = this.flutterwaveKey;
    data['paystack_public_key'] = this.paystackPublicKey;
    data['timezone'] = this.timezone;
    data['default_commission'] = this.defaultCommission;
    data['pharamacy_commission'] = this.pharamacyCommission;
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
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['companyWhite'] = this.companyWhite;
    data['logo'] = this.logo;
    data['favicon'] = this.favicon;
    return data;
  }
}

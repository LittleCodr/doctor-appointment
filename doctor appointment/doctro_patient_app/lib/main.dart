import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctro_patient/Screen/Location/AddLocation.dart';
import 'package:doctro_patient/Screen/Location/AddToCart.dart';
import 'package:doctro_patient/Screen/MedicineAndPharmacy/AllPharamacy.dart';
import 'package:doctro_patient/Screen/AppointmentRelatedScreen/Book_success.dart';
import 'package:doctro_patient/Screen/AppointmentRelatedScreen/BookAppointment.dart';
import 'package:doctro_patient/Screen/Doctor/FavoriteDoctor.dart';
import 'package:doctro_patient/FirebaseProviders/auth_provider.dart';
import 'package:doctro_patient/FirebaseProviders/chat_provider.dart';
import 'package:doctro_patient/FirebaseProviders/home_provider.dart';
import 'package:doctro_patient/FirebaseProviders/setting_provider.dart';
import 'package:doctro_patient/Screen/MedicineAndPharmacy/HealthTips.dart';
import 'package:doctro_patient/Screen/MedicineAndPharmacy/HealthTipsDetail.dart';
import 'package:doctro_patient/Screen/MedicineAndPharmacy/MedicineDescription.dart';
import 'package:doctro_patient/Screen/MedicineAndPharmacy/PharamacyDetail.dart';
import 'package:doctro_patient/Screen/AppointmentRelatedScreen/Review_Appointment.dart';
import 'package:doctro_patient/Screen/Authentication/SignIn.dart';
import 'package:doctro_patient/Screen/Doctor/Specialist.dart';
import 'package:doctro_patient/Screen/Doctor/Treatment.dart';
import 'package:doctro_patient/Screen/Doctor/TreatmentSpecialist.dart';
import 'package:doctro_patient/const/preference.dart';
import 'package:doctro_patient/Screen/Doctor/doctorDetail.dart';
import 'package:doctro_patient/Screen/Authentication/forgotPassword.dart';
import 'package:doctro_patient/Screen/Location/ShowLocation.dart';
import 'package:doctro_patient/Screen/Authentication/phoneVerification.dart';
import 'package:doctro_patient/Screen/MedicineAndPharmacy/MyPrescription.dart';
import 'package:doctro_patient/Screen/AppointmentRelatedScreen/Appointment.dart';
import 'package:doctro_patient/Screen/Setting/ChangeLanguage.dart';
import 'package:doctro_patient/VideoCall/videoCallHistory.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:doctro_patient/Screen/MedicineAndPharmacy/MedicineOrder.dart';
import 'package:doctro_patient/Screen/MedicineAndPharmacy/MedicineOrderDetail.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Screen/Authentication/signup.dart';
import 'Screen/AppointmentRelatedScreen/appointment_stripe_service.dart';
import 'Screen/Payment/MedicinePayment.dart';
import 'Screen/Payment/StripePaymentScreen.dart';
import 'Screen/Payment/StripePaymentScreenMedicine.dart';
import 'Screen/Payment/medicines_stripe_services.dart';
import 'Screen/Screens/Home.dart';
import 'Screen/Screens/Offer.dart';
import 'Screen/Screens/Setting.dart';
import 'Screen/Screens/notifications.dart';
import 'Screen/Screens/profile.dart';
import 'Screen/Setting/AboutUs.dart';
import 'Chat/chatPage.dart';
import 'Screen/Setting/ChangePassword.dart';
import 'Screen/Setting/PrivacyPolicy.dart';
import 'VideoCall/overlay_handler.dart';
import 'api/retrofit_Api.dart';
import 'api/base_model.dart';
import 'api/network_api.dart';
import 'api/server_error.dart';
import 'const/Palette.dart';
import 'const/prefConstatnt.dart';
import 'localization/language_localization.dart';
import 'localization/localization_constant.dart';
import 'model/detail_setting_model.dart';
import 'package:doctro_patient/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform);
  await SharedPreferenceHelper.init();
  await FirebaseMessaging.instance.subscribeToTopic("all");
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  HttpOverrides.global = new MyHttpOverrides();
  runApp(MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    importance: Importance.high,
    showBadge: true,
    playSound: true,
    enableVibration: true);

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>()!;
    state.setLocale(newLocale);
  }
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;
  String? deviceToken = "";

  late SharedPreferences _prefs;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  String msgId = "";
  String msgName = "";
  String msgImage = "";
  String doctorToken = "";

  String token = "";
  bool? router;

  @override
  void initState() {
    super.initState();
    setState(() {
      callApiSetting();
      init();
      Future.delayed(const Duration(seconds: 2), () {
        FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
          if (message != null) {
            Map<String, dynamic> dataValue = message.data;
            msgImage = dataValue['doctorImage'].toString();
            msgName = dataValue['doctorName'].toString();
            msgId = dataValue['doctorId'].toString();
            doctorToken = dataValue['doctorToken'].toString();
            print("message not null");
            if (SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true) {
              Navigator.of(navigatorKey.currentState!.context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    peerId: msgId,
                    peerAvatar: msgImage,
                    peerNickname: msgName,
                    doctorToken: doctorToken,
                    where: "",
                  ),
                ),
              );
            } else {
              Navigator.of(navigatorKey.currentState!.context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => SignIn(),
                ),
              );
            }
          }
        });
      });

      /// Get Notification ///
      var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
      var initializationSettingsIOS = new DarwinInitializationSettings();
      var initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
      flutterLocalNotificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: onSelectNotification);
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;
        Map<String, dynamic> dataValue = message.data;
        String screen = dataValue['screen'].toString();
        msgImage = dataValue['doctorImage'].toString();
        msgName = dataValue['doctorName'].toString();
        msgId = dataValue['doctorId'].toString();
        doctorToken = dataValue['doctorToken'].toString();

        print("Screen: " + screen);
        if (notification != null && android != null) {
          flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              notification.title,
              notification.body,
              NotificationDetails(
                android: AndroidNotificationDetails(
                  channel.id,
                  channel.name,
                  icon: "@mipmap/ic_launcher",
                ),
              ),
              payload: screen);
        }
      });
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;
        if (notification != null && android != null) {
          Navigator.of(navigatorKey.currentState!.context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => ChatPage(
                peerId: msgId,
                peerAvatar: msgImage,
                peerNickname: msgName,
                doctorToken: doctorToken,
                where: "",
              ),
            ),
          );
        }
      });
      getToken();
    });
  }

  onSelectNotification(payload) {
    if (payload.payload == "screen") {
      if (msgId.isNotEmpty && msgName.isNotEmpty && msgImage.isNotEmpty && SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true) {
        Navigator.of(navigatorKey.currentState!.context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ChatPage(
              peerId: msgId,
              peerAvatar: msgImage,
              peerNickname: msgName,
              doctorToken: doctorToken,
              where: "",
            ),
          ),
        );
      }
    }
  }

  getToken() async {
    token = (await FirebaseMessaging.instance.getToken())!;
    if (token.isNotEmpty) {
      print("Notification Token:" + token);
      SharedPreferenceHelper.setString(Preferences.notificationRegisterKey, token);
    }
  }

  Future<SharedPreferences?> init() async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs;
  }

  @override
  void didChangeDependencies() {
    getLocale().then((local) => {
          setState(() {
            this._locale = local;
          })
        });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
    if (_locale == null) {
      return Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Theme.of(context).brightness == Brightness.light ? Colors.white : Colors.black,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider<StripePayment>(
              create: (context) => StripePayment(),
            ),
            ChangeNotifierProvider<MedicinesStripePayment>(
              create: (context) => MedicinesStripePayment(),
            ),
            ChangeNotifierProvider<AuthProvider>(
              create: (_) => AuthProvider(
                firebaseAuth: FirebaseAuth.instance,
                googleSignIn: GoogleSignIn(),
                prefs: this._prefs,
                firebaseFirestore: this.firebaseFirestore,
              ),
            ),
            Provider<SettingProvider>(
              create: (_) => SettingProvider(
                prefs: this._prefs,
                firebaseFirestore: this.firebaseFirestore,
                firebaseStorage: this.firebaseStorage,
              ),
            ),
            Provider<HomeProvider>(
              create: (_) => HomeProvider(
                firebaseFirestore: this.firebaseFirestore,
              ),
            ),
            Provider<ChatProvider>(
              create: (_) => ChatProvider(
                prefs: this._prefs,
                firebaseFirestore: this.firebaseFirestore,
                firebaseStorage: this.firebaseStorage,
              ),
            ),
          ],
          child: ChangeNotifierProvider<OverlayHandlerProvider>(
            create: (_) => OverlayHandlerProvider(),
            child: MaterialApp(
              navigatorKey: navigatorKey,
              title: 'Patient',
              locale: _locale,
              supportedLocales: [
                Locale(ENGLISH, 'US'),
                Locale(SPANISH, 'ES'),
                Locale(ARABIC, 'AE'),
              ],
              localizationsDelegates: [
                LanguageLocalization.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              localeResolutionCallback: (deviceLocal, supportedLocales) {
                for (var local in supportedLocales) {
                  if (local.languageCode == deviceLocal!.languageCode && local.countryCode == deviceLocal.countryCode) {
                    return deviceLocal;
                  }
                }
                return supportedLocales.first;
              },
              debugShowCheckedModeBanner: false,
              initialRoute: "/",
              theme: ThemeData(
                splashColor: Palette.transparent,
                highlightColor: Palette.transparent,
                primaryColor: Palette.blue,
                useMaterial3: false,
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:  Palette.blue
                  )
                )
              ),
              routes: {
                '/': (context) => Home(),
                'SignIn': (context) => SignIn(),
                'SignUp': (context) => SignUp(),
                'ForgotPasswordScreen': (context) => ForgotPasswordScreen(),
                'PhoneVerification': (context) => PhoneVerification(),
                'Home': (context) => Home(),
                'Treatment': (context) => Treatment(),
                'FavoriteDoctorScreen': (context) => FavoriteDoctorScreen(),
                'Specialist': (context) => Specialist(),
                'DoctorDetail': (context) => DoctorDetail(),
                'BookAppointment': (context) => BookAppointment(),
                'Appointment': (context) => Appointment(),
                'Myprescription': (context) => MyPrescription(),
                'HealthTips': (context) => HealthTips(),
                'HealthTipsDetail': (context) => HealthTipsDetail(),
                'Setting': (context) => Setting(),
                'AddToCart': (context) => AddToCart(),
                'Offer': (context) => Offer(),
                'Profile': (context) => Profile(),
                'ShowLocation': (context) => ShowLocation(),
                'AddLocation': (context) => AddLocation(),
                'BookSuccess': (context) => BookSuccess(),
                'Review': (context) => Review(),
                'MedicineDescription': (context) => MedicineDescription(),
                'AllPharamacy': (context) => AllPharamacy(),
                'PharamacyDetail': (context) => PharamacyDetail(),
                'MedicinePayment': (context) => MedicinePayment(),
                'MedicineOrder': (context) => MedicineOrder(),
                'MedicineOrderDetail': (context) => MedicineOrderDetail(),
                'TreatmentSpecialist': (context) => TreatmentSpecialist(),
                'Notifications': (context) => Notifications(),
                'StripePaymentScreen': (context) => StripePaymentScreen(),
                'StripePaymentScreenMedicine': (context) => StripePaymentScreenMedicine(),
                'ChangePassword': (context) => ChangePassword(),
                'PrivacyPolicy': (context) => PrivacyPolicy(),
                'AboutUs': (context) => AboutUs(),
                'ChangeLanguage': (context) => ChangeLanguage(),
                'VideoCallHistory': (context) => VideoCallHistory(),
              },
            ),
          ),
        ),
      );
    }
  }

  Future<BaseModel<DetailSetting>> callApiSetting() async {
    DetailSetting response;
    try {
      response = await RestClient(RetroApi2().dioData2()).settingRequest();
      setState(() {
        if (response.success == true) {
          SharedPreferenceHelper.setString(Preferences.patientAppId, response.data!.patientAppId!);
          if (response.data!.patientAppId != null) {
            getOneSignalToken(SharedPreferenceHelper.getString(Preferences.patientAppId));
          }
        }
      });
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  ///one signal
  getOneSignalToken(appId) async {
    OneSignal.Debug.setLogLevel(OSLogLevel.info);

    OneSignal.initialize(appId);
    if (kDebugMode) {
      print("OneSignal App ID: " + appId);
    }
    OneSignal.Notifications.addPermissionObserver((state) {
      print("Has permission " + state.toString());
    });
    print("Permission ${OneSignal.Notifications.permission}");
    Platform.isIOS
        ? OneSignal.Notifications.permission == false &&
                SharedPreferenceHelper.getBoolean(Preferences.notificationPermissionDialog) == false
            ? OneSignal.Notifications.requestPermission(true)
            : null
        : null;
    Platform.isAndroid ? OneSignal.Notifications.requestPermission(true) : null;
    if (kDebugMode) {
      print("OneSignal ID : ${OneSignal.User.pushSubscription.id}");
      print("OneSignal Token : ${OneSignal.User.pushSubscription.token}");
    }
    OneSignal.Debug.setAlertLevel(OSLogLevel.none);

    if (OneSignal.User.pushSubscription.id != null) {
      SharedPreferenceHelper.setString(Preferences.device_token, OneSignal.User.pushSubscription.id.toString());
    }

    if (SharedPreferenceHelper.getString(Preferences.device_token) != 'N_A') {
      SharedPreferenceHelper.getString(Preferences.device_token);
    } else {
      getOneSignalToken(appId);
    }
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

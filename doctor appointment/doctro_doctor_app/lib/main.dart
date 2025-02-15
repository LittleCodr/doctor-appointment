import'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctro/localization/language_localization.dart';
import 'package:doctro/model/setting.dart';
import 'package:doctro/retrofit/api_header.dart';
import 'package:doctro/retrofit/server_error.dart';
import 'package:doctro/screens/setting/ChangePassword.dart';
import 'package:doctro/screens/setting/Setting.dart';
import 'package:doctro/screens/auth/SignIn.dart';
import 'package:doctro/screens/notification/ViewAllNotification.dart';
import 'package:doctro/screens/setting/changeLanguage.dart';
import 'package:doctro/screens/auth/forgotpassword.dart';
import 'package:doctro/screens/videoCall/videocallhistory.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:doctro/retrofit/base_model.dart';
import 'package:doctro/retrofit/network_api.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'VideoCall/overlay_handler.dart';
import 'chat/pages/home_page.dart';
import 'chat/providers/auth_provider.dart' as provider;
import 'chat/providers/chat_provider.dart';
import 'chat/providers/home_provider.dart';
import 'constant/prefConstatnt.dart';
import 'localization/localization_constant.dart';
import 'screens/auth/signup.dart';
import 'screens/auth/phoneverification.dart';
import 'screens/home page/login_home.dart';
import 'screens/home page/patient_information.dart';
import 'screens/appointment/cancel_appointment.dart';
import 'screens/appointment/appointment_history.dart';
import 'screens/review/rate&review.dart';
import 'screens/notification/notifications.dart';
import 'screens/profile/profile.dart';
import 'screens/paymentScreen/payment.dart';
import 'package:doctro/constant/preferences.dart';
import 'package:doctro/screens/subscription/Subscription.dart';
import 'package:doctro/screens/paymentScreen/PaymentGateway.dart';
import 'package:doctro/screens/subscription/SubscriptionHistory.dart';
import 'package:doctro/screens/schedule/ScheduleTimings.dart';
import 'package:doctro/screens/paymentScreen/StripePayment.dart';
import 'package:doctro/firebase_options.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  await SharedPreferenceHelper.init();
  HttpOverrides.global = new MyHttpOverrides();
  await FirebaseMessaging.instance.subscribeToTopic("all");
  if(Platform.isAndroid){
    SharedPreferenceHelper.setString(Preferences.device_platform, "Android");
  }

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
    enableVibration: true
);

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
class MyApp extends StatefulWidget {

  _MyAppState createState() => _MyAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>()!;
    state.setLocale(newLocale);
  }

}

class _MyAppState extends State<MyApp> {

  late SharedPreferences _prefs;

  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  get skip => null;

  Locale? _locale;
  String messageImage = '';
  String messageName = '';
  String messageId = '';
  String userToken = '';

  void initState() {
    super.initState();
    init();
    settingRequest();
    getToken();
  }

  getToken() async {
   String token = (await FirebaseMessaging.instance.getToken())!;
    if (token.isNotEmpty) {
      print("Firebase Token : "+token);
      SharedPreferenceHelper.setString(Preferences.messageToken, token);
    }
  }

  Future<BaseModel<Setting>> settingRequest() async {

    Setting response;

    try {
      response = await RestClient(RetroApi().dioData()).settingRequest();

      if( SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true){

          if(response.data!.stripeSecretKey != null){
            SharedPreferenceHelper.setString(Preferences.stripeSecretKey, response.data!.stripeSecretKey!);
          }

          if(response.data!.stripePublicKey != null){
            SharedPreferenceHelper.setString(Preferences.stripPublicKey, response.data!.stripePublicKey!);
          }

          if(response.data!.flutterwaveEncryptionKey != null){
            SharedPreferenceHelper.setString(Preferences.flutterWave_encryption_key, response.data!.flutterwaveEncryptionKey!);
          }

          if(response.data!.flutterwaveKey != null){
            SharedPreferenceHelper.setString(Preferences.flutterWave_key, response.data!.flutterwaveKey!);
          }

          if(response.data!.paystackPublicKey != null){
            SharedPreferenceHelper.setString(Preferences.payStack_public_key, response.data!.paystackPublicKey!);
          }

          if(response.data!.razorKey != null){
            SharedPreferenceHelper.setString(Preferences.razor_key, response.data!.razorKey!);
          }

          if(response.data!.paypalProducationKey != null){
            SharedPreferenceHelper.setString(Preferences.payPal_production_key,response.data!.paypalProducationKey!);
          }

          if(response.data!.paypalSandboxKey != null){
            SharedPreferenceHelper.setString(Preferences.payPal_sandbox_key, response.data!.paypalSandboxKey!);
          }

          if(response.data!.paypalClientId != null){
            SharedPreferenceHelper.setString(Preferences.paypal_client_key, response.data!.paypalClientId!);
          }

          if(response.data!.paypalSecretKey != null){
            SharedPreferenceHelper.setString(Preferences.paypal_secret_key, response.data!.paypalSecretKey!);
          }

          if(response.data!.currencySymbol != null){
            SharedPreferenceHelper.setString(Preferences.currency_symbol, response.data!.currencySymbol!);
          }

          if(response.data!.currencyCode != null){
            SharedPreferenceHelper.setString(Preferences.currency_code, response.data!.currencyCode!);
          }

          if(response.data!.doctorAppId != null){
            SharedPreferenceHelper.setString(Preferences.doctorAppId, response.data!.doctorAppId!);
          }

      } else {

        if(response.data!.currencySymbol != null){
          SharedPreferenceHelper.setString(Preferences.currency_symbol, response.data!.currencySymbol!);
        }

        if(response.data!.currencyCode != null){
          SharedPreferenceHelper.setString(Preferences.currency_code, response.data!.currencyCode!);
        }

        if(response.data!.doctorAppId != null){
          setState(() {
            SharedPreferenceHelper.setString(Preferences.doctorAppId, response.data!.doctorAppId!);
          });
        }

        if(response.data!.doctorAppId != null){

          setState(() {
            getOneSingleToken(SharedPreferenceHelper.getString(Preferences.doctorAppId));
          });

        }
      }
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  getOneSingleToken(appId) async {
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
      getOneSingleToken(appId);
    }
  }

  Future<SharedPreferences?> init() async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs;
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  void didChangeDependencies() {
    getLocale().then((local) => {
      setState(() {
        this._locale = local;
      })
    });
    super.didChangeDependencies();
  }

  Widget build(BuildContext context) {

    if (_locale == null) {
      return Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    else {

      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: ChangeNotifierProvider<OverlayHandlerProvider>(
          create: (_) => OverlayHandlerProvider(),
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider<provider.AuthProvider>(
                create: (_) => provider.AuthProvider(
                  firebaseAuth: FirebaseAuth.instance,
                  prefs: _prefs,
                  firebaseFirestore: this.firebaseFirestore,
                ),
              ),
              Provider<HomeProvider>(
                create: (_) => HomeProvider(
                  firebaseFirestore: this.firebaseFirestore,
                ),
              ),
              Provider<ChatProvider>(
                create: (_) => ChatProvider(
                  prefs: _prefs,
                  firebaseFirestore: this.firebaseFirestore,
                  firebaseStorage: this.firebaseStorage,
                ),
              ),
            ],
            child: MaterialApp(
              navigatorKey: navigatorKey,
              title: "Doctor",
              debugShowCheckedModeBanner: false,
              home: LoginHomeScreen(chat: ""),
              locale: _locale,
              supportedLocales: [
                Locale(ENGLISH, 'US'),
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
                  if (local.languageCode == deviceLocal!.languageCode &&
                      local.countryCode == deviceLocal.countryCode) {
                    return deviceLocal;
                  }
                }
                return supportedLocales.first;
              },
              initialRoute: SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true
                  ? 'loginHome'
                  : 'SignIn',
              theme: ThemeData(useMaterial3: false,),
              routes: {
                'SignIn': (context) => SignIn(),
                'signup': (context) => CreateAccount(),
                'ForgotPasswordScreen': (context) => ForgotPasswordScreen(),
                'phoneverification': (context) => PhoneVerificationScreen(),
                'loginHome': (context) => LoginHomeScreen(chat: ""),
                'patientInformation': (context) => patientDetailsScreen(),
                'cancelAppoitmentRoutes': (context) => CancelAppointmentScreen(),
                'AppointmentHistoryScreen': (context) => AppointmentHistoryScreen(),
                'rateAndReviewRoutes': (context) => RateAndReviewRoutesScreen(),
                'notifications': (context) => NotificationsScreen(),
                'profile': (context) => ProfileScreen(),
                'payment': (context) => PaymentScreen(),
                'subscription': (context) => SubSubscription(),
                'paymentGatewayRoutes': (context) => PaymentGatewayScreen(),
                'Subscription History': (context) => SubscriptionHistory(),
                'Schedule Timings': (context) => ScheduleTimings(),
                'Change Password': (context) => ChangePassword(),
                'Change Language': (context) => ChangeLanguage(),
                'ViewAllNotification': (context) => ViewAllNotification(),
                'Stripe' :(context) => Stripe(),
                'VideoCallHistory' :(context) => VideoCallHistory(),
                'Settings' : (context) => SettingScreen(),
                'ChatHome' : (context) => HomePage(),
              },
            ),
          ),
        ),
      );
    }
  }
}
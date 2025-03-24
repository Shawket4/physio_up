// ignore_for_file: unused_local_variable, non_constant_identifier_names, constant_identifier_names, unused_import, deprecated_member_use
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:phsyio_up/components/dio_helper.dart';
import 'package:phsyio_up/firebase_options.dart';
import 'package:phsyio_up/models/user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:material_color_generator/material_color_generator.dart';
import 'package:phsyio_up/screens/whatsapp_qr/Ui/whatsappqrcode.dart';
import 'package:phsyio_up/screens/appointment_request/Ui/appointment_requests.dart';
import 'package:phsyio_up/screens/login/Ui/login_screen.dart';
import 'package:phsyio_up/router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'dart:convert';

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

 const String ServerIP = "https://physioup.ddns.net:3005";

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && !Platform.isMacOS && !Platform.isWindows) {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Initialize FlutterLocalNotificationsPlugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = 
    FlutterLocalNotificationsPlugin();
     const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    
  final DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings();
    
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse details) async {
      // Handle notification tap here
      print('Notification clicked: ${details.payload}');
    },
  );

  }
  
  // Set background message handler
  
    
 
  initDio();
  runApp(const MainWidget());
}

bool isWhatsappLoggedIn = false;


final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
late String jwt;
User userInfo = User();
Future<bool> isConnected() async {
  try {
    final response = await Dio().get('https://www.google.com');
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}

Future<void> _checkWhatsAppLogin() async {
  try {
     dynamic whatsappLogin = await getData("$ServerIP/api/protected/CheckWhatsAppLogin");
    print(whatsappLogin.toString());
    if (whatsappLogin["message"] == "Logged In") {
      isWhatsappLoggedIn = true;
    }
  } catch (e) {

  }
}


Future<String> get _getJwt async {
  
  // bool isOnline = await isConnected();
  // if (!isOnline) {
  //   return "Offline";
  // }
  // Dio dio = Dio();
  // try {
  // } catch (e) {
  //   print("No Internet");
  // }

  final SharedPreferences prefs = await _prefs;
  
  // await prefs.remove("jwt");
  jwt = (prefs.getString('jwt') ?? "");

  dio.options.headers["Authorization"] = "Bearer $jwt";
  // print(jwt);
  try {
    var response = await getData("$ServerIP/api/protected/user");
    userInfo.username = response["data"]["username"];
    userInfo.ID = response["data"]["ID"];
    userInfo.permission = response["data"]["permission"];
    userInfo.clinicName = response["data"]["clinic_name"];
    //userInfo.clinic_group_id = response["data"]["clinic_group_id"];
     if (!kIsWeb && !Platform.isMacOS && !Platform.isWindows) {
        FirebaseMessaging.instance.getToken().then((token) {
          print(token);
          postData(
              "$ServerIP/api/protected/SaveFCM",
              {
                "token": token,
              },);
        });
      }
    await _checkWhatsAppLogin();
  } catch (e) {
    print(e);
    Logout;
    jwt = "";
    return jwt;
  }
  return jwt;
}

Future<bool> SetJwt(String jwt) async {
  final SharedPreferences prefs = await _prefs;
  final bool status = await (prefs.setString('jwt', jwt));
  return status;
}

Future<bool> SetJSON(dynamic input, String key) async {
  final SharedPreferences prefs = await _prefs;
  final bool status = await (prefs.setString(key, json.encode(input)));
  return status;
}

Future<dynamic> GetJSON(String key) async {
  final SharedPreferences prefs = await _prefs;
  // await prefs.remove("jwt");
  dynamic output = (prefs.getString(key) ?? "");
  return output;
}


Future<bool> Logout(BuildContext context) async {
  if (!kIsWeb && !Platform.isMacOS && !Platform.isWindows) {
    // await FirebaseMessaging.instance.getToken().timeout(Duration(seconds: 3)).then((token) async {
    //   await postData(
    //       "$ServerIP/api/protected/UnlinkDeviceToken",
    //       {
    //         "token": token,
    //       },
    //       context);
    // });
  }
  final SharedPreferences prefs = await _prefs;
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
  return await prefs.remove("jwt");
}

class MainWidget extends StatefulWidget {
  const MainWidget({Key? key}) : super(key: key);
  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_MainWidgetState>()!.restartApp();
  }

  @override
  State<MainWidget> createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = 
    FlutterLocalNotificationsPlugin();
void setupNotificationChannels() async {
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.high,
      );

      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  @override
  void initState() {
    setupNotificationChannels();
    setupPushNotifications();
    super.initState();
  }

  void setupPushNotifications() async {
    // Request permission (iOS and some Android versions need this)
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    
    print('User granted permission: ${settings.authorizationStatus}');
    
    // Get the token
    String? token = await FirebaseMessaging.instance.getToken();
    print('FCM Token: $token');
    
    // Save this token to your server to send targeted notifications
    
    // Configure foreground notification handling
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    
    // Handle notifications when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              channelDescription: 'This channel is used for important notifications.',
              importance: Importance.high,
              priority: Priority.high,
              ticker: 'ticker',
            ),
            iOS: DarwinNotificationDetails(),
          ),
          payload: message.data['route'],
        );
      }
    });
    
    // Handle notification click when app is in background but open
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      // Navigate based on the data in the notification
      if (message.data['route'] != null) {
        // Navigate to specific route
        Navigator.of(context).pushNamed(message.data['route']);
      }
    });
    
    // Check if app was opened from a notification
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print('App opened from terminated state via notification');
      // Handle navigation based on the notification data
      if (initialMessage.data['route'] != null) {
        // Delay navigation to ensure app is fully initialized
        Future.delayed(Duration(seconds: 1), () {
          Navigator.of(context).pushNamed(initialMessage.data['route']);
        });
      }
    }
  }

  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: MaterialApp(
        title: "Physio-Up",
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFFF2F5F9),
          useMaterial3: false,
          fontFamily: "Inter",
          primaryColor: const Color(0xFF0b132b),
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: const Color(0xFF0b132b),
            secondary: const Color(0xFF011627),
          ),
          primarySwatch: generateMaterialColor(
            color: const Color(0xFF0b132b),
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: FutureBuilder(
            future: _getJwt,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Scaffold(
                  body: Center(
                    child: Lottie.asset(
                      "assets/lottie/Loading.json",
                      height: 200,
                      width: 200,
                    ),
                  ),
                );
              } else if (snapshot.data != "Offline") {
                if (jwt != "") {
                  if (isWhatsappLoggedIn) {
                    return RouterWidget();
                  }
                   return WhatsAppQRCode();
                } else {
                    return const LoginPage();
                }
              } else {
                return const RouterWidget();
              }
            }),
      ),
    );
  }
}

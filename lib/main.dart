// ignore_for_file: unused_local_variable, non_constant_identifier_names, constant_identifier_names, unused_import
import 'dart:io';

import 'package:phsyio_up/dio_helper.dart';
import 'package:phsyio_up/models/user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:material_color_generator/material_color_generator.dart';
import 'package:phsyio_up/screens/whatsappqrcode.dart';
import 'package:phsyio_up/screens/appointment_request/appointment_requests.dart';
import 'package:phsyio_up/screens/login/login_screen.dart';
import 'package:phsyio_up/secretary/router.dart';
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

// const String ServerIP = "https://dentex.app";
const String ServerIP = "https://physioup.ddns.net:3005";
// const String ServerIP = "http://localhost:3005";



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initDio();
  runApp(const MainWidget());
}


dynamic whatsappLogin;
dynamic qrCodeBytes;

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
    whatsappLogin = await getData("$ServerIP/api/protected/CheckWhatsAppLogin");
    print(whatsappLogin.toString());
    if (whatsappLogin["message"] != "Logged In") {
      print("object");
      qrCodeBytes = await getDataAsBytes("$ServerIP/api/protected/GetWhatsAppQRCode");
    }
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
  @override
  void initState() {
    super.initState();
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
                  if (whatsappLogin["message"] == "Logged In") {
                    return RouterWidget();
                  }
                   return WhatsAppQRCode(qrCodeBytes: qrCodeBytes);
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

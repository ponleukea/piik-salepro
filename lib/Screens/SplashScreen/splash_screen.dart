import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pos/Screens/SplashScreen/on_board.dart';
import 'package:mobile_pos/constant.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:permission_handler/permission_handler.dart';

import '../Authentication/phone.dart';
import '../Home/home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String newUpdateVersion = '1.1';

  bool isUpdateAvailable = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  void showSnack(String text) {
    if (_scaffoldKey.currentContext != null) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(SnackBar(content: Text(text)));
    }
  }

  void getPermission() async {
    // ignore: unused_local_variable
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();
  }

  final CurrentUserData currentUserData = CurrentUserData();

  // Future<void> getSubUserData() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   isSubUser = prefs.getBool('isSubUser') ?? false;
  //   isSubUser ? currentUserData.getUserData() : null;
  // }

  @override
  void initState() {
    super.initState();
    init();
    getPermission();
    currentUserData.getUserData();
  }

  var currentUser = FirebaseAuth.instance.currentUser;
  // bool isis = FirebaseAuth.instance.currentUser

  void init() async {
    final prefs = await SharedPreferences.getInstance();
    isPrintEnable = prefs.getBool('isPrintEnable') ?? true;
    final String? skipVersion = prefs.getString('skipVersion');
    await Future.delayed(const Duration(seconds: 2), () {
      if (isUpdateAvailable && (skipVersion == null || skipVersion != newUpdateVersion)) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Padding(
              padding: const EdgeInsets.all(30.0),
              child: Center(
                child: Container(
                  height: MediaQuery.of(context).size.height / 2,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 20, bottom: 10),
                              child: Text(
                                'A new update available\n\n'
                                'Please update your app',
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: GestureDetector(
                                onTap: () async {
                                  await prefs.remove('skipVersion');
                                },
                                child: Container(
                                  height: 50,
                                  decoration: const BoxDecoration(
                                    color: kMainColor,
                                    borderRadius: BorderRadius.all(Radius.circular(20)),
                                  ),
                                  child: const Center(
                                      child: Text(
                                    'Update Now',
                                    style: TextStyle(color: Colors.white),
                                  )),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: GestureDetector(
                                onTap: () async {
                                  await prefs.setBool('isSkipUpdate', false);
                                  await prefs.setString('skipVersion', newUpdateVersion);

                                  if (currentUser != null) {
                                    // ignore: use_build_context_synchronously
                                    const Home().launch(context);
                                  } else {
                                    // ignore: use_build_context_synchronously
                                    const OnBoard().launch(context);
                                  }
                                },
                                child: Container(
                                  height: 50,
                                  decoration: const BoxDecoration(
                                    color: kMainColor,
                                    borderRadius: BorderRadius.all(Radius.circular(20)),
                                  ),
                                  child: const Center(
                                      child: Text(
                                    'Skip this update',
                                    style: TextStyle(color: Colors.white),
                                  )),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: GestureDetector(
                                onTap: () {
                                  if (currentUser != null) {
                                    const Home().launch(context);
                                  } else {
                                    const OnBoard().launch(context);
                                  }
                                },
                                child: Container(
                                  height: 50,
                                  decoration: const BoxDecoration(
                                    color: kMainColor,
                                    borderRadius: BorderRadius.all(Radius.circular(20)),
                                  ),
                                  child: const Center(
                                      child: Text(
                                    'Remember me later',
                                    style: TextStyle(color: Colors.white),
                                  )),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
        // const RedeemConfirmationScreen().launch(context);
      } else {
        if (currentUser != null) {
          const Home().launch(context);
        } else {
          ///const OnBoard().launch(context);
           const PhoneAuth().launch(context);
        }
      }
    });
    defaultBlurRadius = 10.0;
    defaultSpreadRadius = 0.5;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: context.height() / 3,
            ),
            const Image(
              image: AssetImage('images/logoandname.png'),
            ),
            const Spacer(),
            Column(
              children: [
                Center(
                  child: Text(
                    'PIIK Mall Cambodia',
                    style: GoogleFonts.poppins(color: primaryColor, fontWeight: FontWeight.normal, fontSize: 20.0),
                  ),
                ),
                Center(
                  child: Text(
                    'V $appVersion',
                    style: GoogleFonts.poppins(color: primaryColor, fontWeight: FontWeight.normal, fontSize: 15.0),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

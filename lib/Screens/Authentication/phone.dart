import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mobile_pos/Screens/Authentication/phone_OTP_screen.dart';
import 'package:mobile_pos/constant.dart';
import 'package:nb_utils/nb_utils.dart';

import 'login_form.dart';

class PhoneAuth extends StatefulWidget {
  const PhoneAuth({Key? key}) : super(key: key);
  static String verify = '';
  static String phoneNumber = '';
  @override
  State<PhoneAuth> createState() => _PhoneAuthState();
}

class _PhoneAuthState extends State<PhoneAuth> {
  TextEditingController countryController = TextEditingController();

  String phoneNumber = '';
  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  @override
  void initState() {
    // TODO: implement initState
    countryController.text = "+855";
    super.initState();
    getConnectivity();
    checkInternet();
  }

  getConnectivity() =>
      subscription = Connectivity().onConnectivityChanged.listen(
        (ConnectivityResult result) async {
          isDeviceConnected = await InternetConnectionChecker().hasConnection;
          if (!isDeviceConnected && isAlertSet == false) {
            showDialogBox();
            setState(() => isAlertSet = true);
          }
        },
      );

  checkInternet() async {
    isDeviceConnected = await InternetConnectionChecker().hasConnection;
    if (!isDeviceConnected) {
      showDialogBox();
      setState(() => isAlertSet = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(left: 25, right: 25),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('images/logoandname.png',width: 120,height: 120),
              const SizedBox(height: 25),
              const Text(
                "Phone number log in",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "We need to register your phone without getting started!",
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Container(
                height: 55,
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 40,
                      child: TextField(
                        controller: countryController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const Text(
                      "|",
                      style: TextStyle(fontSize: 33, color: Colors.grey),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                        child: TextField(
                      onChanged: (value) {
                        phoneNumber = value;
                        PhoneAuth.phoneNumber = value;
                      },
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Phone number",
                      ),
                    ))
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    onPressed: () async {
                      EasyLoading.show(status: 'Loading', dismissOnTap: false);
                      try {
                        await FirebaseAuth.instance.verifyPhoneNumber(
                          phoneNumber: countryController.text + phoneNumber,
                          verificationCompleted:
                              (PhoneAuthCredential credential) {},
                          verificationFailed: (FirebaseAuthException e) {},
                          codeSent: (String verificationId, int? resendToken) {
                            EasyLoading.dismiss();
                            PhoneAuth.verify = verificationId;
                            const OTPVerify().launch(context);
                          },
                          codeAutoRetrievalTimeout: (String verificationId) {},
                        );
                      } catch (e) {
                        log('data: $e');
                        EasyLoading.dismiss();
                        const AlertDialog(
                          title: Text(
                              'Message'), // To display the title it is optional
                          content: Text(
                              'GeeksforGeeks'), // Message which will be pop up on the screen
                          // Action widget which will provide the user to acknowledge the choice
                          actions: [],
                        );
                        // EasyLoading.showError('Error');
                      }
                    },
                    child: const Text("Send the code")),
              ),
              const SizedBox(height: 10),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.end,
              //   children: [
              //     TextButton(
              //         onPressed: () {
              //           const LoginForm(isEmailLogin: true).launch(context);
              //         },
              //         child: const Text('Login With Email')),
              //   ],
              // )
            ],
          ),
        ),
      ),
    );
  }

  showDialogBox() => showCupertinoDialog<String>(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: const Text('No Connection'),
          content: const Text('Please check your internet connectivity'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.pop(context, 'Cancel');
                setState(() => isAlertSet = false);
                isDeviceConnected =
                    await InternetConnectionChecker().hasConnection;
                if (!isDeviceConnected && isAlertSet == false) {
                  showDialogBox();
                  setState(() => isAlertSet = true);
                }
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
}

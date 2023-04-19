// ignore_for_file: file_names

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/Authentication/phone.dart';
import 'package:mobile_pos/Screens/Authentication/profile_setup.dart';
import 'package:mobile_pos/Screens/Authentication/success_screen.dart';
import 'package:mobile_pos/Screens/Home/home.dart';
import 'package:mobile_pos/constant.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pinput/pinput.dart';

import '../../Provider/customer_provider.dart';
import '../../Provider/profile_provider.dart';

class OTPVerify extends StatefulWidget {
  const OTPVerify({Key? key}) : super(key: key);

  @override
  State<OTPVerify> createState() => _OTPVerifyState();
}

class _OTPVerifyState extends State<OTPVerify> {
  FirebaseAuth auth = FirebaseAuth.instance;

  String code = '';
  final CurrentUserData currentUserData = CurrentUserData();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.black,
          ),
        ),
        elevation: 0,
      ),
      body: Container(
        margin: const EdgeInsets.only(left: 25, right: 25),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'images/logoandname.png',
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 25),
              const Text(
                "OTP Verification",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "We need to register your phone without getting started!",
                style: TextStyle(
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Pinput(
                  length: 6,
                  showCursor: true,
                  onCompleted: (pin) {
                    code = pin;
                  }),
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
                      EasyLoading.show(status: 'Loading...');
                      log(PhoneAuth.verify);
                      log(code);
                      try {
                        PhoneAuthCredential credential =
                            PhoneAuthProvider.credential(
                                verificationId: PhoneAuth.verify,
                                smsCode: code);
                        final prefs = await SharedPreferences.getInstance();
                        await auth
                            .signInWithCredential(credential)
                            .then((value) {
                          log(value.user!.uid);
                          prefs.setString('userId', value.user!.uid);
                          currentUserData.getUserData();
                          if (value.additionalUserInfo!.isNewUser) {
                            EasyLoading.dismiss();
                            const ProfileSetup(
                              loginWithPhone: true,
                            ).launch(context);
                          } else {
                            EasyLoading.dismiss();
                            const Home().launch(context);
                            // SuccessScreen(
                            //   email: 'phone',
                            // ).launch(context);
                          }
                        });
                      } catch (e) {
                        EasyLoading.showError('Wrong OTP...');
                      }
                    },
                    child: const Text("Verify now")),
              )
            ],
          ),
        ),
      ),
    );
  }
}

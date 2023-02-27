import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pos/GlobalComponents/button_global.dart';
import 'package:mobile_pos/Screens/Authentication/login_form.dart';
import 'package:mobile_pos/Screens/Profile%20Screen/edit_profile.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../Provider/profile_provider.dart';
import '../../constant.dart';
import '../../model/personal_information_model.dart';

class ProfileDetails extends StatefulWidget {
  const ProfileDetails({Key? key}) : super(key: key);
 
  @override
  // ignore: library_private_types_in_public_api
  _ProfileDetailsState createState() => _ProfileDetailsState();
}

class _ProfileDetailsState extends State<ProfileDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 20.0,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: GestureDetector(
              onTap: () {
                const EditProfile().launch(context);
              },
              child: Row(
                children: [
                  const Icon(
                    Icons.edit,
                    color: kMainColor,
                  ),
                  const SizedBox(
                    width: 5.0,
                  ),
                  Text(
                    'Edit',
                    style: GoogleFonts.poppins(
                      color: kMainColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.0,
      ),
      body: Consumer(builder: (context, ref, child) {
        AsyncValue<PersonalInformationModel> userProfileDetails = ref.watch(profileDetailsProvider);
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: userProfileDetails.when(data: (details) {
              return Column(
                children: [
                  Center(
                    child: Container(
                      height: 100.0,
                      width: 100.0,
                      decoration: BoxDecoration(
                        image: DecorationImage(image: NetworkImage(details.pictureUrl ?? ''), fit: BoxFit.cover),
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: AppTextField(
                      readOnly: true,
                      cursorColor: kGreyTextColor,
                      controller: TextEditingController(
                        text: details.companyName,
                      ),
                      decoration: InputDecoration(
                          labelText: 'Name',
                          border:
                              const OutlineInputBorder().copyWith(borderSide: const BorderSide(color: kGreyTextColor)),
                          hoverColor: kGreyTextColor,
                          fillColor: kGreyTextColor),
                      textFieldType: TextFieldType.NAME,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: AppTextField(
                      readOnly: true,
                      cursorColor: kGreyTextColor,
                      controller: TextEditingController(
                        text: details.phoneNumber,
                      ),
                      decoration: InputDecoration(
                          labelText: 'Phone Number',
                          border:
                              const OutlineInputBorder().copyWith(borderSide: const BorderSide(color: kGreyTextColor)),
                          hoverColor: kGreyTextColor,
                          fillColor: kGreyTextColor),
                      textFieldType: TextFieldType.NAME,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: AppTextField(
                      readOnly: true,
                      cursorColor: kGreyTextColor,
                      controller: TextEditingController(
                        text: details.businessCategory,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Business Category',
                        border:
                            const OutlineInputBorder().copyWith(borderSide: const BorderSide(color: kGreyTextColor)),
                        hoverColor: kGreyTextColor,
                        fillColor: kGreyTextColor,
                      ),
                      textFieldType: TextFieldType.NAME,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            readOnly: true,
                            cursorColor: kGreyTextColor,
                            controller: TextEditingController(
                              text: details.countryName,
                            ),
                            decoration: InputDecoration(
                                labelText: 'Address',
                                border: const OutlineInputBorder()
                                    .copyWith(borderSide: const BorderSide(color: kGreyTextColor)),
                                hoverColor: kGreyTextColor,
                                fillColor: kGreyTextColor),
                            textFieldType: TextFieldType.NAME,
                          ),
                        ),
                        const SizedBox(
                          width: 10.0,
                        ),
                        Expanded(
                          child: AppTextField(
                            readOnly: true,
                            cursorColor: kGreyTextColor,
                            controller: TextEditingController(
                              text: details.language,
                            ),
                            decoration: InputDecoration(
                                labelText: 'Language',
                                border: const OutlineInputBorder()
                                    .copyWith(borderSide: const BorderSide(color: kGreyTextColor)),
                                hoverColor: kGreyTextColor,
                                fillColor: kGreyTextColor),
                            textFieldType: TextFieldType.NAME,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ButtonGlobal(
                  //   iconWidget: Icons.arrow_forward,
                  //   buttontext: 'Change Password',
                  //   iconColor: Colors.white,
                  //   buttonDecoration: kButtonDecoration.copyWith(color: kMainColor),
                  //   onPressed: () async {
                  //     try {
                  //       EasyLoading.show(status: 'Sending Email', dismissOnTap: false);
                  //       await FirebaseAuth.instance.sendPasswordResetEmail(
                  //         email: FirebaseAuth.instance.currentUser!.email.toString(),
                  //       );
                  //       EasyLoading.showSuccess('Email Sent! Check your Inbox');
                  //       // ignore: use_build_context_synchronously
                  //       const LoginForm(isEmailLogin: true,).launch(context);
                  //       FirebaseAuth.instance.signOut();
                  //     } catch (e) {
                  //       EasyLoading.showError(e.toString());
                  //     }
                  //   },
                  // ),
                ],
              );
            }, error: (e, stack) {
              return Text(e.toString());
            }, loading: () {
              return const CircularProgressIndicator();
            }),
          ),
        );
      }),
    );
  }
}

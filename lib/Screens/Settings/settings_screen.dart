import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pos/Screens/Profile%20Screen/profile_details.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:restart_app/restart_app.dart';
import '../../Provider/profile_provider.dart';
import '../../constant.dart';
import '../../model/personal_information_model.dart';
import '../Shimmers/home_screen_appbar_shimmer.dart';
import '../subscription/package_screen.dart';
import "package:phoenix_native/phoenix_native.dart";
import 'package:flutter_phoenix/flutter_phoenix.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool expanded = false;
  bool expandedHelp = false;
  bool expandedAbout = false;
  bool selected = false;

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    EasyLoading.showSuccess('Successfully Logged Out');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    printerIsEnable();
  }

  void printerIsEnable() async {
    final prefs = await SharedPreferences.getInstance();

    isPrintEnable = prefs.getBool('isPrintEnable') ?? true;
  }

  void showCustomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm"),
          content: Text("Are you want to logOut?"),
          actions: [
            TextButton(
              child: Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("LogOut"),
              onPressed: () async {
                EasyLoading.show(status: 'Log Out');
                await _signOut();

                ///________subUser_logout___________________________________________________
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isSubUser', false);
                Future.delayed(const Duration(milliseconds: 1000), () {
                   Phoenix.rebirth(context);
                  //_restartApp();
                  // Restart.restartApp();
                  // const SignInScreen().launch(context);
                });
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer(builder: (context, ref, _) {
        AsyncValue<PersonalInformationModel> userProfileDetails =
            ref.watch(profileDetailsProvider);

        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                Card(
                  elevation: 0.0,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: userProfileDetails.when(data: (details) {
                      return Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              isSubUser
                                  ? null
                                  : const ProfileDetails().launch(context);
                            },
                            child: Container(
                              height: 42,
                              width: 42,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    image:
                                        NetworkImage(details.pictureUrl ?? ''),
                                    fit: BoxFit.cover),
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10.0,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isSubUser
                                    ? '${details.companyName ?? ''} [$subUserTitle]'
                                    : details.companyName ?? '',
                                style: GoogleFonts.poppins(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                details.businessCategory ?? '',
                                style: GoogleFonts.poppins(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.normal,
                                  color: kGreyTextColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }, error: (e, stack) {
                      return Text(e.toString());
                    }, loading: () {
                      return const HomeScreenAppBarShimmer();
                    }),
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                ListTile(
                  title: Text(
                    'Profile',
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 18.0,
                    ),
                  ),
                  onTap: () {
                    const ProfileDetails().launch(context);
                  },
                  leading: const Icon(
                    Icons.person_outline_rounded,
                    color: kMainColor,
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: kGreyTextColor,
                  ),
                ).visible(!isSubUser),

                ListTile(
                  title: Text(
                    'Printing Option',
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 18.0,
                    ),
                  ),
                  leading: const Icon(
                    Icons.print,
                    color: kMainColor,
                  ),
                  trailing: Switch.adaptive(
                    value: isPrintEnable,
                    onChanged: (bool value) async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('isPrintEnable', value);
                      setState(() {
                        isPrintEnable = value;
                      });
                    },
                  ),
                ),

                ///_________subscription_____________________________________________________
                ListTile(
                  title: Text(
                    'Subscription',
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 18.0,
                    ),
                  ),
                  onTap: () {
                    // const SubscriptionScreen().launch(context);
                    const PackageScreen().launch(context);
                  },
                  leading: const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: kMainColor,
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: kGreyTextColor,
                  ),
                ),

                ///___________user_role___________________________________________________________
                // ListTile(
                //   title: Text(
                //     'User Role',
                //     style: GoogleFonts.poppins(
                //       color: Colors.black,
                //       fontSize: 18.0,
                //     ),
                //   ),
                //   onTap: () {
                //     const UserRoleScreen().launch(context);
                //   },
                //   leading: const Icon(
                //     Icons.supervised_user_circle_sharp,
                //     color: kMainColor,
                //   ),
                //   trailing: const Icon(
                //     Icons.arrow_forward_ios,
                //     color: kGreyTextColor,
                //   ),
                // ).visible(!isSubUser),

                ///__________log_Out_______________________________________________________________
                ListTile(
                  title: Text(
                    'Log Out',
                    style: GoogleFonts.poppins(
                      color: Colors.red,
                      fontSize: 18.0,
                    ),
                  ),
                  onTap: () async {
                    // PhoenixNative.restartApp();
                   // Phoenix.rebirth(context);
                    // Restart.restartApp();
                     showCustomDialog(context);
                  },
                  leading: const Icon(
                    Icons.logout,
                    color: Colors.red,
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: kGreyTextColor,
                  ),
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Piik Mall V$appVersion',
                        style: GoogleFonts.poppins(
                          color: kGreyTextColor,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class NoticationSettings extends StatefulWidget {
  const NoticationSettings({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _NoticationSettingsState createState() => _NoticationSettingsState();
}

class _NoticationSettingsState extends State<NoticationSettings> {
  bool notify = false;
  String notificationText = 'Off';

  @override
  Widget build(BuildContext context) {
    // ignore: sized_box_for_whitespace
    return Container(
      height: 350.0,
      width: MediaQuery.of(context).size.width - 80,
      child: Column(
        children: [
          Row(
            children: [
              const Spacer(),
              IconButton(
                color: kGreyTextColor,
                icon: const Icon(Icons.cancel_outlined),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          Container(
            height: 100.0,
            width: 100.0,
            decoration: BoxDecoration(
              color: kDarkWhite,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: const Center(
              child: Icon(
                Icons.notifications_none_outlined,
                size: 50.0,
                color: kMainColor,
              ),
            ),
          ),
          const SizedBox(
            height: 20.0,
          ),
          Center(
            child: Text(
              'Do Not Disturb',
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Lorem ipsum dolor sit amet, consectetur elit. Interdum cons.',
                maxLines: 2,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: kGreyTextColor,
                  fontSize: 16.0,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                notificationText,
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 16.0,
                ),
              ),
              Switch(
                value: notify,
                onChanged: (val) {
                  setState(() {
                    notify = val;
                    val ? notificationText = 'On' : notificationText = 'Off';
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

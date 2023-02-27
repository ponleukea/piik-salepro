import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mobile_pos/Screens/Home/home_screen.dart';
import 'package:mobile_pos/Screens/Report/reports.dart';
import 'package:mobile_pos/Screens/Settings/settings_screen.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:restart_app/restart_app.dart'; 

import '../../constant.dart';
import '../Sales/sales_contact.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;
  bool isNoInternet = false;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    SalesContact(),
    Reports(),
    SettingScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void signOutAutoLogin() async {
    CurrentUserData currentUserData = CurrentUserData();
    if (await currentUserData.isSubUserEmailNotFound() && isSubUser) {
      await FirebaseAuth.instance.signOut();
      Future.delayed(const Duration(milliseconds: 5000), () async {
        EasyLoading.showError('User is deleted');
      });
      Future.delayed(const Duration(milliseconds: 1000), () async { 
        Restart.restartApp();
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getConnectivity();
    checkInternet();
    isSubUser ? signOutAutoLogin() : null;
  }

  checkInternet() async {
    isDeviceConnected = await InternetConnectionChecker().hasConnection;
    if (!isDeviceConnected) {
      showDialogBox();
      setState(() => isAlertSet = true); 
    }
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
  @override
  void dispose() { 
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        elevation: 6.0,
        selectedItemColor: primaryColor,
        // ignore: prefer_const_literals_to_create_immutables
        items: [
          const BottomNavigationBarItem(
            icon: Icon(FeatherIcons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(FeatherIcons.shoppingCart),
            label: 'Sales',
          ),
          const BottomNavigationBarItem(
            icon: Icon(FeatherIcons.fileText),
            label: 'Reports',
          ),
          const BottomNavigationBarItem(
              icon: Icon(FeatherIcons.settings), label: 'Settings'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  showDialogBox() {
    showCupertinoDialog<String>(
      context: context,
      barrierDismissible: false,
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
}

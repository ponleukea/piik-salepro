import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mobile_pos/model/user_role_model.dart';
import 'package:nb_utils/nb_utils.dart';

// const kMainColor = Color(0xFF3F8CFF);
const kMainColor = Color(0xFF2980B9);
const kGreyTextColor = Color(0xFF828282);
const kBorderColorTextField = Color(0xFFC2C2C2);
const kDarkWhite = Color(0xFFF1F7F7);
const kPremiumPlanColor = Color(0xFF8752EE);
const kPremiumPlanColor2 = Color(0xFFFF5F00);
const primaryColor = Color(0xFF2980B9);
const greyColor = Color(0xFFEEEEEE);
const greenColor = Color(0xFF49C856);
bool connected = false;
bool isPrintEnable = true;
List<String> paymentsTypeList = ['Cash'];

bool isExpiringInFiveDays = false;
bool isExpiringInOneDays = false;

const String appVersion = '1.0.0';

String paypalClientId = '';
String paypalClientSecret = '';
const bool sandbox = true;

const kButtonDecoration = BoxDecoration(
  borderRadius: BorderRadius.all(
    Radius.circular(5),
  ),
);

const kInputDecoration = InputDecoration(
  hintStyle: TextStyle(color: kBorderColorTextField),
  filled: true,
  fillColor: Colors.white70,
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
    borderSide: BorderSide(color: kBorderColorTextField, width: 2),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(6.0)),
    borderSide: BorderSide(color: kBorderColorTextField, width: 2),
  ),
);

OutlineInputBorder outlineInputBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(1.0),
    borderSide: const BorderSide(color: kBorderColorTextField),
  );
}

final otpInputDecoration = InputDecoration(
  contentPadding: const EdgeInsets.symmetric(vertical: 5.0),
  border: outlineInputBorder(),
  focusedBorder: outlineInputBorder(),
  enabledBorder: outlineInputBorder(),
);

List<String> businessCategory = ['Fashion Store', 'Electronics Store', 'Computer Store', 'Vegetable Store', 'Sweet Store', 'Meat Store'];
List<String> language = ['English'];

List<String> productCategory = ['Fashion', 'Electronics', 'Computer', 'Gadgets', 'Watches', 'Cloths'];

///______________________________________________________________________________________________
String constUserId = '';
bool isSubUser = false;
String subUserTitle = '';
String subUserEmail = '';
bool isSubUserDeleted = true;
//

UserRoleModel finalUserRoleModel = UserRoleModel(
  email: '',
  userTitle: '',
  databaseId: '',
  salePermission: true,
  partiesPermission: true,
  purchasePermission: true,
  productPermission: true,
  profileEditPermission: true,
  addExpensePermission: true,
  lossProfitPermission: true,
  dueListPermission: true,
  stockPermission: true,
  reportsPermission: true,
  salesListPermission: true,
  purchaseListPermission: true,
);

class CurrentUserData {
  
  void getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    constUserId = prefs.getString('userId') ?? '';
    isSubUser = prefs.getBool('isSubUser') ?? false;
    subUserEmail = prefs.getString('subUserEmail') ?? '';
    await updateData();
  }

  Future<void> updateData() async {
    // bool subUserEmailMatch = false;
    final prefs = await SharedPreferences.getInstance();
    await FirebaseDatabase.instance.ref(constUserId).child('User Role').orderByKey().get().then((value) async {
      for (var element in value.children) {
        var data = UserRoleModel.fromJson(jsonDecode(jsonEncode(element.value)));
        if (data.email == subUserEmail) {
          isSubUserDeleted = false;
          finalUserRoleModel = data;
          await prefs.setString('userTitle', data.userTitle);
          subUserTitle = prefs.getString('userTitle') ?? '';
        }
      }
    });
  }

  Future<bool> isSubUserEmailNotFound() async {
    bool isMailMatch = true;
    await FirebaseDatabase.instance.ref(constUserId).child('User Role').orderByKey().get().then((value) async {
      for (var element in value.children) {
        var data = UserRoleModel.fromJson(jsonDecode(jsonEncode(element.value)));
        if (data.email == subUserEmail) {
          isMailMatch = false;
          return;
        }
      }
    });
    return isMailMatch;
  }

  void putUserData({required String userId, required bool isSubUser, required String title, required String email}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    await prefs.setString('subUserEmail', email);
    await prefs.setString('userTitle', title);
    await prefs.setBool('isSubUser', isSubUser);
    getUserData();
  }
}

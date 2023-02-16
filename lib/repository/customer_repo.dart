import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:mobile_pos/Screens/Customers/Model/customer_model.dart';

import '../constant.dart';

class CustomerRepo {

  Future<List<CustomerModel>> getAllCustomers() async {
    List<CustomerModel> customerList = [];
    await FirebaseDatabase.instance.ref(constUserId).child('Customers').orderByKey().get().then((value) {
      for (var element in value.children) {
        customerList.add(CustomerModel.fromJson(jsonDecode(jsonEncode(element.value))));
      }
    });
    return customerList;
  }
}

import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';

import '../constant.dart';
import '../model/product_model.dart';

class ProductRepo {
  Future<List<ProductModel>> getAllProduct() async {
    List<ProductModel> productList = [];
    await FirebaseDatabase.instance.ref(constUserId).child('Products').orderByKey().get().then((value) {
      for (var element in value.children) {
        productList.add(ProductModel.fromJson(jsonDecode(jsonEncode(element.value))));
      }
    });
    return productList;
  }
}

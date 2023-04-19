import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pos/Provider/add_to_cart.dart';
import 'package:mobile_pos/Provider/customer_provider.dart';
import 'package:mobile_pos/Provider/product_provider.dart';
import 'package:mobile_pos/Provider/profile_provider.dart';
import 'package:mobile_pos/Provider/seles_report_provider.dart';
import 'package:mobile_pos/Provider/transactions_provider.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/model/add_to_cart_model.dart';
import 'package:mobile_pos/model/transition_model.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:touchable_opacity/touchable_opacity.dart';
import '../../GlobalComponents/button_global.dart';
import '../../helper.dart';
import '../Customers/Model/customer_model.dart';

// ignore: must_be_immutable
class PaymentScreen extends StatefulWidget {
  final List data;

  PaymentScreen({Key? key, required this.data, required this.customerModel})
      : super(key: key);
  CustomerModel customerModel;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  List<dynamic> items = [];

  TextEditingController paidText = TextEditingController();
  String? dropdownValue = 'Cash';
  int invoice = 0;
  double paidAmount = 0;
  double discountAmount = 0;
  double returnAmount = 0;
  double dueAmount = 0;
  double subTotal = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      items = widget.data;
    });
    // log(widget.data);
    // log(widget.customerModel);
  }

  double calculateSubtotal() {
    double total = 0;
    for (int i = 0; i < items.length; i++) {
      total += double.parse(items[i]['productSalePrice']) * items[i]['qty'];
    }
    return total;
  }

  double calculateTotal() {
    double total = 0;
    total = (calculateSubtotal() - discountAmount);
    return total;
  }

  double calculateReturnAmount() {
    returnAmount = calculateTotal() - paidAmount;
    return paidAmount <= 0 || paidAmount <= calculateTotal()
        ? 0
        : calculateTotal() - paidAmount;
  }

  double calculateDueAmount() {
    if (calculateTotal() < 0) {
      dueAmount = 0;
    } else {
      dueAmount = calculateSubtotal() - paidAmount;
    }
    return returnAmount <= 0
        ? 0
        : calculateSubtotal() - paidAmount - discountAmount;
  }

  void decreaseStock(String productCode, int quantity) async {
    final ref = FirebaseDatabase.instance.ref('$constUserId/Products/');

    var data =
        await ref.orderByChild('productCode').equalTo(productCode).once();
    String productPath = data.snapshot.value.toString().substring(1, 21);

    var data1 = await ref.child('$productPath/productStock').once();
    int stock = int.parse(data1.snapshot.value.toString());
    int remainStock = stock - quantity;

    ref.child(productPath).update({'productStock': '$remainStock'});
  }

  void getSpecificCustomers(
      {required String phoneNumber, required int due}) async {
    final ref = FirebaseDatabase.instance.ref('$constUserId/Customers/');
    String? key;

    await FirebaseDatabase.instance
        .ref(constUserId)
        .child('Customers')
        .orderByKey()
        .get()
        .then((value) {
      for (var element in value.children) {
        var data = jsonDecode(jsonEncode(element.value));
        if (data['phoneNumber'] == phoneNumber) {
          key = element.key;
        }
      }
    });
    var data1 = await ref.child('$key/due').once();
    int previousDue = data1.snapshot.value.toString().toInt();

    int totalDue = previousDue + due;
    ref.child(key!).update({'due': '$totalDue'});
  }

  late TransitionModel transitionModel = TransitionModel(
    customerName: widget.customerModel.customerName,
    customerPhone: widget.customerModel.phoneNumber,
    customerType: widget.customerModel.type,
    invoiceNumber: invoice.toString(),
    purchaseDate: DateTime.now().toString(),
  );

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, consumerRef, __) {
      final personalData = consumerRef.watch(profileDetailsProvider);
      final providerData = consumerRef.watch(cartNotifier);
      personalData.when(data: (data) {
        invoice = data.invoiceCounter!.toInt();
      }, error: (e, stack) {
        return Text(e.toString());
      }, loading: () {
        return null;
      });

      return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Payment', style: GoogleFonts.poppins(color: Colors.black)),
              Text('Inv No: #' + invoice.toString(),
                  style: TextStyle(color: Colors.black, fontSize: 17)),
            ],
          ),
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0.0,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
              child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                Container(
                  margin: const EdgeInsets.all(5),
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      border: Border.all(color: kBorderColorTextField),
                      borderRadius: const BorderRadius.all(Radius.circular(7))),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                items[i]['productName'],
                                textAlign: TextAlign.left,
                                maxLines: 2,
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                '${items[i]['qty'].toString()} x \$${items[i]['productSalePrice']} = \$${TypesHelper.roundNum((items[i]['qty'] * double.parse(items[i]['productSalePrice'])))}',
                                style: TextStyle(color: kMainColor),
                              ),
                            ],
                          )),
                      Row(
                        children: [
                          TouchableOpacity(
                            onTap: () {
                              if (items[i]['qty'] > 1) {
                                List<dynamic> newItesm = [...items];
                                newItesm[i]['qty'] = newItesm[i]['qty'] - 1;
                                setState(() {
                                  items = newItesm;
                                });
                              } else {
                                EasyLoading.showError(
                                    'Qty of item at least 1!');
                              }
                            },
                            child: Image.asset(
                              'images/icon_minus.png',
                              width: 60,
                              height: 60,
                            ),
                          ),
                          Text(
                            items[i]['qty'].toString(),
                            style:
                                TextStyle(fontSize: 17, color: kGreyTextColor),
                          ),
                          TouchableOpacity(
                            onTap: () {
                              List<dynamic> newItesm = [...items];
                              if (newItesm[i]['qty'].toString() ==
                                  items[i]['productStock'].toString()) {
                                EasyLoading.showError('Product out of stock');
                              } else {
                                newItesm[i]['qty'] = newItesm[i]['qty'] + 1;
                                setState(() {
                                  items = newItesm;
                                });
                              }
                            },
                            child: Image.asset(
                              'images/icon_add.png',
                              width: 60,
                              height: 60,
                            ),
                          ),
                          TouchableOpacity(
                            onTap: () {
                              if (items.length == 1) {
                                EasyLoading.showError('Product at least 1.');
                              } else {
                                List<dynamic> newItesm = [...items];
                                newItesm.removeAt(i);
                                setState(() {
                                  items = newItesm;
                                });
                              }
                            },
                            child: Image.asset(
                              'images/icon_delete.png',
                              width: 60,
                              height: 60,
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),

              ///_____Total______________________________
              Container(
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    border: Border.all(color: kMainColor, width: 1.2)),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                          color: kMainColor,
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(7),
                              topLeft: Radius.circular(7))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Sub Total',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '\$${TypesHelper.roundNum(calculateSubtotal())}',
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Discount',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          SizedBox(
                            width: context.width() / 4,
                            child: TextField(
                              maxLength: 7,
                              controller: paidText,
                              onChanged: (value) {
                                if (value == '') {
                                  setState(() {
                                    discountAmount = 0;
                                  });
                                } else {
                                  if (value.toInt() >= subTotal) {
                                    setState(() {
                                      discountAmount = double.parse(value);
                                    });
                                  } else {
                                    paidText.clear();
                                    setState(() {
                                      discountAmount = 0;
                                    });
                                    EasyLoading.showError(
                                        'Enter a valid Discount');
                                  }
                                }
                              },
                              textAlign: TextAlign.right,
                              decoration: const InputDecoration(
                                hintText: '\$0.00',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '\$${TypesHelper.roundNum(calculateTotal())}',
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Paid Amount',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          SizedBox(
                            width: context.width() / 4,
                            child: TextField(
                              maxLength: 7,
                              keyboardType: TextInputType.text,
                              onChanged: (value) {
                                if (value == '') {
                                  setState(() {
                                    paidAmount = 0;
                                  });
                                } else {
                                  setState(() {
                                    paidAmount = double.parse(value);
                                  });
                                }
                              },
                              textAlign: TextAlign.right,
                              decoration:
                                  const InputDecoration(hintText: '\$0.00'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Return Amount',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          Text(
                            '\$${TypesHelper.roundNum(calculateReturnAmount().abs())}',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Due Amount',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          Text(
                            '\$${TypesHelper.roundNum(calculateDueAmount())}',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Container(
                height: 0.2,
                width: double.infinity,
                color: Colors.grey,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.wallet,
                        color: primaryColor,
                      ),
                      Text(
                        'Payment Type:',
                        style: TextStyle(fontSize: 17, color: Colors.black54),
                      ),
                      // SizedBox(
                      //   width: 5,
                      // )
                    ],
                  ),
                  DropdownButton(
                    underline: Container(),
                    value: dropdownValue,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: kMainColor,
                      size: 30,
                    ),
                    items: paymentsTypeList.map((String items) {
                      return DropdownMenuItem(
                        value: items,
                        child: Text(
                          items,
                          style: const TextStyle(color: Colors.black),
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        dropdownValue = newValue.toString();
                      });
                    },
                  ),
                ],
              ),
              // const SizedBox(height: 10),
              Container(
                height: 0.2,
                width: double.infinity,
                color: Colors.grey,
              ),
              const SizedBox(height: 30)
            ],
          )),
        )),
        bottomNavigationBar: ButtonGlobal(
            iconWidget: null,
            buttontext: 'Pay Now',
            iconColor: Colors.white,
            buttonDecoration: kButtonDecoration.copyWith(color: primaryColor),
            onPressed: () async {
              EasyLoading.show(status: 'Loading...', dismissOnTap: false);
              List<dynamic> productList = [];
              for (int i = 0; i < items.length; i++) {
                var item = {
                  "uuid": items[i]['productCode'],
                  "product_id": items[i]['productCode'],
                  "product_name": items[i]['productName'],
                  "product_brand_name": items[i]['brandName'],
                  "unit_price": null,
                  "sub_total": double.parse(items[i]['productSalePrice']) *
                      items[i]['qty'],
                  "unique_check": null,
                  "quantity": items[i]['qty'],
                  "item_cart_index": -1,
                  "stock": int.parse(items[i]['productStock']),
                  "productPurchasePrice": items[i]['productPurchasePrice'],
                  "product_details": null
                };
                productList.add(jsonEncode(item));
              }
              DatabaseReference ref = FirebaseDatabase.instance
                  .ref("$constUserId/Sales Transition");

              num totalQuantity = 0;
              double lossProfit = 0;
              double totalPurchasePrice = 0;
              double totalSalePrice = 0;

              for (int j = 0; j < items.length; j++) {
                totalPurchasePrice +=
                    double.parse(items[j]['productPurchasePrice']) *
                        items[j]['qty'];
                totalSalePrice += double.parse(items[j]['productSalePrice']) *
                    items[j]['qty'];
                totalQuantity += items[j]['qty'];
              }

              lossProfit = ((totalSalePrice - totalPurchasePrice.toDouble()) -
                  double.parse(discountAmount.toString()));

              Object dataToSubmit = {
                "customerName": widget.customerModel.customerName,
                "customerPhone": widget.customerModel.phoneNumber,
                "customerType": widget.customerModel.type,
                "invoiceNumber": invoice.toString(),
                "purchaseDate": DateTime.now().toString(),
                "totalQuantity": totalQuantity,
                "lossProfit": lossProfit,
                "discountAmount": discountAmount,
                "totalAmount": calculateTotal(),
                "dueAmount": dueAmount <= 0 ? 0 : dueAmount,
                "returnAmount": returnAmount < 0 ? returnAmount.abs() : 0,
                "sellerName": isSubUser ? subUserTitle : null,
                "isPaid": dueAmount <= 0 ? true : false,
                "paymentType": dropdownValue,
                "productList": productList,
              };
              await ref.push().set(dataToSubmit);

              log(dataToSubmit);

              for (int k = 0; k < items.length; k++) {
                decreaseStock(items[k]['productCode'], items[k]['qty']);
              }

              ///_______invoice_Update_____________________________________________
              final DatabaseReference personalInformationRef =
                  // ignore: deprecated_member_use
                  FirebaseDatabase.instance
                      .ref()
                      .child(constUserId)
                      .child('Personal Information');

              await personalInformationRef
                  .update({'invoiceCounter': invoice + 1});

              ///_________DueUpdate______________________________________________________
              getSpecificCustomers(
                  phoneNumber: widget.customerModel.phoneNumber,
                  due: dueAmount.toInt());
              EasyLoading.dismiss();
              Future.delayed(const Duration(milliseconds: 800), () {
                AwesomeDialog(
                  btnOk: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      color: darkGray,
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      child: const Text(
                        'OK',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ),
                  customHeader: Column(
                    children: [Image.asset('images/success_icon.png')],
                  ),
                  context: context,
                  animType: AnimType.leftSlide,
                  headerAnimationLoop: false,
                  //dialogType: DialogType.SUCCES,
                  showCloseIcon: false,
                  title: '',
                  descTextStyle: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF49C856)),
                  desc: 'Order Complete',
                  btnOkOnPress: () {
                    Navigator.pop(context);
                  },
                  dismissOnTouchOutside: true,
                  btnOkIcon: Icons.check_circle,
                  onDismissCallback: (type) {
                    consumerRef.refresh(customerProvider);
                    consumerRef.refresh(productProvider);
                    consumerRef.refresh(salesReportProvider);
                    consumerRef.refresh(transitionProvider);
                    consumerRef.refresh(profileDetailsProvider);
                    Navigator.pop(context);
                    debugPrint('Dialog Dissmiss from callback $type');
                  },
                ).show();
              });
            }),
      );
    });
  }
}

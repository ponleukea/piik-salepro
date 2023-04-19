import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pos/Provider/add_to_cart.dart';
import 'package:mobile_pos/Screens/Customers/Model/customer_model.dart';
import 'package:mobile_pos/Screens/Customers/add_customer.dart';
import 'package:mobile_pos/Screens/POS/add_sales.dart';
import 'package:mobile_pos/Screens/POS/payment.dart';
import 'package:mobile_pos/Screens/Sales/sales_contact.dart';
import 'package:mobile_pos/model/add_to_cart_model.dart';
import 'package:mobile_pos/model/product_model.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../GlobalComponents/button_global.dart';
import '../../constant.dart';
import 'package:touchable_opacity/touchable_opacity.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class AddItem extends StatefulWidget {
  final List listProduct;

  const AddItem({Key? key, required this.listProduct}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AddItme createState() => _AddItme();
}

class _AddItme extends State<AddItem> with SingleTickerProviderStateMixin {
  final TextEditingController proNameController = TextEditingController();
  String searching = '';
  int selectedCard = -1;
  late TabController controller;

  List<dynamic> newProduct = [];
  List<dynamic> originalProduct = [];
  int tabIndex = 0;

  CustomerModel customerModel = CustomerModel(
    'Guest',
    'Guest',
    'Guest',
    'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460__340.png',
    'Guest',
    'Guest',
    '0',
  );

  List<dynamic> mainCheck = [];
  String userName = 'Select Customer Name';

  @override
  void initState() {
    super.initState();
    controller = TabController(
      length: widget.listProduct.length,
      vsync: this,
      initialIndex: tabIndex,
    );
    controller.addListener(onPositionChange);
    setState(() {
      newProduct = widget.listProduct;
      originalProduct = widget.listProduct;
    });
    //log(widget.listProduct);
  }

  void onPositionChange() {
    if (!controller.indexIsChanging) {
      if (searching.length > 3) {
        List<dynamic> newProductList =
            searchProductByName(searching, newProduct, tabIndex);
        setState(() {
          newProduct = newProductList;
        });
      }
      setState(() {
        tabIndex = controller.index;
      });
    }
  }

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#2980B9', 'Cancel', true, ScanMode.BARCODE);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    if (!mounted) return;
    if (barcodeScanRes != '-1') {
      setState(() {
        searching = barcodeScanRes;
      });
      List<dynamic> newProductList =
          searchProductByName(barcodeScanRes, newProduct, tabIndex);
      setState(() {
        newProduct = newProductList;
      });
      proNameController.text = barcodeScanRes;
    }
  }

  List<dynamic> searchProductByName(
    String name,
    List<dynamic> productList,
    int index,
  ) {
    List<dynamic> newProductList = productList;

    for (var product in productList[index]['list']) {
      if (product['productName'].toLowerCase() == name.toLowerCase() ||
          product['productCode'].toLowerCase() == name.toLowerCase()) {
        Object newItem = {
          'title': productList[index]['title'],
          'list': [product]
        };
        newProductList[index] = newItem;
        break;
      } else {
        newProductList = [...originalProduct];
      }
    }
    return newProductList;
  }

  List<dynamic> itemPro = [];
  List<dynamic> childPro = [];

  bool searItem(String keySearch) {
    bool isHave = false;
    if (mainCheck.isNotEmpty) {
      var data =
          mainCheck.where((row) => (row["productCode"].contains(keySearch)));
      if (data.isNotEmpty) {
        isHave = true;
      }
    }
    return isHave;
  }

  int searchIndex(String keySearch) {
    final index =
        mainCheck.indexWhere((element) => element["productCode"] == keySearch);
    return index;
  }

  int searchQty(String keySearch) {
    var qty = 0;
    var myIndex = searchIndex(keySearch);
    if (myIndex > -1) {
      qty = mainCheck[myIndex]['qty'];
    }
    return qty;
  }

  double calculatePrice() {
    double price = 0;
    if (mainCheck.isNotEmpty) {
      for (var i = 0; i < mainCheck.length; i++) {
        double total = double.parse(mainCheck[i]['productSalePrice']) *
            mainCheck[i]['qty'];
        price += total;
      }
      log(price);
    }
    return price;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, __) {
      final providerData = ref.watch(cartNotifier);
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            'Add Items',
            style: GoogleFonts.poppins(
              color: Colors.black,
            ),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
          elevation: 0.0,
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        height: 45.0,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          border: Border.all(color: kGreyTextColor),
                        ),
                        child: GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SalesContact(from: 'POS'),
                                ));
                            setState(() {
                              customerModel = result;
                            });
                          },
                          child: Row(
                            children: [
                              SizedBox(
                                width: 10.0,
                              ),
                              Text(customerModel?.customerName != null
                                  ? customerModel.customerName
                                  : userName),
                              Spacer(),
                              Icon(Icons.keyboard_arrow_down),
                              SizedBox(
                                width: 10.0,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AddCustomer(from: 'POS'),
                              ));
                          setState(() {
                            customerModel = result;
                          });
                          log(result);
                        },
                        child: Container(
                          height: 45.0,
                          width: 100.0,
                          padding: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: kGreyTextColor),
                          ),
                          child: const Image(
                            image: AssetImage('images/pos_user_add.png'),
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SizedBox(
                            height: 45,
                            child: TextField(
                              onChanged: (txt) {
                                List<dynamic> newProductList =
                                    searchProductByName(
                                        txt, newProduct, tabIndex);
                                setState(() {
                                  newProduct = newProductList;
                                });
                                setState(() {
                                  searching = txt;
                                });
                              },
                              controller: proNameController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Search name or barcode...',
                                hintText: 'Enter name or barcode',
                              ),
                            )),
                      )),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: GestureDetector(
                        onTap: () => scanBarcodeNormal(),
                        child: Container(
                          height: 45.0,
                          width: 100.0,
                          padding: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: kGreyTextColor),
                          ),
                          child: const Image(
                            image: AssetImage('images/pos_qr.png'),
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              newProduct[0]['list'].isNotEmpty
                  ? Container(
                      padding: const EdgeInsets.all(10),
                      alignment: Alignment.center,
                      child: TabBar(
                        isScrollable: true,
                        controller: controller,
                        labelColor: Theme.of(context).primaryColor,
                        unselectedLabelColor: Theme.of(context).hintColor,
                        indicator: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 2,
                            ),
                          ),
                        ),
                        tabs: List.generate(
                          newProduct.length,
                          (index) => Tab(text: newProduct[index]['title']),
                        ),
                      ),
                    )
                  : Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/AddProducts');
                        },
                        child: Container(
                          color: kMainColor,
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          child: const Text(
                            'Add Product',
                            style:
                                TextStyle(color: Colors.white, fontSize: 13.0),
                          ),
                        ),
                      ),
                    ),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(10),
                child: TabBarView(
                  controller: controller,
                  children: List.generate(
                    newProduct.length,
                    (index) => GridView.builder(
                        shrinkWrap: false,
                        scrollDirection: Axis.vertical,
                        itemCount: newProduct[index]["list"].length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 2.0,
                            mainAxisSpacing: 2.0
                            // childAspectRatio: MediaQuery.of(context).size.width /
                            //     (MediaQuery.of(context).size.height / 1.9),
                            ),
                        itemBuilder: (BuildContext context, int index1) {
                          return GestureDetector(
                            onTap: () {
                              List<dynamic> newMainCheck = [...mainCheck];
                              if (newMainCheck.isNotEmpty) {
                                var myIndex = searchIndex(newProduct[index]
                                    ['list'][index1]['productCode']);
                                if (myIndex > -1) {
                                  newMainCheck.removeAt(myIndex);
                                }
                              }
                              setState(() {
                                mainCheck = newMainCheck;
                              });
                            },
                            child: Card(
                                color: Colors.white,
                                semanticContainer: true,
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7.0),
                                ),
                                elevation: 5,
                                child: Stack(
                                  children: [
                                    Image.network(
                                      newProduct[index]['list'][index1]
                                          ['productPicture'],
                                      fit: BoxFit.fill,
                                     // width: 180,
                                    ),
                                    Positioned(
                                      right: 0,
                                      child: searchQty(newProduct[index]['list']
                                                  [index1]['productCode']) !=
                                              0
                                          ? Container(
                                              padding: const EdgeInsets.all(7),
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(),
                                                  shape: BoxShape.circle),
                                              child: Text(
                                                searchQty(newProduct[index]
                                                            ['list'][index1]
                                                        ['productCode'])
                                                    .toString(),
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.red),
                                              ),
                                            )
                                          : const Text(''),
                                    ),
                                    Positioned(
                                        bottom: 0,
                                        top: 100,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          color: searItem(newProduct[index]
                                                      ['list'][index1]
                                                  ['productCode'])
                                              ? const Color.fromRGBO(
                                                  41, 128, 185, 0.8)
                                              : Colors.grey.withOpacity(0.5),
                                          height: 60,
                                          child: Column(
                                            children: [
                                              Text(
                                                  newProduct[index]['list']
                                                      [index1]['productName'],
                                                  textAlign: TextAlign.start,
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600)),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    '\$${newProduct[index]['list'][index1]['productSalePrice']}',
                                                    style: const TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.white),
                                                  ),
                                                  TouchableOpacity(
                                                    onTap: () {
                                                      if (double.parse(newProduct[
                                                                          index]
                                                                      ['list']
                                                                  [index1][
                                                              'productStock']) <
                                                          0) {
                                                        EasyLoading.showError(
                                                            'Product Out of Stock');
                                                      } else {
                                                        List<dynamic>
                                                            newMainCheck = [
                                                          ...mainCheck
                                                        ];
                                                        if (newMainCheck
                                                            .isNotEmpty) {
                                                          var myIndex = searchIndex(
                                                              newProduct[index][
                                                                          'list']
                                                                      [index1][
                                                                  'productCode']);

                                                          if (myIndex > -1) {
                                                            if (mainCheck[
                                                                        myIndex]
                                                                    ['qty'] ==
                                                                double.parse(newProduct[
                                                                            index]
                                                                        [
                                                                        'list'][index1]
                                                                    [
                                                                    'productStock'])) {
                                                              EasyLoading.showError(
                                                                  'Product Out of Stock');
                                                            } else {
                                                              newMainCheck[
                                                                      myIndex][
                                                                  'qty'] = newMainCheck[
                                                                          myIndex]
                                                                      ['qty'] +
                                                                  1;
                                                            }
                                                          } else {
                                                            Map<String,
                                                                dynamic> firstItem = Map<
                                                                    String,
                                                                    dynamic>.from(
                                                                newProduct[index]
                                                                        ['list']
                                                                    [index1]);

                                                            firstItem['qty'] =
                                                                1;
                                                            newMainCheck
                                                                .add(firstItem);
                                                          }
                                                        } else {
                                                          Map<String,
                                                              dynamic> firstItem = Map<
                                                                  String,
                                                                  dynamic>.from(
                                                              newProduct[index]
                                                                      ['list']
                                                                  [index1]);

                                                          firstItem['qty'] = 1;
                                                          newMainCheck
                                                              .add(firstItem);
                                                        }
                                                        setState(() {
                                                          mainCheck =
                                                              newMainCheck;
                                                        });
                                                        log(mainCheck);
                                                        log(newProduct[index]
                                                                ['list'][index1]
                                                            ['productStock']);
                                                      }
                                                    },
                                                    activeOpacity: 0.4,
                                                    child: Image.asset(
                                                      'images/add_ring_light.png',
                                                      width: 50,
                                                      height: 50,
                                                    ),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        )),
                                  ],
                                )),
                          );
                        }),
                  ),
                ),
              ))
            ],
          ),
        ),
        bottomNavigationBar: ButtonGlobal(
            iconWidget: null,
            buttontext: 'Continue(\$${calculatePrice().toStringAsFixed(2)})',
            iconColor: Colors.white,
            buttonDecoration: kButtonDecoration.copyWith(color: primaryColor),
            onPressed: () {
              if (customerModel.customerName == 'Select Customer Name') {
                EasyLoading.showError('Please select Customer!');
              } else {
                if (mainCheck.isNotEmpty) {
                  PaymentScreen(
                    data: mainCheck,
                    customerModel: customerModel,
                  ).launch(context);
                  setState(() {
                    mainCheck = [];
                  });
                } else {
                  EasyLoading.showError('Please select product!');
                }
              }
            }),
      );
    });
  }
}

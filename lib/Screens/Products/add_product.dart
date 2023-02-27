import 'dart:io';

import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_pos/GlobalComponents/button_global.dart';
import 'package:mobile_pos/GlobalComponents/category_list.dart';
import 'package:mobile_pos/Screens/Products/brands_list.dart';
import 'package:mobile_pos/Screens/Products/unit_list.dart';
import 'package:mobile_pos/model/product_model.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../GlobalComponents/Model/category_model.dart';
import '../../Provider/product_provider.dart';
import '../../constant.dart';
import '../Home/home.dart';

// ignore: must_be_immutable
class AddProduct extends StatefulWidget {
  AddProduct({Key? key, this.catName, this.unitsName, this.brandName})
      : super(key: key);
  // ignore: prefer_typing_uninitialized_variables
  var catName;
  // ignore: prefer_typing_uninitialized_variables
  var unitsName;
  // ignore: prefer_typing_uninitialized_variables
  var brandName;
  @override
  // ignore: library_private_types_in_public_api
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  GetCategoryAndVariationModel data =
      GetCategoryAndVariationModel(variations: [], categoryName: '');
  String productCategory = 'Select Product Category';
  String brandName = 'Select Brand';
  String productUnit = 'Select Unit';
  String productName = '';
  String productStock = '';
  String productSalePrice = '';
  String productPurchasePrice = '';
  String productCode = '';
  String productWholeSalePrice = '0';
  String productDealerPrice = '0';
  String productPicture =
      'https://firebasestorage.googleapis.com/v0/b/maanpos.appspot.com/o/Customer%20Picture%2FNo_Image_Available.jpeg?alt=media&token=3de0d45e-0e4a-4a7b-b115-9d6722d5031f';
  String productDiscount = 'Not Provided';
  String productManufacturer = 'Not Provided';
  String size = 'Not Provided';
  String color = 'Not Provided';
  String weight = 'Not Provided';
  String capacity = 'Not Provided';
  String type = 'Not Provided';
  List<String> catItems = [];
  bool showProgress = false;
  double progress = 0.0;
  final ImagePicker _picker = ImagePicker();
  XFile? pickedImage;
  List<String> codeList = [];
  List<String> productNameList = [];
  String promoCodeHint = 'Enter product code';
  TextEditingController productCodeController = TextEditingController();

  bool nameValid = false;
  bool saleValid = false;
  bool purchaseValid = false;
  bool stockValdi = false;
  bool codeValid = false;

  int loop = 0;
  File imageFile = File('No File');
  String imagePath = 'No Data';
  File? myFile;

  Future<void> uploadFile(String filePath) async {
    File file = File(filePath);
    try {
      EasyLoading.show(
        status: 'Uploading... ',
        dismissOnTap: false,
      );
      var snapshot = await FirebaseStorage.instance
          .ref('Product Picture/${DateTime.now().millisecondsSinceEpoch}')
          .putFile(file);
      var url = await snapshot.ref.getDownloadURL();

      setState(() {
        productPicture = url.toString();
      });
    } on firebase_core.FirebaseException catch (e) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.code.toString())));
    }
  }

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    if (!mounted) return;
    if (codeList.contains(barcodeScanRes)) {
      EasyLoading.showError('This Product Already added!');
    } else {
      if (barcodeScanRes != '-1') {
        setState(() {
          productCode = barcodeScanRes;
          promoCodeHint = barcodeScanRes;
        });
      }
    }
  }

  @override
  void initState() {
    widget.catName == null
        ? productCategory = 'Select Product Category'
        : productCategory = widget.catName;
    widget.unitsName == null
        ? productUnit = 'Select Units'
        : productUnit = widget.unitsName;
    widget.brandName == null
        ? brandName = 'Select Brands'
        : brandName = widget.brandName;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    loop++;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'Add New Product',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer(builder: (context, ref, __) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: Column(
              children: [
                FirebaseAnimatedList(
                  shrinkWrap: true,
                  query: FirebaseDatabase.instance
                      // ignore: deprecated_member_use
                      .reference()
                      .child(constUserId)
                      .child('Products'),
                  itemBuilder: (context, snapshot, animation, index) {
                    final json = snapshot.value as Map<dynamic, dynamic>;
                    final product = ProductModel.fromJson(json);
                    codeList.add(product.productCode.toLowerCase());
                    productNameList.add(product.productName.toLowerCase());
                    return Container();
                  },
                ).visible(loop <= 1),
                const SizedBox(
                  height: 10.0,
                ),
                Visibility(
                  visible: showProgress,
                  child: const CircularProgressIndicator(
                    color: primaryColor,
                    strokeWidth: 5.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: AppTextField(
                    textFieldType: TextFieldType.NAME,
                    onChanged: (value) {
                      setState(() {
                        productName = value;
                      });
                    },
                    decoration: InputDecoration(
                        label: Container(
                          width: 130,
                          child: Row(
                            children: [
                              Text("Product name"),
                              const Text(' *',
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 22))
                            ],
                          ),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        hintText: 'Enter product name',
                        border: OutlineInputBorder(),
                        errorText:
                            nameValid ? 'Please input product name!' : null),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    height: 60.0,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(color: kGreyTextColor),
                    ),
                    child: GestureDetector(
                      onTap: () async {
                        data = await const CategoryList().launch(context);
                        setState(() {
                          productCategory = data.categoryName;
                        });
                      },
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 10.0,
                          ),
                          Text(productCategory),
                          const Spacer(),
                          const Icon(Icons.keyboard_arrow_down),
                          const SizedBox(
                            width: 10.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: AppTextField(
                          textFieldType: TextFieldType.NAME,
                          onChanged: (value) {
                            setState(() {
                              size = value;
                            });
                          },
                          decoration: const InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: 'Size',
                            hintText: 'M',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ).visible(data.variations.contains('Size')),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: AppTextField(
                          textFieldType: TextFieldType.NAME,
                          onChanged: (value) {
                            setState(() {
                              color = value;
                            });
                          },
                          decoration: const InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: 'Color',
                            hintText: 'Green',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ).visible(data.variations.contains('Color')),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: AppTextField(
                          textFieldType: TextFieldType.NAME,
                          onChanged: (value) {
                            setState(() {
                              weight = value;
                            });
                          },
                          decoration: const InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: 'Weight',
                            hintText: '10 inc',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ).visible(data.variations.contains('Weight')),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: AppTextField(
                          textFieldType: TextFieldType.NAME,
                          onChanged: (value) {
                            setState(() {
                              capacity = value;
                            });
                          },
                          decoration: const InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: 'Capacity',
                            hintText: '244 liter',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ).visible(data.variations.contains('Capacity')),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: AppTextField(
                    textFieldType: TextFieldType.NAME,
                    onChanged: (value) {
                      setState(() {
                        type = value;
                      });
                    },
                    decoration: const InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: 'Type',
                      hintText: 'Usb C',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ).visible(data.variations.contains('Type')),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: AppTextField(
                          controller: productCodeController,
                          textFieldType: TextFieldType.NAME,
                          onChanged: (value) {
                            setState(() {
                              productCode = value;
                              promoCodeHint = value;
                            });
                          },
                          onFieldSubmitted: (value) {
                            if (codeList.contains(value)) {
                              EasyLoading.showError(
                                  'This Product Already added!');
                              productCodeController.clear();
                            } else {
                              setState(() {
                                productCode = value;
                                promoCodeHint = value;
                              });
                            }
                          },
                          decoration: InputDecoration(
                              label: Container(
                                width: 150,
                                child: Row(
                                  children: [
                                    Text("Product Code"),
                                    const Text(' *',
                                        style: TextStyle(
                                            color: Colors.red, fontSize: 22))
                                  ],
                                ),
                              ),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              hintText: promoCodeHint,
                              border: const OutlineInputBorder(),
                              errorText: codeValid
                                  ? 'Please enter product code'
                                  : null),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: GestureDetector(
                          onTap: () => scanBarcodeNormal(),
                          child: Container(
                            height: 60.0,
                            width: 100.0,
                            padding: const EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(color: kGreyTextColor),
                            ),
                            child: const Image(
                              image: AssetImage('images/barcode.png'),
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
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: AppTextField(
                          textFieldType: TextFieldType.NAME,
                          onChanged: (value) {
                            setState(() {
                              productStock = value;
                            });
                          },
                          decoration: InputDecoration(
                              label: Container(
                                width: 70,
                                child: Row(
                                  children: [
                                    Text("Stock"),
                                    const Text(' *',
                                        style: TextStyle(
                                            color: Colors.red, fontSize: 22))
                                  ],
                                ),
                              ),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              hintText: 'Enter stock',
                              border: OutlineInputBorder(),
                              errorText: stockValdi
                                  ? 'Please enter stock qty!'
                                  : null),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          height: 60.0,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            border: Border.all(color: kGreyTextColor),
                          ),
                          child: GestureDetector(
                            onTap: () async {
                              String data =
                                  await const UnitList().launch(context);
                              setState(() {
                                productUnit = data;
                              });
                            },
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 10.0,
                                ),
                                Text(productUnit),
                                const Spacer(),
                                const Icon(Icons.keyboard_arrow_down),
                                const SizedBox(
                                  width: 10.0,
                                ),
                              ],
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
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: AppTextField(
                          textFieldType: TextFieldType.PHONE,
                          onChanged: (value) {
                            setState(() {
                              productPurchasePrice = value;
                            });
                          },
                          decoration: InputDecoration(
                            label: Container(
                              width: 140,
                              child: Row(
                                children: [
                                  Text("Purchase Price(\$)"),
                                  const Text('*',
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 22))
                                ],
                              ),
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            hintText: 'Enter price',
                            border: OutlineInputBorder(),
                            errorText: purchaseValid
                                ? 'Please enter Purchase price!'
                                : null,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: AppTextField(
                          textFieldType: TextFieldType.PHONE,
                          onChanged: (value) {
                            setState(() {
                              productSalePrice = value;
                            });
                          },
                          decoration: InputDecoration(
                            label: Container(
                              width: 105,
                              child: Row(
                                children: [
                                  Text("Sale Price(\$)"),
                                  const Text('*',
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 22))
                                ],
                              ),
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            hintText: 'Enter price',
                            border: OutlineInputBorder(),
                            errorText:
                                saleValid ? 'Please enter Sale price!' : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Row(
                //   children: [
                //     Expanded(
                //       child: Padding(
                //         padding: const EdgeInsets.all(10.0),
                //         child: AppTextField(
                //           textFieldType: TextFieldType.PHONE,
                //           onChanged: (value) {
                //             setState(() {
                //               productWholeSalePrice = value;
                //             });
                //           },
                //           decoration: const InputDecoration(
                //             floatingLabelBehavior: FloatingLabelBehavior.always,
                //             labelText: 'WholeSale Price',
                //             hintText: '\$110',
                //             border: OutlineInputBorder(),
                //           ),
                //         ),
                //       ),
                //     ),
                //     Expanded(
                //       child: Padding(
                //           padding: const EdgeInsets.all(10.0),
                //           child: AppTextField(
                //               textFieldType: TextFieldType.NUMBER,
                //               onChanged: (value) {
                //                 setState(() {
                //                   productDealerPrice = value;
                //                 });
                //               },
                //               decoration: InputDecoration(
                //                 floatingLabelBehavior:
                //                     FloatingLabelBehavior.always,
                //                 hintText: '\$115',
                //                 border: OutlineInputBorder(),
                //                 labelText: 'Dealer price',
                //               ))),
                //     ),
                //   ],
                // ),
                Column(
                  children: [
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                // ignore: sized_box_for_whitespace
                                child: Container(
                                  height: 200.0,
                                  width: MediaQuery.of(context).size.width - 80,
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            pickedImage =
                                                await _picker.pickImage(
                                                    source:
                                                        ImageSource.gallery);
                                            setState(() {
                                              imageFile =
                                                  File(pickedImage!.path);
                                              final myFile =
                                                  File(pickedImage!.path);

                                              imagePath = pickedImage!.path;
                                            });

                                            Future.delayed(
                                                const Duration(
                                                    milliseconds: 100), () {
                                              Navigator.pop(context);
                                            });
                                          },
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.photo_library_rounded,
                                                size: 60.0,
                                                color: kMainColor,
                                              ),
                                              Text(
                                                'Gallery',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 20.0,
                                                  color: primaryColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 40.0,
                                        ),
                                        GestureDetector(
                                          onTap: () async {
                                            pickedImage =
                                                await _picker.pickImage(
                                                    source: ImageSource.camera);
                                            setState(() {
                                              imageFile =
                                                  File(pickedImage!.path);
                                              final myFile =
                                                  File(pickedImage!.path);

                                              imagePath = pickedImage!.path;
                                            });
                                            Future.delayed(
                                                const Duration(
                                                    milliseconds: 100), () {
                                              Navigator.pop(context);
                                            });
                                          },
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.camera,
                                                size: 60.0,
                                                color: kGreyTextColor,
                                              ),
                                              Text(
                                                'Camera',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 20.0,
                                                  color: kGreyTextColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            });
                      },
                      child: Stack(
                        children: [
                          imagePath == 'No Data'
                              ? Container(
                                  height: 120,
                                  width: 120,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.black54, width: 1),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(120)),
                                    image: DecorationImage(
                                      image: new AssetImage(
                                          'images/photo_cover.png'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              : Container(
                                  height: 120,
                                  width: 120,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.black54, width: 1),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(120)),
                                      image: DecorationImage(
                                        image: FileImage(File(imagePath)),
                                        fit: BoxFit.cover,
                                      )),
                                ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              height: 35,
                              width: 35,
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.white, width: 2),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(120)),
                                color: kMainColor,
                              ),
                              child: const Icon(
                                Icons.camera_alt_outlined,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
                ButtonGlobalWithoutIcon(
                  buttontext: 'Save and Publish',
                  buttonDecoration:
                      kButtonDecoration.copyWith(color: primaryColor),
                  onPressed: () async {
                    if (productName == '') {
                      setState(() => {nameValid = true});
                    } else if (productCode == '') {
                      setState(() {
                        codeValid = true;
                      });
                    } else if (productStock == '') {
                      setState(() {
                        stockValdi = true;
                        nameValid = false;
                        codeValid = false;
                      });
                    } else if (productPurchasePrice == '') {
                      setState(() {
                        purchaseValid = true;
                        stockValdi = false;
                        nameValid = false;
                        codeValid = false;
                      });
                    } else if (productSalePrice == '') {
                      setState(() {
                        purchaseValid = false;
                        stockValdi = false;
                        nameValid = false;
                        codeValid = false;
                        saleValid = true;
                      });
                    } else {
                      if (!codeList.contains(productCode.toLowerCase()) &&
                          !productNameList
                              .contains(productName.toLowerCase())) {
                        try {
                          EasyLoading.show(
                              status: 'Loading...', dismissOnTap: false);

                          imagePath == 'No Data'
                              ? null
                              : await uploadFile(imagePath);
                          // ignore: no_leading_underscores_for_local_identifiers
                          final DatabaseReference _productInformationRef =
                              FirebaseDatabase.instance
                                  .ref()
                                  .child(constUserId)
                                  .child('Products');
                          ProductModel productModel = ProductModel(
                            productName,
                            productCategory,
                            size,
                            color,
                            weight,
                            capacity,
                            type,
                            brandName,
                            productCode,
                            productStock,
                            productUnit,
                            productSalePrice,
                            productPurchasePrice,
                            productDiscount,
                            productWholeSalePrice,
                            productDealerPrice,
                            productManufacturer,
                            productPicture,
                          );
                          await _productInformationRef
                              .push()
                              .set(productModel.toJson());
                          decreaseSubscriptionSale();
                          EasyLoading.showSuccess('Added Successfully',
                              duration: const Duration(milliseconds: 500));
                          ref.refresh(productProvider);
                          Future.delayed(const Duration(milliseconds: 100), () {
                            const Home().launch(context, isNewTask: true);
                          });
                        } catch (e) {
                          EasyLoading.dismiss();
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())));
                        }
                      } else {
                        EasyLoading.showError(
                            'Product Code or Name are already added!');
                      }
                    }
                  },
                  buttonTextColor: Colors.white,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void decreaseSubscriptionSale() async {
    final ref =
        FirebaseDatabase.instance.ref('$constUserId/Subscription/products');
    var data = await ref.once();
    int beforeSale = int.parse(data.snapshot.value.toString());
    int afterSale = beforeSale - 1;
    beforeSale != -202
        ? FirebaseDatabase.instance
            .ref('$constUserId/Subscription')
            .update({'products': afterSale})
        : null;
  }
}

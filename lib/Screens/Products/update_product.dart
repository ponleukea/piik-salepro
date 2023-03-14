import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_pos/GlobalComponents/button_global.dart';
import 'package:mobile_pos/model/product_model.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../GlobalComponents/Model/category_model.dart';
import '../../constant.dart';
import '../Home/home_screen.dart';

// ignore: must_be_immutable
class UpdateProduct extends StatefulWidget {
  UpdateProduct({Key? key, this.productModel}) : super(key: key);

  ProductModel? productModel;

  @override
  // ignore: library_private_types_in_public_api
  _UpdateProductState createState() => _UpdateProductState();
}

class _UpdateProductState extends State<UpdateProduct> {
  late String productKey;
  late ProductModel updatedProductModel;
  GetCategoryAndVariationModel data =
      GetCategoryAndVariationModel(variations: [], categoryName: '');
  bool showProgress = false;
  final ImagePicker _picker = ImagePicker();
  XFile? pickedImage;
  File imageFile = File('No File');
  String imagePath = 'No Data';

  bool nameValid = false;
  bool saleValid = false;
  bool purchaseValid = false;
  bool stockValdi = false;

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
        updatedProductModel.productPicture = url.toString();
      });
    } on firebase_core.FirebaseException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.code.toString())));
    }
  }

  void getProductKey(String code) async {
    // ignore: unused_local_variable
    List<ProductModel> productList = [];
    await FirebaseDatabase.instance
        .ref(constUserId)
        .child('Products')
        .orderByKey()
        .get()
        .then((value) {
      for (var element in value.children) {
        var data = jsonDecode(jsonEncode(element.value));
        if (data['productCode'].toString() == code) {
          productKey = element.key.toString();
        }
      }
    });
  }

  @override
  void initState() {
    getProductKey(widget.productModel!.productCode);
    updatedProductModel = widget.productModel!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'Update Product',
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
                const SizedBox(
                  height: 10.0,
                ),
                Visibility(
                  visible: showProgress,
                  child: const CircularProgressIndicator(
                    color: kMainColor,
                    strokeWidth: 5.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: AppTextField(
                    initialValue: widget.productModel!.productName,
                    textFieldType: TextFieldType.NAME,
                    onChanged: (value) {
                      setState(() {
                        updatedProductModel.productName = value;
                      });
                    },
                    decoration: InputDecoration(
                        label: new Stack(children: [
                          Text("Product name  "),
                          new Positioned(
                              right: 0.0,
                              child: Text(
                                '*',
                                style:
                                    TextStyle(color: Colors.red, fontSize: 22),
                              ))
                        ]),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        hintText: 'Enter product name',
                        border: OutlineInputBorder(),
                        errorText:
                            nameValid ? 'Please input product name' : null),
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
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 10.0,
                        ),
                        Text(widget.productModel!.productCategory),
                        const Spacer(),
                        const Icon(Icons.keyboard_arrow_down),
                        const SizedBox(
                          width: 10.0,
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: AppTextField(
                          initialValue: widget.productModel!.size,
                          textFieldType: TextFieldType.NAME,
                          onChanged: (value) {
                            setState(() {
                              updatedProductModel.size = value;
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
                    ).visible(widget.productModel!.size != 'Not Provided'),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: AppTextField(
                          initialValue: widget.productModel!.color,
                          textFieldType: TextFieldType.NAME,
                          onChanged: (value) {
                            setState(() {
                              updatedProductModel.color = value;
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
                    ).visible(widget.productModel!.color != 'Not Provided'),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: AppTextField(
                          initialValue: widget.productModel!.weight,
                          textFieldType: TextFieldType.NAME,
                          onChanged: (value) {
                            setState(() {
                              updatedProductModel.weight = value;
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
                    ).visible(widget.productModel!.weight != 'Not Provided'),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: AppTextField(
                          initialValue: widget.productModel!.capacity,
                          textFieldType: TextFieldType.NAME,
                          onChanged: (value) {
                            setState(() {
                              updatedProductModel.capacity = value;
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
                    ).visible(widget.productModel!.capacity != 'Not Provided'),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: AppTextField(
                    initialValue: widget.productModel!.type,
                    textFieldType: TextFieldType.NAME,
                    onChanged: (value) {
                      setState(() {
                        updatedProductModel.type = value;
                      });
                    },
                    decoration: const InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: 'Type',
                      hintText: 'Usb C',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ).visible(widget.productModel!.type != 'Not Provided'),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    height: 60.0,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(color: kGreyTextColor),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 10.0,
                        ),
                        Text(widget.productModel!.brandName),
                        const Spacer(),
                        const Icon(Icons.keyboard_arrow_down),
                        const SizedBox(
                          width: 10.0,
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: AppTextField(
                          readOnly: true,
                          textFieldType: TextFieldType.NAME,
                          decoration: InputDecoration(
                            fillColor: greyColor,
                            filled: true,
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: 'Product Code',
                            hintText: widget.productModel!.productCode,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
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
                          initialValue: widget.productModel!.productStock,
                          textFieldType: TextFieldType.NAME,
                          //readOnly: true,
                          onChanged: (value) {
                            setState(() {
                              updatedProductModel.productStock = value;
                            });
                          },
                          decoration: InputDecoration(
                              label: new Stack(
                                children: [
                                  Text("Stock  "),
                                  new Positioned(
                                      right: 0.0,
                                      child: Text(
                                        '*',
                                        style: TextStyle(
                                            color: Colors.red, fontSize: 22),
                                      ))
                                ],
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
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 10.0,
                              ),
                              Text(widget.productModel!.productUnit),
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
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: AppTextField(
                          initialValue:
                              widget.productModel!.productPurchasePrice,
                          textFieldType: TextFieldType.PHONE,
                          onChanged: (value) {
                            setState(() {
                              updatedProductModel.productPurchasePrice = value;
                            });
                          },
                          decoration: InputDecoration(
                            label: new Stack(
                              children: [
                                Text("Purchase Price(\$)  "),
                                new Positioned(
                                    right: 0.0,
                                    child: Text(
                                      '*',
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 22),
                                    ))
                              ],
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
                          initialValue: widget.productModel!.productSalePrice,
                          textFieldType: TextFieldType.PHONE,
                          onChanged: (value) {
                            setState(() {
                              updatedProductModel.productSalePrice = value;
                            });
                          },
                          decoration: InputDecoration(
                            label: new Stack(
                              children: [
                                Text("Sale Price(\$)  "),
                                new Positioned(
                                    right: 0.0,
                                    child: Text(
                                      '*',
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 22),
                                    ))
                              ],
                            ),
                            // Container(
                            //   width: 105,
                            //   child: Row(
                            //     children: [
                            //       Text("Sale Price(\$)"),
                            //       const Text('*',
                            //           style: TextStyle(
                            //               color: Colors.red, fontSize: 22))
                            //     ],
                            //   ),
                            // ),
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
                //           initialValue: widget.productModel!.productWholeSalePrice,
                //           textFieldType: TextFieldType.PHONE,
                //           onChanged: (value) {
                //             setState(() {
                //               updatedProductModel.productWholeSalePrice = value;
                //             });
                //           },
                //           decoration: const InputDecoration(
                //             floatingLabelBehavior: FloatingLabelBehavior.always,
                //             labelText: 'WholeSale Price',
                //             hintText: '\$155',
                //             border: OutlineInputBorder(),
                //           ),
                //         ),
                //       ),
                //     ),
                //     Expanded(
                //       child: Padding(
                //         padding: const EdgeInsets.all(10.0),
                //         child: AppTextField(
                //           initialValue: widget.productModel!.productDealerPrice,
                //           textFieldType: TextFieldType.PHONE,
                //           onChanged: (value) {
                //             setState(() {
                //               updatedProductModel.productDealerPrice = value;
                //             });
                //           },
                //           decoration: const InputDecoration(
                //             floatingLabelBehavior: FloatingLabelBehavior.always,
                //             labelText: 'Dealer price',
                //             hintText: '\$130',
                //             border: OutlineInputBorder(),
                //           ),
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
                // Row(
                //   children: [
                //     Expanded(
                //         child: Padding(
                //       padding: const EdgeInsets.all(10.0),
                //       child: AppTextField(
                //         textFieldType: TextFieldType.PHONE,
                //         initialValue: widget.productModel!.productDiscount,
                //         onChanged: (value) {
                //           setState(() {
                //             updatedProductModel.productDiscount = value;
                //           });
                //         },
                //         decoration: const InputDecoration(
                //           floatingLabelBehavior: FloatingLabelBehavior.always,
                //           labelText: 'Discount',
                //           hintText: '\$34.90',
                //           border: OutlineInputBorder(),
                //         ),
                //       ),
                //     )),
                //     Expanded(
                //       child: Padding(
                //         padding: const EdgeInsets.all(10.0),
                //         child: AppTextField(
                //           initialValue: widget.productModel!.productManufacturer,
                //           textFieldType: TextFieldType.NAME,
                //           onChanged: (value) {
                //             setState(() {
                //               updatedProductModel.productManufacturer = value;
                //             });
                //           },
                //           decoration: const InputDecoration(
                //             floatingLabelBehavior: FloatingLabelBehavior.always,
                //             labelText: 'Manufacturer',
                //             hintText: 'Apple',
                //             border: OutlineInputBorder(),
                //           ),
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        pickedImage = await _picker.pickImage(
                                            source: ImageSource.gallery);
                                        setState(() {
                                          imageFile = File(pickedImage!.path);
                                          imagePath = pickedImage!.path;
                                        });
                                        Future.delayed(
                                            const Duration(milliseconds: 100),
                                            () {
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
                                              color: kMainColor,
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
                                        pickedImage = await _picker.pickImage(
                                            source: ImageSource.camera);
                                        setState(() {
                                          imageFile = File(pickedImage!.path);
                                          imagePath = pickedImage!.path;
                                        });
                                        Future.delayed(
                                            const Duration(milliseconds: 100),
                                            () {
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
                      Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black54, width: 1),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(120)),
                          image: imagePath == 'No Data'
                              ? DecorationImage(
                                  image: NetworkImage(
                                      widget.productModel!.productPicture),
                                  fit: BoxFit.cover,
                                )
                              : DecorationImage(
                                  image: FileImage(imageFile),
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          height: 35,
                          width: 35,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 2),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(120)),
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
                const SizedBox(height: 20),
                ButtonGlobalWithoutIcon(
                  buttontext: 'Save and Publish',
                  buttonDecoration:
                      kButtonDecoration.copyWith(color: kMainColor),
                  onPressed: () async {
                    if (updatedProductModel.productName == '') {
                      setState(() {
                        nameValid = true;
                      });
                    } else if (updatedProductModel.productStock == '') {
                      setState(() {
                        nameValid = false;
                        stockValdi = true;
                      });
                    } else if (updatedProductModel.productPurchasePrice == '') {
                      setState(() {
                        nameValid = false;
                        stockValdi = false;
                        purchaseValid = true;
                      });
                    } else if (updatedProductModel.productSalePrice == '') {
                      setState(() {
                        nameValid = false;
                        stockValdi = false;
                        purchaseValid = false;
                        saleValid = true;
                      });
                    } else {
                      try {
                        imagePath == 'No Data'
                            ? null
                            : await uploadFile(imagePath);
                        EasyLoading.show(
                            status: 'Loading...', dismissOnTap: false);
                        DatabaseReference ref = FirebaseDatabase.instance
                            .ref("$constUserId/Products/$productKey");
                        await ref.update({
                          'productName': updatedProductModel.productName,
                          'productCategory':
                              updatedProductModel.productCategory,
                          'size': updatedProductModel.size,
                          'color': updatedProductModel.color,
                          'weight': updatedProductModel.weight,
                          'capacity': updatedProductModel.capacity,
                          'type': updatedProductModel.type,
                          'brandName': updatedProductModel.brandName,
                          'productCode': updatedProductModel.productCode,
                          'productStock': updatedProductModel.productStock,
                          'productUnit': updatedProductModel.productUnit,
                          'productSalePrice':
                              updatedProductModel.productSalePrice,
                          'productPurchasePrice':
                              updatedProductModel.productPurchasePrice,
                          'productDiscount':
                              updatedProductModel.productDiscount,
                          'productWholeSalePrice':
                              updatedProductModel.productWholeSalePrice,
                          'productDealerPrice':
                              updatedProductModel.productDealerPrice,
                          'productManufacturer':
                              updatedProductModel.productManufacturer,
                          'productPicture': updatedProductModel.productPicture,
                        });
                        EasyLoading.showSuccess('Added Successfully',
                            duration: const Duration(milliseconds: 500));
                        //ref.refresh(productProvider);
                        Future.delayed(const Duration(milliseconds: 100), () {
                          const HomeScreen().launch(context, isNewTask: true);
                        });
                      } catch (e) {
                        EasyLoading.dismiss();
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())));
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
}

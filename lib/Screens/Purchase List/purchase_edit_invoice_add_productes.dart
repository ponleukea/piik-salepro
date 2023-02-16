import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_cart/flutter_cart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pos/Provider/product_provider.dart';
import 'package:mobile_pos/Screens/Customers/Model/customer_model.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/model/product_model.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../Provider/add_to_cart.dart';
import '../../Provider/add_to_cart_purchase.dart';
import '../../model/transition_model.dart';

// ignore: must_be_immutable
class EditPurchaseInvoiceSaleProducts extends StatefulWidget {
  EditPurchaseInvoiceSaleProducts({Key? key, @required this.catName, this.customerModel, required this.transitionModel}) : super(key: key);

  // ignore: prefer_typing_uninitialized_variables
  var catName;
  CustomerModel? customerModel;
  PurchaseTransitionModel transitionModel;

  @override
  State<EditPurchaseInvoiceSaleProducts> createState() => _EditPurchaseInvoiceSaleProductsState();
}

class _EditPurchaseInvoiceSaleProductsState extends State<EditPurchaseInvoiceSaleProducts> {
  String dropdownValue = '';
  String productCode = '0000';

  var salesCart = FlutterCart();
  String total = 'Cart Is Empty';
  int items = 0;
  String productPrice = '0';
  String sentProductPrice = '';

  @override
  void initState() {
    widget.catName == null ? dropdownValue = 'Fashion' : dropdownValue = widget.catName;
    super.initState();
  }

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode('#ff6666', 'Cancel', true, ScanMode.BARCODE);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    if (!mounted) return;

    setState(() {
      productCode = barcodeScanRes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, __) {
      final providerData = ref.watch(cartNotifierPurchase);
      final productList = ref.watch(productProvider);

      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Sales Details',
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 20.0,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 20.0,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: AppTextField(
                          textFieldType: TextFieldType.NAME,
                          onChanged: (value) {
                            setState(() {
                              productCode = value;
                            });
                          },
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: 'Product Code',
                            hintText: productCode == '0000' || productCode == '-1' ? 'Scan product QR code' : productCode,
                            border: const OutlineInputBorder(),
                          ),
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
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                productList.when(data: (products) {
                  return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: products.length,
                      itemBuilder: (_, i) {
                        if (widget.customerModel!.type.contains('Retailer')) {
                          productPrice = products[i].productSalePrice;
                        } else if (widget.customerModel!.type.contains('Dealer')) {
                          productPrice = products[i].productDealerPrice;
                        } else if (widget.customerModel!.type.contains('Wholesaler')) {
                          productPrice = products[i].productWholeSalePrice;
                        } else if (widget.customerModel!.type.contains('Supplier')) {
                          productPrice = products[i].productPurchasePrice;
                        }
                        return GestureDetector(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (_) {
                                  ProductModel tempProductModel = products[i];
                                  return AlertDialog(
                                      content: SizedBox(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                'Add Items',
                                                style: TextStyle(fontSize: 16),
                                              ),
                                              IconButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  icon: const Icon(Icons.cancel))
                                            ],
                                          ),
                                          Container(
                                            height: 1,
                                            width: double.infinity,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    products[i].productName,
                                                    style: const TextStyle(fontSize: 16),
                                                  ),
                                                  Text(
                                                    products[i].brandName,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  const Text(
                                                    'Stock',
                                                    style: TextStyle(fontSize: 16),
                                                  ),
                                                  Text(
                                                    products[i].productStock,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 20),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Expanded(
                                                child: AppTextField(
                                                  textFieldType: TextFieldType.PHONE,
                                                  onChanged: (value) {
                                                    tempProductModel.productStock = value;
                                                  },
                                                  decoration: const InputDecoration(
                                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                                    labelText: 'Quantity',
                                                    hintText: '02',
                                                    border: OutlineInputBorder(),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 20),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Expanded(
                                                child: AppTextField(
                                                  initialValue: products[i].productPurchasePrice,
                                                  keyboardType: TextInputType.number,
                                                  textFieldType: TextFieldType.NAME,
                                                  onChanged: (value) {
                                                    tempProductModel.productPurchasePrice = value;
                                                  },
                                                  decoration: const InputDecoration(
                                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                                    labelText: 'Purchase Price',
                                                    border: OutlineInputBorder(),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: AppTextField(
                                                  initialValue: products[i].productSalePrice,
                                                  keyboardType: TextInputType.number,
                                                  textFieldType: TextFieldType.NAME,
                                                  onChanged: (value) {
                                                    tempProductModel.productSalePrice = value;
                                                  },
                                                  decoration: const InputDecoration(
                                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                                    labelText: 'Sale Price',
                                                    border: OutlineInputBorder(),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 20),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Expanded(
                                                child: AppTextField(
                                                  initialValue: products[i].productWholeSalePrice,
                                                  keyboardType: TextInputType.number,
                                                  textFieldType: TextFieldType.NAME,
                                                  onChanged: (value) {
                                                    tempProductModel.productWholeSalePrice = value;
                                                  },
                                                  decoration: const InputDecoration(
                                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                                    labelText: 'WholeSale Price',
                                                    border: OutlineInputBorder(),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: AppTextField(
                                                  initialValue: products[i].productDealerPrice,
                                                  keyboardType: TextInputType.number,
                                                  textFieldType: TextFieldType.NAME,
                                                  onChanged: (value) {
                                                    tempProductModel.productDealerPrice = value;
                                                  },
                                                  decoration: const InputDecoration(
                                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                                    labelText: 'Dealer Price',
                                                    border: OutlineInputBorder(),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 20),
                                          GestureDetector(
                                            onTap: () {
                                              providerData.addToCartRiverPod(tempProductModel);
                                              providerData.addProductsInSales(products[i]);
                                              ref.refresh(productProvider);
                                              int count = 0;
                                              Navigator.popUntil(context, (route) {
                                                return count++ == 2;
                                              });
                                            },
                                            child: Container(
                                              height: 60,
                                              width: context.width(),
                                              decoration: const BoxDecoration(color: kMainColor, borderRadius: BorderRadius.all(Radius.circular(15))),
                                              child: const Center(
                                                child: Text(
                                                  'Save',
                                                  style: TextStyle(fontSize: 18, color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ));
                                });
                            // if (products[i].productStock.toInt() <= 0) {
                            //   EasyLoading.showError('Out of stock');
                            // } else {
                            //   if (widget.customerModel!.type.contains('Retailer')) {
                            //     sentProductPrice = products[i].productSalePrice;
                            //   } else if (widget.customerModel!.type.contains('Dealer')) {
                            //     sentProductPrice = products[i].productDealerPrice;
                            //   } else if (widget.customerModel!.type.contains('Wholesaler')) {
                            //     sentProductPrice = products[i].productWholeSalePrice;
                            //   } else if (widget.customerModel!.type.contains('Supplier')) {
                            //     sentProductPrice = products[i].productPurchasePrice;
                            //   }
                            //
                            //   AddToCartModel cartItem = AddToCartModel(
                            //     productName: products[i].productName,
                            //     subTotal: sentProductPrice,
                            //     productId: products[i].productCode,
                            //     productBrandName: products[i].brandName,
                            //     stock: int.parse(products[i].productStock),
                            //   );
                            //   providerData.addToCartRiverPod(cartItem);
                            //
                            //   EasyLoading.showSuccess('Added To Cart');
                            //   Navigator.pop(context);
                            // }
                          },
                          child: ProductCard(
                            productTitle: products[i].productName,
                            productDescription: products[i].brandName,
                            stock: products[i].productStock,
                            productImage: products[i].productPicture,
                          ).visible((products[i].productCode == productCode || productCode == '0000' || productCode == '-1') && productPrice != '0'),
                        );
                      });
                }, error: (e, stack) {
                  return Text(e.toString());
                }, loading: () {
                  return const Center(child: CircularProgressIndicator());
                }),
              ],
            ),
          ),
        ),
      );
    });
  }
}

// ignore: must_be_immutable
class ProductCard extends StatefulWidget {
  ProductCard({Key? key, required this.productTitle, required this.productDescription, required this.stock, required this.productImage}) : super(key: key);

  // final Product product;
  String productImage, productTitle, productDescription, stock;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  int quantity = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, __) {
      final providerData = ref.watch(cartNotifier);
      for (var element in providerData.cartItemList) {
        if (element.productName == widget.productTitle) {
          quantity = element.quantity;
        }
      }
      return Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  image: DecorationImage(image: NetworkImage(widget.productImage), fit: BoxFit.cover),
                  borderRadius: BorderRadius.circular(90.0),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.productTitle,
                        style: GoogleFonts.jost(
                          fontSize: 20.0,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    widget.productDescription,
                    style: GoogleFonts.jost(
                      fontSize: 15.0,
                      color: kGreyTextColor,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Stock',
                  style: GoogleFonts.jost(
                    fontSize: 18.0,
                    color: Colors.black,
                  ),
                ),
                Text(
                  widget.stock,
                  style: GoogleFonts.jost(
                    fontSize: 16.0,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart'; 
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pos/Provider/add_to_cart.dart';
import 'package:mobile_pos/Provider/customer_provider.dart';
import 'package:mobile_pos/Provider/profile_provider.dart';
import 'package:mobile_pos/Provider/transactions_provider.dart';
import 'package:mobile_pos/Screens/Report/Screens/sales_report_screen.dart';
import 'package:mobile_pos/Screens/Sales/sales_screen.dart';
import 'package:mobile_pos/model/transition_model.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../Provider/printer_provider.dart';
import '../../Provider/product_provider.dart';
import '../../Provider/seles_report_provider.dart';
import '../../constant.dart';
import '../../helper.dart';
import '../../model/print_transaction_model.dart';
import '../Customers/Model/customer_model.dart';
import '../Home/home.dart';

// ignore: must_be_immutable
class AddSalesScreen extends StatefulWidget {
  AddSalesScreen({Key? key, required this.customerModel}) : super(key: key); 

  CustomerModel customerModel;

  @override
  State<AddSalesScreen> createState() => _AddSalesScreenState();
}

class _AddSalesScreenState extends State<AddSalesScreen> {

  TextEditingController paidText = TextEditingController();
  int invoice = 0;
  double paidAmount = 0;
  double discountAmount = 0;
  double returnAmount = 0;
  double dueAmount = 0;
  double subTotal = 0;

  String? dropdownValue = 'Cash';
  String? selectedPaymentType;

  double calculateSubtotal({required double total}) { 
    subTotal = total - discountAmount;
    return total - discountAmount;
  }

  double calculateReturnAmount({required double total}) {
    returnAmount = total - paidAmount;
    return paidAmount <= 0 || paidAmount <= subTotal ? 0 : total - paidAmount;
  }

  double calculateDueAmount({required double total}) { 
    if (total < 0) {
      dueAmount = 0;
    } else {
      dueAmount = subTotal - paidAmount;
    }
    return returnAmount <= 0 ? 0 : subTotal - paidAmount;
  }

  late TransitionModel transitionModel = TransitionModel(
    customerName: widget.customerModel.customerName,
    customerPhone: widget.customerModel.phoneNumber,
    customerType: widget.customerModel.type,
    invoiceNumber: invoice.toString(),
    purchaseDate: DateTime.now().toString(),
  );
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, consumerRef, __) {
      final providerData = consumerRef.watch(cartNotifier);
      final printerData = consumerRef.watch(printerProviderNotifier);
      final personalData = consumerRef.watch(profileDetailsProvider);
      return personalData.when(data: (data) {
        invoice = data.invoiceCounter!.toInt();
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(
              'Add Sales',
              style: GoogleFonts.poppins( 
                color: Colors.black,
              ),
            ),
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.black),
            elevation: 0.0,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          textFieldType: TextFieldType.NAME,
                          readOnly: true,
                          initialValue: data.invoiceCounter.toString(),
                          decoration: const InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: 'Inv No.',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: AppTextField(
                          textFieldType: TextFieldType.NAME,
                          readOnly: true,
                          initialValue: transitionModel.purchaseDate,
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: 'Date',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              onPressed: () async {
                                final DateTime? picked = await showDatePicker(
                                  initialDate: selectedDate,
                                  firstDate: DateTime(2015, 8),
                                  lastDate: DateTime(2101),
                                  context: context,
                                );
                                if (picked != null && picked != selectedDate) {
                                  setState(() {
                                    selectedDate = picked;
                                    transitionModel.purchaseDate =
                                        picked.toString();
                                  });
                                }
                              },
                              icon: const Icon(FeatherIcons.calendar),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text('Due Amount: '),
                          Text(
                            widget.customerModel.dueAmount == ''
                                ? '\$ 0'
                                : '\$${widget.customerModel.dueAmount}',
                            style: const TextStyle(color: Color(0xFFFF8C34)),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      AppTextField(
                        textFieldType: TextFieldType.NAME,
                        readOnly: true,
                        initialValue: widget.customerModel.customerName,
                        decoration: const InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: 'Customer Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  ///_______Added_ItemS__________________________________________________
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10)),
                      border:
                          Border.all(width: 1, color: const Color(0xffEAEFFA)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: Color(0xffEAEFFA),
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: SizedBox(
                                width: context.width() / 1.35,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: const [
                                    Text(
                                      'Item Added',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      'Quantity',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                        ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: providerData.cartItemList.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(0),
                                  title: Text(providerData
                                      .cartItemList[index].productName
                                      .toString()),
                                  subtitle: Text(
                                      '${providerData.cartItemList[index].quantity} X ${providerData.cartItemList[index].subTotal} = ${TypesHelper.roundNum(double.parse(providerData.cartItemList[index].subTotal) * providerData.cartItemList[index].quantity)}'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 80,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                providerData
                                                    .quantityDecrease(index);
                                              },
                                              child: Container(
                                                height: 25,
                                                width: 25,
                                                decoration: const BoxDecoration(
                                                  color: kMainColor,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              12.5)),
                                                ),
                                                child: const Center(
                                                  child: Text(
                                                    '-',
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              '${providerData.cartItemList[index].quantity}',
                                              style: GoogleFonts.poppins(
                                                color: kGreyTextColor,
                                                fontSize: 15.0,
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            GestureDetector(
                                              onTap: () {
                                                providerData
                                                    .quantityIncrease(index);
                                              },
                                              child: Container(
                                                height: 25,
                                                width: 25,
                                                decoration: const BoxDecoration(
                                                  color: kMainColor,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              12.5)),
                                                ),
                                                child: const Center(
                                                    child: Text(
                                                  '+',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.white),
                                                )),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      GestureDetector(
                                        onTap: () {
                                          providerData.deleteToCart(index);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          color: Colors.red.withOpacity(0.1),
                                          child: const Icon(
                                            Icons.delete,
                                            size: 20,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                      ],
                    ).visible(providerData.cartItemList.isNotEmpty),
                  ),
                  const SizedBox(height: 20),

                  ///_______Add_Button__________________________________________________
                  GestureDetector(
                    onTap: () {
                      
                      SaleProducts(
                        catName: null,
                        customerModel: widget.customerModel,
                      ).launch(context);

                    },
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: kMainColor.withOpacity(0.1),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                      child: const Center(
                          child: Text(
                        'Add Items',
                        style: TextStyle(color: kMainColor, fontSize: 20),
                      )),
                    ),
                  ),
                  const SizedBox(height: 20),

                  ///_____Total______________________________
                  Container(
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        border:
                            Border.all(color: Colors.grey.shade300, width: 1)),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                              color: Color(0xff8BCCF0),
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(10),
                                  topLeft: Radius.circular(10))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Sub Total',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                providerData.getTotalAmount() == 0 
                                    ? '\$0.00'
                                    : '\$' +
                                        TypesHelper.roundNum(
                                            providerData.getTotalAmount()),
                                style: const TextStyle(fontSize: 16),
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
                                style: TextStyle(fontSize: 16),
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
                                      if (value.toInt() <=
                                          providerData.getTotalAmount()) {
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
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                providerData.getTotalAmount() == 0
                                    ? '\$0.00'
                                    : '\$' +
                                        TypesHelper.roundNum(calculateSubtotal(
                                            total:
                                                providerData.getTotalAmount())),
                                style: const TextStyle(fontSize: 16),
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
                                style: TextStyle(fontSize: 16),
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
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                subTotal == 0
                                    ? '\$0.00'
                                    : TypesHelper.roundNum(
                                        calculateReturnAmount(total: subTotal)
                                            .abs()),
                                style: const TextStyle(fontSize: 16),
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
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                subTotal == 0
                                    ? '\$0.00'
                                    : '\$' +
                                        TypesHelper.roundNum(calculateDueAmount(
                                            total: subTotal)),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 0.2,
                    width: double.infinity,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 10),
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
                            'Payment Type',
                            style:
                                TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                          SizedBox(
                            width: 5,
                          )
                        ],
                      ),
                      DropdownButton(
                        value: dropdownValue,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: paymentsTypeList.map((String items) {
                          return DropdownMenuItem(
                            value: items,
                            child: Text(items),
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
                  const SizedBox(height: 10),
                  Container(
                    height: 0.2,
                    width: double.infinity,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          textFieldType: TextFieldType.NAME,
                          onChanged: (value) {
                            setState(() {});
                          },
                          decoration: const InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: 'Description',
                            hintText: 'Add Note',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Container(
                        height: 60,
                        width: 100,
                        decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            color: Colors.grey.shade200),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                FeatherIcons.camera,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Image',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 16),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ).visible(false),
                  Row(
                    children: [
                      Expanded(
                          child: GestureDetector(
                        onTap: () async {
                          if (providerData.cartItemList.isNotEmpty) {
                            if (widget.customerModel.type == 'Guest' &&
                                double.parse(TypesHelper.roundNum(dueAmount)) >
                                    0) {
                              EasyLoading.showError(
                                  'Due is not available for guest');
                            } else {
                              try {
                                EasyLoading.show(
                                    status: 'Loading...', dismissOnTap: false);

                                DatabaseReference ref = FirebaseDatabase
                                    .instance
                                    .ref("$constUserId/Sales Transition");

                                dueAmount <= 0
                                    ? transitionModel.isPaid = true
                                    : transitionModel.isPaid = false;
                                dueAmount <= 0
                                    ? transitionModel.dueAmount = 0
                                    : transitionModel.dueAmount = dueAmount;
                                returnAmount < 0
                                    ? transitionModel.returnAmount =
                                        returnAmount.abs()
                                    : transitionModel.returnAmount = 0;
                                transitionModel.discountAmount = discountAmount;
                                transitionModel.totalAmount = subTotal; 
                                transitionModel.productList =
                                    providerData.cartItemList;
                                transitionModel.paymentType = dropdownValue;
                                isSubUser
                                    ? transitionModel.sellerName = subUserTitle
                                    : null;
                                transitionModel.invoiceNumber =
                                    invoice.toString();

                                int totalQuantity = 0;
                                double lossProfit = 0;
                                double totalPurchasePrice = 0;
                                double totalSalePrice = 0;
                                for (var element
                                    in transitionModel.productList!) {
                                  totalPurchasePrice = totalPurchasePrice +
                                      (double.parse(
                                              element.productPurchasePrice) *
                                          element.quantity);
                                  totalSalePrice = totalSalePrice +
                                      (double.parse(element.subTotal) *
                                          element.quantity);

                                  totalQuantity =
                                      totalQuantity + element.quantity; 
                                }
                                lossProfit = ((totalSalePrice -
                                        totalPurchasePrice.toDouble()) -
                                    double.parse(transitionModel.discountAmount
                                        .toString()));

                                transitionModel.totalQuantity = totalQuantity;
                                transitionModel.lossProfit = lossProfit;

                                await ref.push().set(transitionModel.toJson());

                                log(transitionModel.toJson());

                                ///__________StockMange_________________________________________________-

                                for (var element in providerData.cartItemList) {
                                  decreaseStock(
                                      element.productId, element.quantity);
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

                                ///________Subscription_____________________________________________________
                                decreaseSubscriptionSale();

                                ///_________DueUpdate______________________________________________________
                                getSpecificCustomers(
                                    phoneNumber:
                                        widget.customerModel.phoneNumber,
                                    due: transitionModel.dueAmount!.toInt());

                                await printerData.getBluetooth();
                                PrintTransactionModel model =
                                    PrintTransactionModel(
                                        transitionModel: transitionModel,
                                        personalInformationModel: data);

                                ///_________printer________________________________________
                                if (isPrintEnable) {
                                  if (connected) {
                                    await printerData.printTicket(
                                        printTransactionModel: model,
                                        productList: providerData.cartItemList);
                                    providerData.clearCart();
                                    consumerRef.refresh(customerProvider);
                                    consumerRef.refresh(productProvider);
                                    consumerRef.refresh(salesReportProvider);
                                    consumerRef.refresh(transitionProvider);
                                    consumerRef.refresh(profileDetailsProvider);

                                    EasyLoading.showSuccess(
                                        'Added Successfully');
                                    Future.delayed(
                                        const Duration(milliseconds: 500), () {
                                      const Home().launch(context);
                                    });
                                  } else {
                                    EasyLoading.showSuccess(
                                        'Added Successfully');
                                    // ignore: use_build_context_synchronously
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content: Text(
                                          "Please Connect The Printer First"),
                                    ));
                                    // EasyLoading.showInfo('Please Connect The Printer First');
                                    showDialog(
                                        context: context,
                                        builder: (_) {
                                          return WillPopScope(
                                            onWillPop: () async => false,
                                            child: Dialog(
                                              child: SizedBox(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    ListView.builder(
                                                      shrinkWrap: true,
                                                      itemCount: printerData
                                                              .availableBluetoothDevices
                                                              .isNotEmpty
                                                          ? printerData
                                                              .availableBluetoothDevices
                                                              .length
                                                          : 0,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return ListTile(
                                                          onTap: () async {
                                                            String select =
                                                                printerData
                                                                        .availableBluetoothDevices[
                                                                    index];
                                                            List list = select
                                                                .split("#");
                                                            // String name = list[0];
                                                            String mac =
                                                                list[1];
                                                            bool isConnect =
                                                                await printerData
                                                                    .setConnect(
                                                                        mac);
                                                            if (isConnect) {
                                                              await printerData.printTicket(
                                                                  printTransactionModel:
                                                                      model,
                                                                  productList:
                                                                      transitionModel
                                                                          .productList);
                                                              providerData
                                                                  .clearCart();
                                                              consumerRef.refresh(
                                                                  customerProvider);
                                                              consumerRef.refresh(
                                                                  productProvider);
                                                              consumerRef.refresh(
                                                                  salesReportProvider);
                                                              consumerRef.refresh(
                                                                  transitionProvider);
                                                              consumerRef.refresh(
                                                                  profileDetailsProvider);
                                                              EasyLoading
                                                                  .showSuccess(
                                                                      'Added Successfully');
                                                              Future.delayed(
                                                                  const Duration(
                                                                      milliseconds:
                                                                          500),
                                                                  () {
                                                                const Home()
                                                                    .launch(
                                                                        context);
                                                              });
                                                            }
                                                          },
                                                          title: Text(
                                                              '${printerData.availableBluetoothDevices[index]}'),
                                                          subtitle: const Text(
                                                              "Click to connect"),
                                                        );
                                                      },
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Container(
                                                      height: 1,
                                                      width: double.infinity,
                                                      color: Colors.grey,
                                                    ),
                                                    const SizedBox(height: 15),
                                                    GestureDetector(
                                                      onTap: () {
                                                        consumerRef.refresh(
                                                            customerProvider);
                                                        consumerRef.refresh(
                                                            productProvider);
                                                        consumerRef.refresh(
                                                            salesReportProvider);
                                                        consumerRef.refresh(
                                                            transitionProvider);
                                                        consumerRef.refresh(
                                                            profileDetailsProvider);
                                                        const Home()
                                                            .launch(context);
                                                      },
                                                      child: const Center(
                                                        child: Text(
                                                          'Cancel',
                                                          style: TextStyle(
                                                              color:
                                                                  kMainColor),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 15),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        });
                                  }
                                } else {
                                  providerData.clearCart();
                                  consumerRef.refresh(customerProvider);
                                  consumerRef.refresh(productProvider);
                                  consumerRef.refresh(salesReportProvider);
                                  consumerRef.refresh(transitionProvider);
                                  consumerRef.refresh(profileDetailsProvider);
                                  EasyLoading.showSuccess('Added Successfully');
                                  Future.delayed(
                                      const Duration(milliseconds: 500), () {
                                    const SalesReportScreen().launch(context);
                                  });
                                }
                                EasyLoading.showSuccess('Added Successfully');
                                // const Home().launch(context, isNewTask: true);
                              } catch (e) {
                                EasyLoading.dismiss();
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString())));
                              }
                            }
                          } else {
                            EasyLoading.showError('Add Product first');
                          }
                        },
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              border: Border.all(width: 0.5)),
                          child: const Center(
                            child: Text(
                              'Save & New',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ),
                        ),
                      )),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            if (providerData.cartItemList.isNotEmpty) {
                              if (widget.customerModel.type == 'Guest' &&
                                  double.parse(
                                          TypesHelper.roundNum(dueAmount)) >
                                      0) {
                                EasyLoading.showError(
                                    'Due is not available for guest');
                              } else {
                                try {
                                  EasyLoading.show(
                                      status: 'Loading...',
                                      dismissOnTap: false);

                                  DatabaseReference ref = FirebaseDatabase
                                      .instance
                                      .ref("$constUserId/Sales Transition");

                                  dueAmount <= 0
                                      ? transitionModel.isPaid = true
                                      : transitionModel.isPaid = false;
                                  dueAmount <= 0
                                      ? transitionModel.dueAmount = 0
                                      : transitionModel.dueAmount = dueAmount;
                                  returnAmount < 0
                                      ? transitionModel.returnAmount =
                                          returnAmount.abs()
                                      : transitionModel.returnAmount = 0;
                                  transitionModel.discountAmount =
                                      discountAmount;
                                  transitionModel.totalAmount = subTotal;
                                  transitionModel.productList =
                                      providerData.cartItemList;
                                  transitionModel.paymentType = dropdownValue;
                                  isSubUser
                                      ? transitionModel.sellerName =
                                          subUserTitle
                                      : null;
                                  transitionModel.invoiceNumber =
                                      invoice.toString();

                                  ///__________total LossProfit & quantity________________________________________________________________
                                  int totalQuantity = 0;
                                  double lossProfit = 0;
                                  double totalPurchasePrice = 0;
                                  double totalSalePrice = 0;
                                   
                                  for (var element
                                      in transitionModel.productList!) {
                                    totalPurchasePrice = totalPurchasePrice +
                                        (double.parse(
                                                element.productPurchasePrice) *
                                            element.quantity);
                                    totalSalePrice = totalSalePrice +
                                        (double.parse(element.subTotal) *
                                            element.quantity);

                                    totalQuantity =
                                        totalQuantity + element.quantity;
                                  }
                                  lossProfit = ((totalSalePrice -
                                          totalPurchasePrice.toDouble()) -
                                      double.parse(transitionModel
                                          .discountAmount
                                          .toString()));

                                  transitionModel.totalQuantity = totalQuantity;
                                  transitionModel.lossProfit = lossProfit;

                                  await ref
                                      .push()
                                      .set(transitionModel.toJson());

                                  ///__________StockMange_________________________________________________-

                                  for (var element
                                      in providerData.cartItemList) {
                                    decreaseStock(
                                        element.productId, element.quantity);
                                  }

                                  ///_______invoice_Update_____________________________________________
                                  final DatabaseReference
                                      personalInformationRef =
                                      // ignore: deprecated_member_use
                                      FirebaseDatabase.instance
                                          .ref()
                                          .child(constUserId)
                                          .child('Personal Information');

                                  await personalInformationRef
                                      .update({'invoiceCounter': invoice + 1});

                                  ///________Subscription_____________________________________________________
                                  decreaseSubscriptionSale();

                                  ///_________DueUpdate______________________________________________________
                                  getSpecificCustomers(
                                      phoneNumber:
                                          widget.customerModel.phoneNumber,
                                      due: transitionModel.dueAmount!.toInt());

                                  ///________Print_______________________________________________________

                                  PrintTransactionModel model =
                                      PrintTransactionModel(
                                          transitionModel: transitionModel,
                                          personalInformationModel: data);
                                  if (isPrintEnable) {
                                    await printerData.getBluetooth();
                                    if (connected) {
                                      await printerData.printTicket(
                                          printTransactionModel: model,
                                          productList:
                                              providerData.cartItemList);
                                      providerData.clearCart();
                                      consumerRef.refresh(customerProvider);
                                      consumerRef.refresh(productProvider);
                                      consumerRef.refresh(salesReportProvider);
                                      consumerRef.refresh(transitionProvider);
                                      consumerRef
                                          .refresh(profileDetailsProvider);

                                      EasyLoading.showSuccess(
                                          'Added Successfully');
                                      Future.delayed(
                                          const Duration(milliseconds: 500),
                                          () {
                                        const SalesReportScreen()
                                            .launch(context);
                                      });
                                    } else {
                                      EasyLoading.showSuccess(
                                          'Added Successfully');
                                      // ignore: use_build_context_synchronously
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'Please Connect The Printer First')));

                                      showDialog(
                                          context: context,
                                          builder: (_) {
                                            return WillPopScope(
                                              onWillPop: () async => false,
                                              child: Dialog(
                                                child: SizedBox(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      ListView.builder(
                                                        shrinkWrap: true,
                                                        itemCount: printerData
                                                                .availableBluetoothDevices
                                                                .isNotEmpty
                                                            ? printerData
                                                                .availableBluetoothDevices
                                                                .length
                                                            : 0,
                                                        itemBuilder:
                                                            (context, index) {
                                                          return ListTile(
                                                            onTap: () async {
                                                              String select =
                                                                  printerData
                                                                          .availableBluetoothDevices[
                                                                      index];
                                                              List list = select
                                                                  .split("#");
                                                              // String name = list[0];
                                                              String mac =
                                                                  list[1];
                                                              bool isConnect =
                                                                  await printerData
                                                                      .setConnect(
                                                                          mac);
                                                              if (isConnect) {
                                                                await printerData.printTicket(
                                                                    printTransactionModel:
                                                                        model,
                                                                    productList:
                                                                        transitionModel
                                                                            .productList);
                                                                providerData
                                                                    .clearCart();
                                                                consumerRef.refresh(
                                                                    customerProvider);
                                                                consumerRef.refresh(
                                                                    productProvider);
                                                                consumerRef.refresh(
                                                                    salesReportProvider);
                                                                consumerRef.refresh(
                                                                    transitionProvider);
                                                                consumerRef.refresh(
                                                                    profileDetailsProvider);
                                                                EasyLoading
                                                                    .showSuccess(
                                                                        'Added Successfully');
                                                                Future.delayed(
                                                                    const Duration(
                                                                        milliseconds:
                                                                            500),
                                                                    () {
                                                                  const SalesReportScreen()
                                                                      .launch(
                                                                          context);
                                                                });
                                                              }
                                                            },
                                                            title: Text(
                                                                '${printerData.availableBluetoothDevices[index]}'),
                                                            subtitle: const Text(
                                                                "Click to connect"),
                                                          );
                                                        },
                                                      ),
                                                      const SizedBox(
                                                          height: 10),
                                                      Container(
                                                        height: 1,
                                                        width: double.infinity,
                                                        color: Colors.grey,
                                                      ),
                                                      const SizedBox(
                                                          height: 15),
                                                      GestureDetector(
                                                        onTap: () {
                                                          consumerRef.refresh(
                                                              customerProvider);
                                                          consumerRef.refresh(
                                                              productProvider);
                                                          consumerRef.refresh(
                                                              salesReportProvider);
                                                          consumerRef.refresh(
                                                              transitionProvider);
                                                          consumerRef.refresh(
                                                              profileDetailsProvider);
                                                          const SalesReportScreen()
                                                              .launch(context);
                                                        },
                                                        child: const Center(
                                                          child: Text(
                                                            'Cancel',
                                                            style: TextStyle(
                                                                color:
                                                                    kMainColor),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 15),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          });
                                    }
                                  } else { 
                                    providerData.clearCart();
                                    consumerRef.refresh(customerProvider);
                                    consumerRef.refresh(productProvider);
                                    consumerRef.refresh(salesReportProvider);
                                    consumerRef.refresh(transitionProvider);
                                    consumerRef.refresh(profileDetailsProvider);
                                    EasyLoading.showSuccess(
                                        'Added Successfully');
                                    Future.delayed(
                                        const Duration(milliseconds: 500), () {
                                      const SalesReportScreen().launch(context);
                                    });
                                  }
                                } catch (e) {
                                  EasyLoading.dismiss();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.toString())));
                                }
                              }
                            } else {
                              EasyLoading.showError('Add product first');
                            }
                          },
                          child: Container(
                            height: 60,
                            decoration: const BoxDecoration(
                              color: primaryColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            child: const Center(
                              child: Text(
                                'Save',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      }, error: (e, stack) {
        return Center(
          child: Text(e.toString()),
        );
      }, loading: () {
        return const Center(child: CircularProgressIndicator());
      });
    });
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

  void decreaseSubscriptionSale() async {
    final ref =
        FirebaseDatabase.instance.ref('$constUserId/Subscription/saleNumber');
    var data = await ref.once();
    int beforeSale = int.parse(data.snapshot.value.toString());
    int afterSale = beforeSale - 1;
    beforeSale != -202
        ? FirebaseDatabase.instance
            .ref('$constUserId/Subscription')
            .update({'saleNumber': afterSale})
        : null;
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
}

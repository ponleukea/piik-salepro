import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../constant.dart';
import '../../model/transition_model.dart';

class SingleLossProfitScreen extends StatefulWidget {
  const SingleLossProfitScreen({
    Key? key,
    required this.transactionModel,
  }) : super(key: key);

  final TransitionModel transactionModel;

  @override
  State<SingleLossProfitScreen> createState() => _SingleLossProfitScreenState();
}

class _SingleLossProfitScreenState extends State<SingleLossProfitScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    log(jsonEncode(widget.transactionModel));
  }

  double getTotalProfit() {
    double totalProfit = 0;
    for (var element in widget.transactionModel.productList!) {
      double purchasePrice =
          double.parse(element.productPurchasePrice.toString()) *
              double.parse(element.quantity.toString());
      double salePrice = double.parse(element.subTotal.toString()) *
          double.parse(element.quantity.toString());

      double profit = salePrice - purchasePrice;

      if (!profit.isNegative) {
        totalProfit = totalProfit + profit;
      }
    }

    return totalProfit;
  }

  double getTotalLoss() {
    double totalLoss = 0;
    for (var element in widget.transactionModel.productList!) {
      double purchasePrice =
          double.parse(element.productPurchasePrice.toString()) *
              double.parse(element.quantity.toString());
      double salePrice = double.parse(element.subTotal.toString()) *
          double.parse(element.quantity.toString());

      double profit = salePrice - purchasePrice;

      if (profit.isNegative) {
        totalLoss = totalLoss + profit.abs();
      }
    }

    return totalLoss;
  }

  @override
  Widget build(BuildContext context) {  
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Loss/Profit Details',
          style: GoogleFonts.poppins(
            color: Colors.black,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Invoice # ${widget.transactionModel.invoiceNumber}'),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                children: [
                  Text(widget.transactionModel.customerName),
                  Text(
                    "Date: ${DateFormat.yMMMd().format(DateTime.parse(widget.transactionModel.purchaseDate))}",
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Mobile: ${widget.transactionModel.customerPhone}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Text(
                    DateFormat.jm().format(
                        DateTime.parse(widget.transactionModel.purchaseDate)),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(10),
                color: kMainColor.withOpacity(0.2),
                child: Row(
                  children: const [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Product',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Quantity',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Profit',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      'Loss',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              ListView.builder(
                  itemCount: widget.transactionModel.productList!.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    double purchasePrice = double.parse(widget.transactionModel
                            .productList![index].productPurchasePrice
                            .toString()) *
                        double.parse(widget
                            .transactionModel.productList![index].quantity
                            .toString());
                    double salePrice = double.parse(widget
                            .transactionModel.productList![index].subTotal
                            .toString()) *
                        double.parse(widget
                            .transactionModel.productList![index].quantity
                            .toString());

                    double profit = salePrice - purchasePrice;

                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              widget.transactionModel.productList![index]
                                  .productName
                                  .toString(),
                              textAlign: TextAlign.start,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: Text(
                                widget.transactionModel.productList![index]
                                    .quantity
                                    .toString(),
                                style: GoogleFonts.poppins(),
                              ),
                            ),
                          ),
                          Expanded(
                              flex: 2,
                              child: Center(
                                child: Text(
                                  !profit.isNegative
                                      ? "\$${profit.abs().toInt().toString()}"
                                      : '0',
                                  style: GoogleFonts.poppins(),
                                ),
                              )),
                          Expanded(
                            child: Center(
                              child: Text(
                                profit.isNegative
                                    ? "\$${profit.abs().toInt().toString()}"
                                    : '0',
                                style: GoogleFonts.poppins(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                  color: kMainColor.withOpacity(0.2),
                  border: const Border(
                      bottom: BorderSide(width: 1, color: Colors.grey))),
              padding: const EdgeInsets.all(10),
              child: Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Total',
                            textAlign: TextAlign.start,
                            style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            widget.transactionModel.totalQuantity.toString(),
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Expanded(
                            flex: 2,
                            child: Text(
                              "\$${getTotalProfit().toInt()}",
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                              ),
                            )),
                        Text(
                          "\$${getTotalLoss().toInt()}",
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: kMainColor.withOpacity(0.2),
                  border: const Border(
                      bottom: BorderSide(width: 1, color: Colors.grey))),
              child: Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Discount',
                            textAlign: TextAlign.start,
                            style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text(
                          "\$${widget.transactionModel.discountAmount!.toInt().toString()}",
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: kMainColor.withOpacity(0.2),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            widget.transactionModel.lossProfit!.isNegative
                                ? 'Total Loss'
                                : 'Total Profit',
                            textAlign: TextAlign.start,
                            style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text(
                          widget.transactionModel.lossProfit!.isNegative
                              ? "\$${widget.transactionModel.lossProfit!.toInt().abs()}"
                              : "\$${widget.transactionModel.lossProfit!.toInt()}",
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

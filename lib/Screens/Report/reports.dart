import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pos/Screens/Report/Screens/due_report_screen.dart';
import 'package:mobile_pos/Screens/Report/Screens/purchase_report.dart';
import 'package:mobile_pos/Screens/Report/Screens/sales_report_screen.dart';
import 'package:mobile_pos/constant.dart';
import 'package:nb_utils/nb_utils.dart';

class Reports extends StatefulWidget {
  const Reports({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ReportsState createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reports',
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
      body: Column(
        children: [
          ReportCard(
              pressed: () {
                const PurchaseReportScreen().launch(context);
              },
              iconPath: 'images/purchase1.png',
              title: 'Purchase Report'),
          ReportCard(
              pressed: () {
                const SalesReportScreen().launch(context);
              },
              iconPath: 'images/sales.png',
              title: 'Sales Report'),
          ReportCard(
              pressed: () {
                const DueReportScreen().launch(context);
              },
              iconPath: 'images/duelist.png',
              title: 'Due Report'),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class ReportCard extends StatelessWidget {
  ReportCard({
    Key? key,
    required this.pressed,
    required this.iconPath,
    required this.title,
  }) : super(key: key);
  // ignore: prefer_typing_uninitialized_variables
  var pressed;
  String iconPath, title;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: pressed,
      child: Card(
        elevation: 0.0,
        color: Colors.white,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image(
                height: 40,
                width: 40,
                image: AssetImage(iconPath),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.black,
                ),
              ),
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: Icon(
                Icons.arrow_forward_ios,
                color: kMainColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

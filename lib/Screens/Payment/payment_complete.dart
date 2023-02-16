import 'package:flutter/material.dart';
import 'package:flutter_cart/flutter_cart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pos/GlobalComponents/button_global.dart';
import 'package:mobile_pos/Screens/Home/home.dart';
import 'package:mobile_pos/constant.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../Provider/add_to_cart.dart';
import '../../Provider/seles_report_provider.dart';

class PaymentCompleted extends StatefulWidget {
  const PaymentCompleted({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _PaymentCompletedState createState() => _PaymentCompletedState();
}

class _PaymentCompletedState extends State<PaymentCompleted> {
  var cart = FlutterCart();
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, __) {
      final providerData = ref.watch(cartNotifier);
      ref.refresh(salesReportProvider);
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'Payment Complete',
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 20.0,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.0,
          actions: [
            PopupMenuButton(
              itemBuilder: (BuildContext bc) => [
                const PopupMenuItem(value: "/addPromoCode", child: Text('Add Promo Code')),
                const PopupMenuItem(value: "/addDiscount", child: Text('Add Discount')),
                const PopupMenuItem(value: "/settings", child: Text('Cancel All Product')),
                const PopupMenuItem(value: "/settings", child: Text('Vat Doesn\'t Apply')),
              ],
              onSelected: (value) {
                Navigator.pushNamed(context, '$value');
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Center(
                child: Image(
                  image: AssetImage('images/complete.png'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Card(
                  elevation: 5.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            Text(
                              'Total',
                              style: GoogleFonts.poppins(
                                fontSize: 20.0,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(
                              height: 5.0,
                            ),
                            Text(
                              providerData.getTotalAmount().toString(),
                              style: GoogleFonts.poppins(
                                fontSize: 20.0,
                                color: kGreyTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                        child: SizedBox(
                          height: 50.0,
                          width: 1.0,
                          child: Container(
                            color: kGreyTextColor,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            Text(
                              'Return',
                              style: GoogleFonts.poppins(
                                fontSize: 20.0,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(
                              height: 5.0,
                            ),
                            Text(
                              '\$00.00',
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
              const Spacer(),
              const ListTile(
                leading: Icon(
                  Icons.payment,
                  color: kGreyTextColor,
                ),
                title: Text('Invoice: #121342'),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: kGreyTextColor,
                ),
              ),
              const ListTile(
                leading: Icon(
                  Icons.payment,
                  color: kGreyTextColor,
                ),
                title: Text('Send Email'),
                trailing: Icon(
                  Icons.email,
                  color: kGreyTextColor,
                ),
              ),
              const ListTile(
                leading: Icon(
                  Icons.payment,
                  color: kGreyTextColor,
                ),
                title: Text('Send Sms'),
                trailing: Icon(
                  Icons.message_outlined,
                  color: kGreyTextColor,
                ),
              ),
              const ListTile(
                leading: Icon(
                  Icons.payment,
                  color: kGreyTextColor,
                ),
                title: Text('Received the Pin'),
                trailing: Icon(
                  Icons.local_print_shop,
                  color: kGreyTextColor,
                ),
              ),
              ButtonGlobalWithoutIcon(
                buttontext: 'Start New Sale',
                buttonDecoration: kButtonDecoration.copyWith(color: kMainColor),
                onPressed: () {
                  providerData.clearCart();
                  providerData.clearDiscount();

                  const Home().launch(context);
                },
                buttonTextColor: Colors.white,
              ),
            ],
          ),
        ),
      );
    });
  }
}

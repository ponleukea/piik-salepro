import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pos/GlobalComponents/button_global.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../Provider/customer_provider.dart';
import '../../Provider/delivery_address_provider.dart';
import '../../Provider/product_provider.dart';
import '../../Provider/profile_provider.dart';
import '../../Provider/user_role_provider.dart';
import '../../constant.dart';
import '../Home/home.dart';

class SuccessScreen extends StatelessWidget {
  SuccessScreen({Key? key, required this.email}) : super(key: key);

  final String? email;

  final CurrentUserData currentUserData = CurrentUserData();

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final userRoleData = ref.watch(allUserRoleProvider);
      ref.refresh(profileDetailsProvider);
      ref.refresh(customerProvider);
      ref.refresh(deliveryAddressProvider);
      ref.refresh(productProvider);
      return userRoleData.when(data: (data) {
        if (email == 'phone') {
          currentUserData.putUserData(userId: FirebaseAuth.instance.currentUser!.uid, isSubUser: false, title: '', email: '');
        } else {
          for (var element in data) {
            if (element.email == email) {
              currentUserData.putUserData(userId: element.databaseId, isSubUser: true, title: element.userTitle, email: element.email);
              subUserTitle = element.userTitle;
            }
          }
        }
        return Scaffold(
          resizeToAvoidBottomInset: true,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Image(image: AssetImage('images/success.png')),
              const SizedBox(height: 40.0),
              Text(
                'Congratulations',
                style: GoogleFonts.poppins(
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "You have logIn successfully!",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: kGreyTextColor,
                    fontSize: 20.0,
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: ButtonGlobalWithoutIcon(
            buttontext: 'Continue',
            buttonDecoration: kButtonDecoration.copyWith(color: kMainColor),
            onPressed: () {
              const Home().launch(context);
              // Navigator.pushNamed(context, '/home');
            },
            buttonTextColor: Colors.white,
          ),
        );
      }, error: (e, stack) {
        return Text(e.toString());
      }, loading: () {
        return const Center(child: CircularProgressIndicator());
      });
    });
  }
}

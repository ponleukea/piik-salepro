import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pos/GlobalComponents/button_global.dart';
import 'package:mobile_pos/Screens/Authentication/phone.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../constant.dart';

class OnBoard extends StatefulWidget {
  const OnBoard({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _OnBoardState createState() => _OnBoardState();
}

class _OnBoardState extends State<OnBoard> {
  PageController pageController = PageController(initialPage: 0);
  int currentIndexPage = 0;
  String buttonText = 'Next';

  List<Map<String, dynamic>> sliderList = [
    {
      "icon": 'images/onboard1.png',
      "title": 'Easy to use mobile pos',
      "description":
          'Lorem ipsum dolor sit amet, consectetuer adipisci elit, sed diam nonummy nibh euismod tincidunt u laoreet dolore magna aliquam erat volutpat. Ut wi',
    },
    {
      "icon": 'images/onboard2.png',
      "title": 'Choose your features',
      "description":
          'Lorem ipsum dolor sit amet, consectetuer adipisci elit, sed diam nonummy nibh euismod tincidunt u laoreet dolore magna aliquam erat volutpat. Ut wi',
    },
    {
      "icon": 'images/onboard3.png',
      "title": 'All business solutions',
      "description":
          'Lorem ipsum dolor sit amet, consectetuer adipisci elit, sed diam nonummy nibh euismod tincidunt u laoreet dolore magna aliquam erat volutpat. Ut wi',
    },
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0.0,
        actions: [
          const SizedBox(
            width: 20.0,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextButton(
              onPressed: () {
                const PhoneAuth().launch(context);
                // const SignInScreen().launch(context);
                // Navigator.pushNamed(context, '/signIn');
              },
              child: Text(
                'Skip',
                style: GoogleFonts.jost(
                  fontSize: 20.0,
                  color: kMainColor,
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 30.0,
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            height: 550,
            width: 340,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                PageView.builder(
                  itemCount: sliderList.length,
                  controller: pageController,
                  onPageChanged: (int index) => setState(() => currentIndexPage = index),
                  itemBuilder: (_, index) {
                    return Column(
                      children: [
                        Image.asset(sliderList[index]['icon'], fit: BoxFit.fill, width: context.width(), height: 340),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            sliderList[index]['title'].toString(),
                            style: GoogleFonts.jost(
                              fontSize: 25.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        // ignore: sized_box_for_whitespace
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                          // ignore: sized_box_for_whitespace
                          child: Container(
                            width: context.width(),
                            child: Text(
                              sliderList[index]['description'].toString(),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 5,
                              style: GoogleFonts.jost(
                                fontSize: 15.0,
                                color: kGreyTextColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          DotIndicator(
            currentDotSize: 15,
            dotSize: 6,
            pageController: pageController,
            pages: sliderList,
            indicatorColor: kMainColor,
            unselectedIndicatorColor: Colors.grey,
          ),
          ButtonGlobal(
            iconWidget: Icons.arrow_forward,
            buttontext: buttonText,
            iconColor: Colors.white,
            buttonDecoration: kButtonDecoration.copyWith(color: kMainColor),
            onPressed: () {
              setState(
                () {
                  currentIndexPage < 2
                      ? pageController.nextPage(duration: const Duration(microseconds: 1000), curve: Curves.bounceInOut)
                      : const PhoneAuth().launch(context);
                  // : const SignInScreen().launch(context);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

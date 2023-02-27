import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pos/Screens/Home/components/grid_items.dart';
import 'package:mobile_pos/Screens/Profile%20Screen/profile_details.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/model/subscription_model.dart';
import 'package:mobile_pos/model/subscription_plan_model.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../Provider/homepage_image_provider.dart';
import '../../Provider/profile_provider.dart';
import '../../model/paypal_info_model.dart';
import '../../subscription.dart';
import '../Shimmers/home_screen_appbar_shimmer.dart';
import '../subscription/package_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Color> color = [
    const Color(0xffEDFAFF),
    const Color(0xffFFF6ED),
    const Color(0xffEAFFEA),
    const Color(0xffEAFFEA),
    const Color(0xffEDFAFF),
    const Color(0xffFFF6ED),
    const Color(0xffFFF6ED),
    const Color(0xffEAFFEA),
    const Color(0xffEDFAFF),
    const Color(0xffEAFFEA),
    const Color(0xffFFF6ED),
  ];

  String customerPackage = '';
  List<Map<String, dynamic>> sliderList = [
    {
      "icon": 'images/banner1.png',
    },
    {
      "icon": 'images/banner2.png',
    }
  ];
  PageController pageController = PageController(initialPage: 0);

  // void subscriptionRemainder() async {
  //   final prefs = await SharedPreferences.getInstance();

  //   DatabaseReference ref = FirebaseDatabase.instance.ref('$constUserId/Subscription');

  //   final model = await ref.get();
  //   var data = jsonDecode(jsonEncode(model.value));
  //   final dataModel = SubscriptionModel.fromJson(data);
  //   setState(() {
  //     customerPackage = dataModel.subscriptionName;
  //   });

  //   final remainTime = DateTime.parse(dataModel.subscriptionDate).difference(DateTime.now());

  //   if (dataModel.subscriptionName != 'Lifetime') {
  //     if (remainTime.inHours.abs().isBetween((dataModel.duration * 24) - 24, dataModel.duration * 24)) {
  //       await prefs.setBool('isFiveDayRemainderShown', false);
  //       setState(() {
  //         isExpiringInOneDays = true;
  //         isExpiringInFiveDays = false;
  //       });
  //     } else if (remainTime.inHours.abs().isBetween((dataModel.duration * 24) - 120, dataModel.duration * 24)) {
  //       setState(() {
  //         isExpiringInFiveDays = true;
  //         isExpiringInOneDays = false;
  //       });
  //     }

  //     final bool? isFiveDayRemainderShown = prefs.getBool('isFiveDayRemainderShown');

  //     if (isExpiringInFiveDays && isFiveDayRemainderShown == false) {
  //       showDialog(
  //         context: context,
  //         builder: (BuildContext context) {
  //           return Dialog(
  //             child: SizedBox(
  //               height: 200,
  //               width: 200,
  //               child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 crossAxisAlignment: CrossAxisAlignment.center,
  //                 children: [
  //                   const Text(
  //                     'Your Package Will Expire in 5 Day',
  //                     style: TextStyle(fontSize: 16),
  //                   ),
  //                   const SizedBox(height: 20),
  //                   TextButton(
  //                     onPressed: () async {
  //                       await prefs.setBool('isFiveDayRemainderShown', true);
  //                       // ignore: use_build_context_synchronously
  //                       Navigator.pop(context);
  //                     },
  //                     child: const Text(
  //                       'Cancel',
  //                       style: TextStyle(color: Colors.red),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           );
  //         },
  //       );
  //     }
  //     if (isExpiringInOneDays) {
  //       showDialog(
  //         context: context,
  //         builder: (BuildContext context) {
  //           return Dialog(
  //             child: Padding(
  //               padding: const EdgeInsets.all(20.0),
  //               child: SizedBox(
  //                 child: Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   crossAxisAlignment: CrossAxisAlignment.center,
  //                   children: [
  //                     const Text(
  //                       'Your Package Will Expire Today\n\nPlease Purchase again',
  //                       style: TextStyle(fontSize: 16),
  //                       textAlign: TextAlign.center,
  //                     ),
  //                     const SizedBox(height: 20),
  //                     Column(
  //                       children: [
  //                         TextButton(
  //                           onPressed: () {
  //                             const PackageScreen().launch(context);
  //                           },
  //                           child: const Text('Purchase'),
  //                         ),
  //                         TextButton(
  //                           onPressed: () {
  //                             Navigator.pop(context);
  //                           },
  //                           child: const Text(
  //                             'Cancel',
  //                             style: TextStyle(color: Colors.red),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           );
  //         },
  //       );
  //     }
  //   }
  // }

  // Future<void> getPaypalInfo() async {
  //   DatabaseReference paypalRef = FirebaseDatabase.instance.ref('Admin Panel/Paypal Info');
  //   final paypalData = await paypalRef.get();
  //   PaypalInfoModel paypalInfoModel = PaypalInfoModel.fromJson(jsonDecode(jsonEncode(paypalData.value)));
  //   paypalClientId = paypalInfoModel.paypalClientId;
  //   paypalClientSecret = paypalInfoModel.paypalClientSecret;
  // }

  // Future<void> getAllSubscriptionPlan() async {
  //   await FirebaseDatabase.instance.ref().child('Admin Panel').child('Subscription Plan').orderByKey().get().then((value) {
  //     for (var element in value.children) {
  //       Subscription.subscriptionPlan.add(SubscriptionPlanModel.fromJson(jsonDecode(jsonEncode(element.value))));
  //     }
  //   });
  //   for (var element in Subscription.subscriptionPlan) {
  //     if (element.subscriptionName == 'Free') {
  //       Subscription.freeSubscriptionModel.products = element.products;
  //       Subscription.freeSubscriptionModel.duration = element.duration;
  //       Subscription.freeSubscriptionModel.dueNumber = element.dueNumber;
  //       Subscription.freeSubscriptionModel.partiesNumber = element.partiesNumber;
  //       Subscription.freeSubscriptionModel.purchaseNumber = element.purchaseNumber;
  //       Subscription.freeSubscriptionModel.saleNumber = element.purchaseNumber;
  //       Subscription.freeSubscriptionModel.subscriptionDate = DateTime.now().toString();
  //     }
  //   }
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //subscriptionRemainder();
    //getPaypalInfo();
    //getAllSubscriptionPlan();
  }

  @override
  Widget build(BuildContext context) {
    // print('UserId: $constUserId');
    // print('UserId: ${FirebaseAuth.instance.currentUser!.uid}');
    return SafeArea(
      child: Consumer(builder: (_, ref, __) {
        final userProfileDetails = ref.watch(profileDetailsProvider);
        final homePageImageProvider = ref.watch(homepageImageProvider);

        return Scaffold(
          resizeToAvoidBottomInset: true,
          body: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: userProfileDetails.when(data: (details) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              isSubUser
                                  ? null
                                  : const ProfileDetails().launch(context);
                            },
                            child: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    image:
                                        NetworkImage(details.pictureUrl ?? ''),
                                    fit: BoxFit.cover),
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 15.0,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isSubUser
                                    ? '${details.companyName ?? ''} [$subUserTitle]'
                                    : details.companyName ?? '',
                                style: GoogleFonts.poppins(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                customerPackage != ''
                                    ? '$customerPackage Plan'
                                    : 'Free Plan',
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          // Container(
                          //   height: 40.0,
                          //   width: 40.0,
                          //   decoration: BoxDecoration(
                          //     borderRadius: BorderRadius.circular(10.0),
                          //     color: kDarkWhite,
                          //   ),
                          //   child: Center(
                          //     child: GestureDetector(
                          //       onTap: () {
                          //         EasyLoading.showInfo('Coming Soon');
                          //       },
                          //       child: const Icon(
                          //         Icons.notifications_active,
                          //         color: kMainColor,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    );
                  }, error: (e, stack) {
                    return Text(e.toString());
                  }, loading: () {
                    return const HomeScreenAppBarShimmer();
                  }),
                ),
                Container(
                  padding: const EdgeInsets.all(1.3),
                  child: GridView.count(
                    physics: const NeverScrollableScrollPhysics(), 
                    shrinkWrap: true,
                    childAspectRatio: 1.1,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                    crossAxisCount: 3,
                    children: List.generate(
                      freeIcons.length,
                      (index) => HomeGridCards(
                        gridItems: freeIcons[index],
                        color: color[index],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  height: 1,
                  width: double.infinity,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 10),
                homePageImageProvider.when(data: (images) {
                  if (images.isNotEmpty) {
                    return SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'What\'s New',
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              GestureDetector(
                                child: const Icon(Icons.keyboard_arrow_left),
                                onTap: () {
                                  pageController.previousPage(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.linear);
                                },
                              ),
                              Container(
                                
                                padding: const EdgeInsets.all(10),
                                height: 180,
                                width: MediaQuery.of(context).size.width-50,
                                child: PageView.builder(
                                  pageSnapping: true,
                                  itemCount: images.length,
                                  controller: pageController,
                                  itemBuilder: (_, index) {
                
                                    if (images[index].imageUrl.contains(
                                        'https://firebasestorage.googleapis.com')) {
                                      return GestureDetector(  
                                        onTap: () {
                                          const PackageScreen().launch(context);
                                        },
                                        child: Image(
                                          
                                          image: NetworkImage(
                                            images[index].imageUrl,
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    } else {
                                      YoutubePlayerController videoController =
                                          YoutubePlayerController(
                                        flags: const YoutubePlayerFlags(
                                          autoPlay: false,
                                          mute: false,
                                        ),
                                        initialVideoId: images[index].imageUrl,
                                      );
                                      return YoutubePlayer(
                                        controller: videoController,
                                        showVideoProgressIndicator: true,
                                        onReady: () {},
                                      );
                                    }
                                  },
                                ),
                              ),
                              GestureDetector(
                                child: const Icon(Icons.keyboard_arrow_right),
                                onTap: () {
                                  pageController.nextPage(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.linear);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    );
                  } else {
                    return Container(
                      padding: const EdgeInsets.all(10),
                      height: 180,
                      width: 320,
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('images/banner1.png'))),
                    );
                  }
                }, error: (e, stack) {
                  return Container(
                    padding: const EdgeInsets.all(10),
                    height: 180,
                    width: 320,
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('images/banner1.png'))),
                  );
                }, loading: () {
                  return const CircularProgressIndicator();
                }),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class HomeGridCards extends StatefulWidget {
  const HomeGridCards({Key? key, required this.gridItems, required this.color})
      : super(key: key);
  final GridItems gridItems;
  final Color color;

  @override
  State<HomeGridCards> createState() => _HomeGridCardsState();
}

class _HomeGridCardsState extends State<HomeGridCards> {
  // Future<bool> subscriptionChecker({
  //   required String item,
  // }) async {
  //   final DatabaseReference subscriptionRef = FirebaseDatabase.instance.ref().child(constUserId).child('Subscription');
  //   DatabaseReference ref = FirebaseDatabase.instance.ref('$constUserId/Subscription');

  //   final model = await ref.get();
  //   var data = jsonDecode(jsonEncode(model.value));

  //   final dataModel = SubscriptionModel.fromJson(data);
  //   final remainTime = DateTime.parse(dataModel.subscriptionDate).difference(DateTime.now());

  //   ///__________get_free_packageData________________________________________________________
  //   for (var element in Subscription.subscriptionPlan) {
  //     if (dataModel.subscriptionName == element.subscriptionName) {
  //       if (element.duration == -202) {
  //         return true;
  //       } else {
  //         if (remainTime.inHours.abs() > element.duration * 24) {
  //           Subscription.freeSubscriptionModel.subscriptionDate = DateTime.now().toString();
  //           await subscriptionRef.set(Subscription.freeSubscriptionModel.toJson());
  //           final prefs = await SharedPreferences.getInstance();
  //           await prefs.setBool('isFiveDayRemainderShown', true);
  //         } else if (item == 'Sales' && dataModel.saleNumber <= 0 && dataModel.saleNumber != -202) {
  //           return false;
  //         } else if (item == 'Parties' && dataModel.partiesNumber <= 0 && dataModel.partiesNumber != -202) {
  //           return false;
  //         } else if (item == 'Purchase' && dataModel.purchaseNumber <= 0 && dataModel.purchaseNumber != -202) {
  //           return false;
  //         } else if (item == 'Products' && dataModel.products <= 0 && dataModel.products != -202) {
  //           return false;
  //         } else if (item == 'Due List' && dataModel.dueNumber <= 0 && dataModel.dueNumber != -202) {
  //           return false;
  //         }
  //         return true;
  //       }
  //     }
  //   }
  //   return true;
  // }

  // bool checkPermission({required String item}) {
  //   if (item == 'Sales' && finalUserRoleModel.salePermission) {
  //     return true;
  //   } else if (item == 'Parties' && finalUserRoleModel.partiesPermission) {
  //     return true;
  //   } else if (item == 'Purchase' && finalUserRoleModel.purchasePermission) {
  //     return true;
  //   } else if (item == 'Products' && finalUserRoleModel.productPermission) {
  //     return true;
  //   } else if (item == 'Due List' && finalUserRoleModel.dueListPermission) {
  //     return true;
  //   } else if (item == 'Stock' && finalUserRoleModel.stockPermission) {
  //     return true;
  //   } else if (item == 'Reports' && finalUserRoleModel.reportsPermission) {
  //     return true;
  //   } else if (item == 'Sales List' && finalUserRoleModel.salesListPermission) {
  //     return true;
  //   } else if (item == 'Purchase List' && finalUserRoleModel.purchaseListPermission) {
  //     return true;
  //   } else if (item == 'Loss/Profit' && finalUserRoleModel.lossProfitPermission) {
  //     return true;
  //   } else if (item == 'Expense' && finalUserRoleModel.addExpensePermission) {
  //     return true;
  //   }
  //   return false;
  // }

  @override
  Widget build(BuildContext context) {
    // ignore: avoid_unnecessary_containers
    return Consumer(builder: (context, ref, __) {
      return Card(
        elevation: 2,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () async {
                setState(() {});
                Navigator.of(context).pushNamed('/${widget.gridItems.title}');
                // isSubUser
                //     ? checkPermission(item: widget.gridItems.title)
                //         ? await subscriptionChecker(item: widget.gridItems.title)
                //             ? Navigator.of(context).pushNamed('/${widget.gridItems.title}')
                //             : EasyLoading.showError('Update your plan first,\nyour limit is over.')
                //         : EasyLoading.showError('Sorry, you have no permission to access this service')
                //     : await subscriptionChecker(item: widget.gridItems.title)
                //         ? Navigator.of(context).pushNamed('/${widget.gridItems.title}')
                //         : EasyLoading.showError('Update your plan first,\nyour limit is over.');
              },
              child: Image(
                height: 50,
                width: 50,
                image: AssetImage(
                  widget.gridItems.icon.toString(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: Text(
                widget.gridItems.title.toString(),
                style: const TextStyle(
                    fontSize: 14,
                    color: primaryColor,
                    fontWeight: FontWeight.w600),
                maxLines: 1,
              ),
            ),
          ],
        ),
      );
    });
  }
}

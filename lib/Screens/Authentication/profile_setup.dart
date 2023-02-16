import 'dart:convert';
import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_pos/GlobalComponents/button_global.dart';
import 'package:mobile_pos/Screens/Authentication/phone.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../GlobalComponents/Model/seller_info_model.dart';
import '../../constant.dart';
import '../../model/personal_information_model.dart';
import '../../model/subscription_plan_model.dart';
import '../../subscription.dart';
import '../subscription/purchase_premium_plan_screen.dart';

class ProfileSetup extends StatefulWidget {
  const ProfileSetup({Key? key, required this.loginWithPhone}) : super(key: key);

  final bool loginWithPhone;

  @override
  State<ProfileSetup> createState() => _ProfileSetupState();
}

class _ProfileSetupState extends State<ProfileSetup> {
  final CurrentUserData currentUserData = CurrentUserData();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentUserData.putUserData(userId: FirebaseAuth.instance.currentUser!.uid, isSubUser: false,title: '',email: '');

    freeSubscription();
  }

  String dropdownLangValue = 'English';
  String initialCountry = 'Bangladesh';
  String dropdownValue = 'Fashion Store';
  late String companyName, phoneNumber;
  double progress = 0.0;
  int openingBalance = 0;
  bool showProgress = false;
  String profilePicture =
      'https://firebasestorage.googleapis.com/v0/b/salespro-saas-4a6d5.appspot.com/o/Importent%20Images%2Fno_profile_pic.png?alt=media&token=29376639-ca70-4c92-a30f-d3ce905cdf53';

  final ImagePicker _picker = ImagePicker();
  XFile? pickedImage;
  File imageFile = File('No File');
  String imagePath = 'No Data';
  TextEditingController controller = TextEditingController();

  Future<void> uploadFile(String filePath) async {
    File file = File(filePath);
    try {
      EasyLoading.show(
        status: 'Uploading... ',
        dismissOnTap: false,
      );
      var snapshot = await FirebaseStorage.instance.ref('Profile Picture/${DateTime.now().millisecondsSinceEpoch}').putFile(file);
      var url = await snapshot.ref.getDownloadURL();
      setState(() {
        profilePicture = url.toString();
      });
    } on firebase_core.FirebaseException catch (e) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.code.toString())));
    }
  }

  DropdownButton<String> getCategory() {
    List<DropdownMenuItem<String>> dropDownItems = [];
    for (String category in businessCategory) {
      var item = DropdownMenuItem(
        value: category,
        child: Text(category),
      );
      dropDownItems.add(item);
    }
    return DropdownButton(
      items: dropDownItems,
      value: dropdownValue,
      onChanged: (value) {
        setState(() {
          dropdownValue = value!;
        });
      },
    );
  }

  DropdownButton<String> getLanguage() {
    List<DropdownMenuItem<String>> dropDownLangItems = [];
    for (String lang in language) {
      var item = DropdownMenuItem(
        value: lang,
        child: Text(lang),
      );
      dropDownLangItems.add(item);
    }
    return DropdownButton(
      items: dropDownLangItems,
      value: dropdownLangValue,
      onChanged: (value) {
        setState(() {
          dropdownLangValue = value!;
        });
      },
    );
  }

  void freeSubscription() async {
    await FirebaseDatabase.instance.ref().child('Admin Panel').child('Subscription Plan').orderByKey().get().then((value) {
      for (var element in value.children) {
        Subscription.subscriptionPlan.add(SubscriptionPlanModel.fromJson(jsonDecode(jsonEncode(element.value))));
      }
    });
    for (var element in Subscription.subscriptionPlan) {
      if (element.subscriptionName == 'Free') {
        Subscription.freeSubscriptionModel.products = element.products;
        Subscription.freeSubscriptionModel.duration = element.duration;
        Subscription.freeSubscriptionModel.dueNumber = element.dueNumber;
        Subscription.freeSubscriptionModel.partiesNumber = element.partiesNumber;
        Subscription.freeSubscriptionModel.purchaseNumber = element.purchaseNumber;
        Subscription.freeSubscriptionModel.saleNumber = element.purchaseNumber;
        Subscription.freeSubscriptionModel.subscriptionDate = DateTime.now().toString();
      }
    }
    final DatabaseReference subscriptionRef = FirebaseDatabase.instance.ref().child(constUserId).child('Subscription');

    await subscriptionRef.set(Subscription.freeSubscriptionModel.toJson());
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.black),
          title: Text(
            'Setup Your Profile',
            style: GoogleFonts.poppins(
              color: Colors.black,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.0,
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "Update your profile to connect your doctor with better impression",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: kGreyTextColor,
                      fontSize: 15.0,
                    ),
                  ),
                ),
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
                                        pickedImage = await _picker.pickImage(source: ImageSource.gallery);
                                        setState(() {
                                          imageFile = File(pickedImage!.path);
                                          imagePath = pickedImage!.path;
                                        });
                                        Future.delayed(const Duration(milliseconds: 100), () {
                                          Navigator.pop(context);
                                        });
                                      },
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
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
                                        pickedImage = await _picker.pickImage(source: ImageSource.camera);
                                        setState(() {
                                          imageFile = File(pickedImage!.path);
                                          imagePath = pickedImage!.path;
                                        });
                                        Future.delayed(const Duration(milliseconds: 100), () {
                                          Navigator.pop(context);
                                        });
                                      },
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
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
                          borderRadius: const BorderRadius.all(Radius.circular(120)),
                          image: imagePath == 'No Data'
                              ? DecorationImage(
                                  image: NetworkImage(profilePicture),
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
                            borderRadius: const BorderRadius.all(Radius.circular(120)),
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
                const SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    height: 60.0,
                    child: FormField(
                      builder: (FormFieldState<dynamic> field) {
                        return InputDecorator(
                          decoration: InputDecoration(
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              labelText: 'Business Category',
                              labelStyle: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 20.0,
                              ),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
                          child: DropdownButtonHideUnderline(child: getCategory()),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: AppTextField(
                    onChanged: (value) {
                      setState(() {
                        companyName = value;
                      });
                    }, // Optional
                    textFieldType: TextFieldType.NAME,
                    decoration: const InputDecoration(labelText: 'Company & Business Name', border: OutlineInputBorder()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    height: 60.0,
                    child: AppTextField(
                      readOnly: widget.loginWithPhone ? true : false,
                      textFieldType: TextFieldType.PHONE,
                      initialValue: PhoneAuth.phoneNumber,
                      onChanged: (value) {
                        setState(() {
                          phoneNumber = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        hintText: 'Enter Phone Number',
                        border: const OutlineInputBorder(),
                        prefix: CountryCodePicker(
                          padding: EdgeInsets.zero,
                          onChanged: print,
                          initialSelection: 'BD',
                          showFlag: false,
                          showDropDownButton: true,
                          alignLeft: false,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: AppTextField(
                    // ignore: deprecated_member_use
                    textFieldType: TextFieldType.ADDRESS,
                    controller: controller,
                    decoration: const InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: kGreyTextColor),
                      ),
                      labelText: 'Company Address',
                      hintText: 'Enter Full Address',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    height: 60.0,
                    child: FormField(
                      builder: (FormFieldState<dynamic> field) {
                        return InputDecorator(
                          decoration: InputDecoration(
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              labelText: 'Language',
                              labelStyle: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 20.0,
                              ),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
                          child: DropdownButtonHideUnderline(child: getLanguage()),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: AppTextField(
                    onChanged: (value) {
                      setState(() {
                        openingBalance = value.toInt();
                      });
                    }, // Optional
                    textFieldType: TextFieldType.PHONE,
                    decoration: const InputDecoration(labelText: 'Opening Balance', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(
                  height: 40.0,
                ),
                ButtonGlobal(
                  iconWidget: Icons.arrow_forward,
                  buttontext: 'Continue',
                  iconColor: Colors.white,
                  buttonDecoration: kButtonDecoration.copyWith(color: kMainColor),
                  onPressed: () async {
                    try {
                      EasyLoading.show(status: 'Loading...', dismissOnTap: false);
                      imagePath == 'No Data' ? null : await uploadFile(imagePath);

                      final DatabaseReference personalInformationRef = FirebaseDatabase.instance.ref().child(constUserId).child('Personal Information');
                      PersonalInformationModel personalInformation = PersonalInformationModel(
                        businessCategory: dropdownValue,
                        companyName: companyName,
                        phoneNumber: widget.loginWithPhone ? PhoneAuth.phoneNumber : phoneNumber,
                        countryName: controller.text,
                        language: dropdownLangValue,
                        pictureUrl: profilePicture,
                        shopOpeningBalance: openingBalance,
                        remainingShopBalance: openingBalance,
                        invoiceCounter: 1,
                      );
                      await personalInformationRef.set(personalInformation.toJson());
                      SellerInfoModel sellerInfoModel = SellerInfoModel(
                        businessCategory: dropdownValue,
                        companyName: companyName,
                        phoneNumber: widget.loginWithPhone ? PhoneAuth.phoneNumber : phoneNumber,
                        countryName: controller.text,
                        language: dropdownLangValue,
                        pictureUrl: profilePicture,
                        userID: FirebaseAuth.instance.currentUser!.uid,
                        email: FirebaseAuth.instance.currentUser!.email,
                        subscriptionDate: DateTime.now().toString(),
                        subscriptionName: 'Free',
                        subscriptionMethod: 'Not Provided',
                      );
                      await FirebaseDatabase.instance.ref().child('Admin Panel').child('Seller List').push().set(sellerInfoModel.toJson());

                      EasyLoading.showSuccess('Added Successfully', duration: const Duration(milliseconds: 1000));

                      // ignore: use_build_context_synchronously
                      const PurchasePremiumPlanScreen(
                        isCameBack: false,
                      ).launch(context);
                    } catch (e) {
                      EasyLoading.dismiss();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                    // Navigator.pushNamed(context, '/otp');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

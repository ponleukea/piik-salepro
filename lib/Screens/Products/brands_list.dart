
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pos/Screens/Products/Model/brands_model.dart';
import 'package:mobile_pos/Screens/Products/add_brans.dart';
import 'package:mobile_pos/constant.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../GlobalComponents/button_global.dart';

// ignore: must_be_immutable
class BrandsList extends StatefulWidget {
  const BrandsList({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _BrandsListState createState() => _BrandsListState();
}

class _BrandsListState extends State<BrandsList> {
  String search = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Brands',
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: AppTextField(
                      textFieldType: TextFieldType.NAME,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: 'Search',
                        prefixIcon: Icon(
                          Icons.search,
                          color: kGreyTextColor.withOpacity(0.5),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          search = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: () {
                        const AddBrands().launch(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                        height: 60.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          border: Border.all(color: kGreyTextColor),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: kGreyTextColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 20.0,
                  ),
                ],
              ),
              SingleChildScrollView(
                child: FirebaseAnimatedList(
                  controller: ScrollController(keepScrollOffset: false),
                  defaultChild: Padding(
                    padding: const EdgeInsets.only(top: 30.0, bottom: 30.0),
                    child: Loader(
                      color: Colors.white.withOpacity(0.2),
                      size: 60,
                    ),
                  ),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  query: FirebaseDatabase.instance
                      .ref()
                      .child(constUserId)
                      .child('Brands'),
                  itemBuilder: (context, snapshot, animation, index) {
                    final json = snapshot.value as Map<dynamic, dynamic>;
                    final title = BrandsModel.fromJson(json);
                    return title.brandName.contains(search)
                        ? Padding(
                            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    title.brandName,
                                    style: GoogleFonts.poppins(
                                      fontSize: 18.0,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: ButtonGlobalWithoutIcon(
                                    buttontext: 'Select',
                                    buttonDecoration: kButtonDecoration.copyWith(color: kDarkWhite),
                                    onPressed: () {
                                      Navigator.pop(context, title.brandName);
                                      // AddProduct(
                                      //   catName: title.categoryName,
                                      // ).launch(context);
                                    },
                                    buttonTextColor: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

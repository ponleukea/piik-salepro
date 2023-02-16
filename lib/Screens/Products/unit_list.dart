import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pos/Screens/Products/Model/unit_model.dart';
import 'package:mobile_pos/constant.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../GlobalComponents/button_global.dart';
import 'add_units.dart';

// ignore: must_be_immutable
class UnitList extends StatefulWidget {
  const UnitList({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _UnitListState createState() => _UnitListState();
}

class _UnitListState extends State<UnitList> {
  String search = '';
  Future<List<UnitModel>> getUnits() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref();
    List<UnitModel> list = [];
    final model = await ref.child('$constUserId/Units').get();

    var data = jsonDecode(jsonEncode(model.value));
    if (data == null) {
      return list;
    } else {
      return data;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Units',
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
                        const AddUnits().launch(context);
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
                  physics: const NeverScrollableScrollPhysics(),
                  query:
                      // ignore: deprecated_member_use
                      FirebaseDatabase.instance.reference().child(constUserId).child('Units'),
                  itemBuilder: (context, snapshot, animation, index) {
                    final json = snapshot.value as Map<dynamic, dynamic>;
                    final title = UnitModel.fromJson(json);
                    return title.unitName.contains(search)
                        ? Padding(
                            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    title.unitName,
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
                                      Navigator.pop(context, title.unitName.toString());
                                      // AddProduct(
                                      //   unitsName: title.unitName,
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

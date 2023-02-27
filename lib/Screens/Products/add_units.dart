import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pos/GlobalComponents/button_global.dart';
import 'package:mobile_pos/Provider/category,brans,units_provide.dart';
import 'package:mobile_pos/Screens/Products/Model/unit_model.dart';
import 'package:mobile_pos/constant.dart';
import 'package:nb_utils/nb_utils.dart';

class AddUnits extends StatefulWidget {
  const AddUnits({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AddUnitsState createState() => _AddUnitsState();
}

class _AddUnitsState extends State<AddUnits> {
  bool showProgress = false;
  String unitsName = '';

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, __) {
      final allUnits = ref.watch(unitsProvider);
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Image(
                image: AssetImage('images/x.png'),
              )),
          title: Text(
            'Add Unit',
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
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Visibility(
                visible: showProgress,
                child: const CircularProgressIndicator(
                  color: kMainColor,
                  strokeWidth: 5.0,
                ),
              ),
              AppTextField(
                textFieldType: TextFieldType.NAME,
                onChanged: (value) {
                  setState(() {
                    unitsName = value;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'kg',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelText: 'Unit name',
                ),
              ),
              ButtonGlobalWithoutIcon(
                buttontext: 'Save',
                buttonDecoration: kButtonDecoration.copyWith(color: kMainColor),
                onPressed: () async {
                  bool isAlreadyAdded = false;
                  allUnits.value?.forEach((element) {
                    if (element.unitName.toLowerCase().removeAllWhiteSpace() ==
                        unitsName.toLowerCase().removeAllWhiteSpace()) {
                      isAlreadyAdded = true;
                    }
                  });
                  setState(() {
                    showProgress = true;
                  });
                  final DatabaseReference unitInformationRef = FirebaseDatabase
                      .instance
                      .ref()
                      .child(constUserId)
                      .child('Units');
                  UnitModel unitModel = UnitModel(unitsName);
                  isAlreadyAdded
                      ? EasyLoading.showError('Already Added')
                      : await unitInformationRef.push().set(unitModel.toJson());
                  setState(() {
                    showProgress = false;
                    isAlreadyAdded
                        ? null
                        : ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Data Saved Successfully")));
                  });

                  // ignore: use_build_context_synchronously
                  isAlreadyAdded ? null : Navigator.pop(context);
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

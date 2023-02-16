
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pos/GlobalComponents/button_global.dart';
import 'package:mobile_pos/Provider/expense_category_proivder.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/model/expense_category_model.dart';
import 'package:nb_utils/nb_utils.dart';

class AddExpenseCategory extends StatefulWidget {
  const AddExpenseCategory({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AddExpenseCategoryState createState() => _AddExpenseCategoryState();
}

class _AddExpenseCategoryState extends State<AddExpenseCategory> {
  final CurrentUserData currentUserData = CurrentUserData();
  bool showProgress = false;
  late String categoryName;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, __) {
      final allCategory = ref.watch(expenseCategoryProvider);
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
            'Add Expense Category',
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
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                      categoryName = value;
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Fashion',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: 'Category name',
                  ),
                ),
                const SizedBox(height: 20),
                ButtonGlobalWithoutIcon(
                  buttontext: 'Save',
                  buttonDecoration: kButtonDecoration.copyWith(color: kMainColor),
                  onPressed: () async {
                    bool isAlreadyAdded = false;
                    allCategory.value?.forEach((element) {
                      if (element.categoryName.toLowerCase().removeAllWhiteSpace().contains(
                            categoryName.toLowerCase().removeAllWhiteSpace(),
                          )) {
                        isAlreadyAdded = true;
                      }
                    });
                    setState(() {
                      showProgress = true;
                    });
                    final DatabaseReference categoryInformationRef =
                        FirebaseDatabase.instance.ref().child(constUserId).child('Expense Category');

                    ExpenseCategoryModel categoryModel = ExpenseCategoryModel(
                      categoryName: categoryName,
                      categoryDescription: '',
                    );
                    isAlreadyAdded ? EasyLoading.showError('Already Added') : await categoryInformationRef.push().set(categoryModel.toJson());
                    setState(() {
                      showProgress = false;
                      isAlreadyAdded ? null : ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data Saved Successfully")));
                    });

                    ref.refresh(expenseCategoryProvider);
                    // ignore: use_build_context_synchronously
                    isAlreadyAdded ? null : Navigator.pop(context);
                  },
                  buttonTextColor: Colors.white,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

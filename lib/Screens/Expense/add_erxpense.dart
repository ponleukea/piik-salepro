
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pos/GlobalComponents/button_global.dart';
import 'package:mobile_pos/Screens/Expense/expense_category_list.dart';
import 'package:mobile_pos/Screens/Expense/expense_list.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../Provider/all_expanse_provider.dart';
import '../../constant.dart';
import '../../model/expense_model.dart';

// ignore: must_be_immutable
class AddExpense extends StatefulWidget {
  const AddExpense({
    Key? key,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AddExpenseState createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  final CurrentUserData currentUserData = CurrentUserData();
  String dropdownValue = 'Select Category';
  final dateController = TextEditingController();
  TextEditingController expanseForNameController = TextEditingController();
  TextEditingController expanseAmountController = TextEditingController();
  TextEditingController expanseNoteController = TextEditingController();
  TextEditingController expanseRefController = TextEditingController();
  List<String> paymentMethods = [
    'Cash',
    'Bank',
    'Card',
    'Mobile Payment',
    'Snacks',
  ];

  String selectedPaymentType = 'Cash';
  DropdownButton<String> getPaymentMethods() {
    List<DropdownMenuItem<String>> dropDownItems = [];
    for (String des in paymentMethods) {
      var item = DropdownMenuItem(
        value: des,
        child: Text(des),
      );
      dropDownItems.add(item);
    }
    return DropdownButton(
      items: dropDownItems,
      value: selectedPaymentType,
      onChanged: (value) {
        setState(() {
          selectedPaymentType = value!;
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }

  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2015, 8), lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool validateAndSave() {
    final form = formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, __) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            'Add Expense',
            style: GoogleFonts.poppins(
              color: Colors.black,
            ),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
          elevation: 0.0,
        ),
        body: SingleChildScrollView(
          child: SizedBox(
            width: context.width(),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      ///_______date________________________________
                      FormField(
                        builder: (FormFieldState<dynamic> field) {
                          return InputDecorator(
                            decoration: const InputDecoration(
                              suffixIcon: Icon(FeatherIcons.calendar, color: kGreyTextColor),
                              enabledBorder: OutlineInputBorder(),
                              contentPadding: EdgeInsets.all(20),
                              labelText: 'Expense Date',
                              hintText: 'Enter expense date',
                            ),
                            child: Text(
                              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                            ),
                          );
                        },
                      ).onTap(() => _selectDate(context)),
                      const SizedBox(height: 20),

                      ///_________category_______________________________________________
                      Container(
                        height: 60.0,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          border: Border.all(color: kGreyTextColor),
                        ),
                        child: GestureDetector(
                          onTap: () async {
                            dropdownValue = await const ExpenseCategoryList().launch(context);
                            setState(() {});
                          },
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 10.0,
                              ),
                              Text(dropdownValue),
                              const Spacer(),
                              const Icon(Icons.keyboard_arrow_down),
                              const SizedBox(
                                width: 10.0,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      ///________Expense_for_______________________________________________
                      TextFormField(
                          showCursor: true,
                          controller: expanseForNameController,
                          validator: (value) {
                            if (value.isEmptyOrNull) {
                              return 'Please Enter Name';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            expanseForNameController.text = value!;
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Expense For',
                            hintText: 'Enter Name',
                          )),
                      const SizedBox(height: 20),

                      ///________PaymentType__________________________________
                      FormField(
                        builder: (FormFieldState<dynamic> field) {
                          return InputDecorator(
                            decoration: const InputDecoration(
                                enabledBorder: OutlineInputBorder(),
                                contentPadding: EdgeInsets.all(8.0),
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelText: 'Payment Type'),
                            child: DropdownButtonHideUnderline(child: getPaymentMethods()),
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      ///_________________Amount_____________________________
                      TextFormField(
                        showCursor: true,
                        controller: expanseAmountController,
                        validator: (value) {
                          if (value.isEmptyOrNull) {
                            return 'please Inter Amount';
                          } else if (double.tryParse(value!) == null) {
                            return 'Enter a valid Amount';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          expanseAmountController.text = value!;
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                          labelText: 'Amount',
                          hintText: 'Enter Amount',
                        ),
                        keyboardType: TextInputType.number,
                      ),

                      const SizedBox(height: 20),

                      ///_______reference_________________________________
                      TextFormField(
                        showCursor: true,
                        controller: expanseRefController,
                        validator: (value) {
                          return null;
                        },
                        onSaved: (value) {
                          expanseRefController.text = value!;
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Reference Number',
                          hintText: 'Enter Reference Number',
                        ),
                      ),
                      const SizedBox(height: 20),

                      ///_________note____________________________________________________
                      TextFormField(
                        showCursor: true,
                        controller: expanseNoteController,
                        validator: (value) {
                          if (value == null) {
                            return 'please Inter Amount';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          expanseNoteController.text = value!;
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Note',
                          hintText: 'Enter Note',
                        ),
                      ),
                      const SizedBox(height: 20),

                      ///_______button_________________________________
                      ButtonGlobal(
                        buttontext: 'Continue',
                        buttonDecoration: kButtonDecoration.copyWith(color: kMainColor),
                        onPressed: () async {
                          if (validateAndSave()) {
                            ExpenseModel expense = ExpenseModel(
                              expenseDate: selectedDate.toString(),
                              category: dropdownValue == 'Select Category' ? '' : dropdownValue,
                              account: '',
                              amount: expanseAmountController.text,
                              expanseFor: expanseForNameController.text,
                              paymentType: selectedPaymentType,
                              referenceNo: expanseRefController.text,
                              note: expanseNoteController.text,
                            );
                            try {
                              EasyLoading.show(status: 'Loading...', dismissOnTap: false);
                              final DatabaseReference productInformationRef =
                                  FirebaseDatabase.instance.ref().child(constUserId).child('Expense');
                              await productInformationRef.push().set(expense.toJson());
                              EasyLoading.showSuccess('Added Successfully', duration: const Duration(milliseconds: 500));

                              ///____provider_refresh____________________________________________
                              ref.refresh(expenseProvider);

                              Future.delayed(const Duration(milliseconds: 100), () {
                                int count = 0;
                                Navigator.popUntil(context, (route) {
                                  return count++ == 2;
                                });
                                // Navigator.pop(context,true);
                                const ExpenseList().launch(
                                  context,
                                );
                              });
                            } catch (e) {
                              EasyLoading.dismiss();
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                            }
                          }
                        },
                        iconWidget: Icons.arrow_forward,
                        iconColor: Colors.white,
                      ),
                    ],
                  )),
            ),
          ),
        ),
      );
    });
  }
}

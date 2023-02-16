import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pos/Screens/User%20Roles/user_role_details.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../Provider/user_role_provider.dart';
import '../../constant.dart';
import 'add_user_role_screen.dart';

class UserRoleScreen extends StatefulWidget {
  const UserRoleScreen({Key? key}) : super(key: key);

  @override
  State<UserRoleScreen> createState() => _UserRoleScreenState();
}

class _UserRoleScreenState extends State<UserRoleScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, __) {
      final userRoleData = ref.watch(userRoleProvider);
      return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            'User Role',
            style: GoogleFonts.poppins(
              color: Colors.black,
            ),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
          elevation: 0.0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: userRoleData.when(data: (users) {
              if (users.isNotEmpty) {
                return ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: users.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      child: ListTile(
                        onTap: () {
                          UserRoleDetails(
                            userRoleModel: users[index],
                          ).launch(context);
                        },
                        title: Text(users[index].email),
                        subtitle: Text(users[index].userTitle),
                        trailing: const Icon(
                          (Icons.arrow_forward_ios),
                        ),
                      ),
                    );
                  },
                );
              } else {
                return const Center(child: Text("No User Role Found"));
              }
            }, error: (e, stack) {
              return Text(e.toString());
            }, loading: () {
              return const Center(child: CircularProgressIndicator());
            }),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(10.0),
          child: GestureDetector(
            onTap: () {
              const AddUserRole().launch(context);
            },
            child: Container(
              height: 50,
              decoration: const BoxDecoration(
                color: kMainColor,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: const Center(
                child: Text(
                  'Add New User Role',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   Future deleteUser(String email, String password) async {
//     try {
//       FirebaseUser user = await _auth.currentUser();
//       AuthCredential credentials = EmailAuthProvider.getCredential(email: email, password: password);
//       final sdhg = FirebaseAuth.instance.print(user);
//       final result = await user.reauthenticateWithCredential(credentials);
//       await DatabaseService(uid: result.user.uid).deleteuser(); // called from database class
//       await result.user.delete();
//       return true;
//     } catch (e) {
//       print(e.toString());
//       return null;
//     }
//   }
// }

// class DatabaseService {
//   final String uid;
//
//   DatabaseService({required this.uid});
//
//   final CollectionReference userCollection = Firestore.instance.collection('users');
//
//   Future deleteuser() {
//     return userCollection.document(uid).delete();
//   }
// }

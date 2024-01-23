import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gradution_project2/bussines_logic/cubit/phone_auth_cubit.dart';
import 'package:gradution_project2/constant/strings.dart';
import 'package:gradution_project2/presentation/widgets/constant_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? userEmail;
  String? userPhoneNumber;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      setState(() {
        userEmail = user.email;
        userPhoneNumber = user.phoneNumber;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PhoneAuthCubit(),
      child: SafeArea(
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Column(
                children: <Widget>[
                  const ConstantWidget(),
                  const SizedBox(
                    height: 60,
                  ),
                  if (userEmail != null)
                    Text(
                      'المستخدم: $userEmail',
                      style: const TextStyle(fontSize: 18),
                    ),
                  if (userPhoneNumber != null)
                    Text(
                      'رقم الهاتف: $userPhoneNumber',
                      style: const TextStyle(fontSize: 24),
                    ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 40),
                        backgroundColor: Colors.blue),
                    onPressed: () async {
                      PhoneAuthCubit phoneAuthCubit =
                          BlocProvider.of<PhoneAuthCubit>(context);
                      GoogleSignIn googleSignIn = GoogleSignIn();

                      try {
                        await googleSignIn.disconnect();
                      } catch (error) {
                        print("Error disconnecting Google Sign In: $error");
                      }

                      try {
                        await FirebaseAuth.instance.signOut();
                      } catch (error) {
                        print("Error signing out of Firebase: $error");
                      }

                      await phoneAuthCubit.logOut();

                      Navigator.of(context).pushNamedAndRemoveUntil(
                        choseLogin,
                        (route) => false,
                      );
                    },
                    icon:
                        const Icon(Icons.logout_outlined, color: Colors.white),
                    label: const Text(
                      "تسجيل الخروج",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

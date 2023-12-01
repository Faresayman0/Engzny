import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gradution_project2/constant/strings.dart';
import 'package:gradution_project2/presentation/widgets/constant_widget.dart';

class ChoseLogin extends StatefulWidget {
  const ChoseLogin({super.key});

  @override
  State<ChoseLogin> createState() => _ChoseLoginState();
}

class _ChoseLoginState extends State<ChoseLogin> {
  bool isLoading = false;

  Future signInWithGoogle(BuildContext context) async {
    isLoading = true;
    setState(() {});
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      isLoading = false;
      setState(() {});
      return;
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);
    // ignore: use_build_context_synchronously
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.rightSlide,
      title: '',
      desc: "تم تسجيل الدخول بنجاح",
      btnOkOnPress: () {
        Navigator.of(context).pushReplacementNamed(navBar);
      },
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 200,
                        child: ConstantWidget(),
                      ),
                      const SizedBox(
                        height: 90,
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: TextButton(
                            style: TextButton.styleFrom(
                                backgroundColor: Colors.blue),
                            onPressed: () async {
                              setState(() {
                                isLoading = true;
                              });
                              await Navigator.pushNamed(context, loginScreen);

                              setState(() {
                                isLoading = false;
                              });
                            },
                            child: const Text(
                              "تسجيل الدخول باستخدام رقم الهاتف",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            )),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Row(
                        children: [
                          Expanded(child: Divider()),
                          Text("or"),
                          Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  onPressed: () {
                                    signInWithGoogle(context);
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "تسجل الدخول باستخدام جوجل  ",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      ),
                                      Image.asset(
                                        "asset/images/search.png",
                                        height: 20,
                                      )
                                    ],
                                  )),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(flex: 1),
                      const Text(
                        "powered by",
                        style: TextStyle(color: Colors.blue, fontSize: 20),
                      ),
                      const Text(
                        "Engzny Team",
                      ),
                    ],
                  ),
                )),
    );
  }
}

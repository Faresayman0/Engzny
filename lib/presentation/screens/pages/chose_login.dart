import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gradution_project2/constant/strings.dart';
import 'package:gradution_project2/presentation/widgets/constant_widget.dart';

class ChoseLogin extends StatelessWidget {
  const ChoseLogin({super.key});
  Future signInWithGoogle(context) async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      return;
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);
    Navigator.of(context).pushNamedAndRemoveUntil(navBar, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 200,
              child: ConstantWidget(),
            ),
            const SizedBox(height: 90,),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: TextButton(
                  style: TextButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: () {
                    Navigator.pushNamed(context, loginScreen);
                  },
                  child: const Text(
                    "login with your phone number",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  )),
            ),
            const SizedBox(height: 20,),
            const Row(children: [Expanded(child: Divider()),Text("or"),Expanded(child: Divider()),],),
            const SizedBox(height: 20,),
            Container(child: Column(children: [
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
                        "login with google  ",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      Image.asset(
                        "asset/images/search.png",
                        height: 20,
                        
                      )
                    ],
                  )),
            ),
            ],),),
            const Spacer(flex: 1),
            const Text("powered by",style: TextStyle(color: Colors.blue,fontSize: 20),),
            const Text("Engzny Team",),
          ],
        ),
      )),
    );
  }
}

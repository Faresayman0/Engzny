import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:gradution_project2/presentation/screens/pages/chose_login.dart';
import 'package:page_transition/page_transition.dart';

class AnimitedSplashScreen extends StatelessWidget {
  const AnimitedSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
        splashTransition: SplashTransition.decoratedBoxTransition,
        pageTransitionType:PageTransitionType.bottomToTop ,
        splashIconSize: 650,
        backgroundColor: Colors.blue,
        splash: ListView(
          
          children: [
            Column(children: [
              Image.asset(
                "asset/images/Directions-pana 1.png",
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.centerRight,
                  child: const Text(
                    "طريقك لتعرف علي مواقف مصر",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  )),
              Container(
                padding: const EdgeInsets.all(10),
                alignment: Alignment.centerRight,
                child: const Text("السفر من محافظة الى محافظة بقى اسهل معانا",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold)),
              )
            ]),
          ],
        ),
        nextScreen: const ChoseLogin() );
  }

  
}

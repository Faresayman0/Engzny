import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gradution_project2/app_routes.dart';
import 'package:gradution_project2/bussines_logic/cubit/phone_auth_cubit.dart';
import 'package:gradution_project2/constant/strings.dart';
import 'package:gradution_project2/firebase_options.dart';
import 'package:gradution_project2/presentation/screens/pages/chose_login.dart';

late String intialRoute;
void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseAuth.instance.authStateChanges().listen((user) {
    if (user == null) {
      intialRoute = animitedSplashScreen;
    } else {
      intialRoute = navBar;
    }
  });

  runApp(GradutionProject(
    appRouter: AppRouter(),
    phoneAuthCubit: PhoneAuthCubit(),
  ));
}

class GradutionProject extends StatelessWidget {
  final AppRouter appRouter;
  final PhoneAuthCubit phoneAuthCubit;

  const GradutionProject(
      {super.key, required this.appRouter, required this.phoneAuthCubit});
  @override
  Widget build(BuildContext context) {
    return BlocProvider<PhoneAuthCubit>.value(
      value: phoneAuthCubit,
      child: MaterialApp(
        theme: ThemeData(fontFamily: "LamaSans",),
        debugShowCheckedModeBanner: false,
        home: const ChoseLogin(),
        onGenerateRoute: appRouter.generateRoute,
        initialRoute: intialRoute,
      ),
    );
  }
}

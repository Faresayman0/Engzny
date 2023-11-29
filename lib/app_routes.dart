import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gradution_project2/bussines_logic/cubit/phone_auth_cubit.dart';
import 'package:gradution_project2/constant/strings.dart';
import 'package:gradution_project2/presentation/screens/auth/login_screen.dart'; // Import the LoginScreen class
import 'package:gradution_project2/presentation/screens/auth/otp_screen.dart';
import 'package:gradution_project2/presentation/screens/pages/chose_login.dart';
import 'package:gradution_project2/presentation/screens/pages/home_page.dart';
import 'package:gradution_project2/presentation/widgets/navbar.dart';

class AppRouter {
  PhoneAuthCubit? phoneAuthCubit;
  AppRouter() {
    phoneAuthCubit = PhoneAuthCubit();
  }

  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case homePage:
        return MaterialPageRoute(
            builder: (_) => BlocProvider<PhoneAuthCubit>.value(
                  value: phoneAuthCubit!,
                  child: const HomePage(),
                ));
      case loginScreen:
        return MaterialPageRoute(
            builder: (_) => BlocProvider<PhoneAuthCubit>.value(
                  value: phoneAuthCubit!,
                  child: LoginScreen(),
                ));

      case otpScreen:
        final phoneNumber = settings.arguments;
        return MaterialPageRoute(
            builder: (_) => BlocProvider.value(
                  value: phoneAuthCubit!,
                  child: OtpScreen(
                    phoneNumber: phoneNumber,
                  ),
                ));
      case navBar:
        return MaterialPageRoute(
            builder: (_) => BlocProvider<PhoneAuthCubit>.value(
                  value: phoneAuthCubit!,
                  child: Navbar(),
                ));
      case choseLogin:
        return MaterialPageRoute(
            builder: (_) => BlocProvider<PhoneAuthCubit>.value(
                  value: phoneAuthCubit!,
                  child: const ChoseLogin(),
                ));
    }
    return null;
  }
}

import 'dart:async';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gradution_project2/bussines_logic/cubit/phone_auth_cubit.dart';
import 'package:gradution_project2/constant/my_color.dart';
import 'package:gradution_project2/constant/strings.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpScreen extends StatefulWidget {
  final phoneNumber;
  const OtpScreen({Key? key, required this.phoneNumber}) : super(key: key);
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  late String otpCode;
  int _start = 10;
  late Timer _timer;
  bool _timerExpired = false;

  GlobalKey<FormState> otpKey = GlobalKey();
  TextEditingController otpController = TextEditingController();

  Widget _buildIntroTexts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.centerRight,
          child: const Text(
            'التحقق من رقم الهاتف',
            style: TextStyle(
                color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          child: RichText(
            text: TextSpan(
              text: 'ادخل 6 ارقام الذي تم ارسالهم الي ',
              style: const TextStyle(
                  color: Colors.black, fontSize: 18, height: 1.4),
              children: <TextSpan>[
                TextSpan(
                  text: '${widget.phoneNumber}',
                  style: TextStyle(color: MyColor.blue),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void showProgressIndicator(BuildContext context) {
    AlertDialog alertDialog = const AlertDialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
        ),
      ),
    );

    showDialog(
      barrierColor: Colors.white.withOpacity(0),
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return alertDialog;
      },
    );
  }

  Widget _buildPinCodeFields(BuildContext context) {
    return Container(
      child: PinCodeTextField(
        validator: (String? val) {
          if (val == null || val.isEmpty || val.length < 6) {
            return "ادخل كل الارقام ";
          }
          return null;
        },
        appContext: context,
        autoFocus: true,
        cursorColor: Colors.black,
        keyboardType: TextInputType.number,
        length: 6,
        obscureText: false,
        animationType: AnimationType.scale,
        pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(5),
            fieldHeight: 50,
            fieldWidth: 40,
            borderWidth: 1,
            activeColor: MyColor.blue,
            inactiveColor: MyColor.blue,
            inactiveFillColor: Colors.white,
            activeFillColor: MyColor.lightBlue,
            selectedColor: MyColor.blue,
            selectedFillColor: Colors.white,
            errorBorderColor: Colors.red),
        animationDuration: const Duration(milliseconds: 300),
        backgroundColor: Colors.white,
        enableActiveFill: true,
        onCompleted: (submitedCode) {
          otpCode = submitedCode;
          _login(context);
        },
      ),
    );
  }

  void _login(BuildContext context) {
    showProgressIndicator(context);

    if (otpCode.isEmpty) {
      return;
    }

    BlocProvider.of<PhoneAuthCubit>(context).submitOTP(otpCode);
  }

  Widget _buildVrifyButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        onPressed: () {
          if ((otpKey.currentState!.validate())) {
            showProgressIndicator(context);

            _login(context);
          }
        },
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(500, 50),
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: const Text(
          'الدخول',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildPhoneVerificationBloc() {
    return BlocListener<PhoneAuthCubit, PhoneAuthState>(
      listenWhen: (previous, current) {
        return previous != current;
      },
      listener: (context, state) {
        if (state is Loading) {
          showProgressIndicator(context);
        }

        if (state is PhoneOTPVerified) {
          Navigator.pop(context);
          

          AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.rightSlide,
            title: '',
            desc: 'تم التسجيل بنجاح',
            btnOkOnPress: () {
              Navigator.of(context)
              .pushNamedAndRemoveUntil(navBar, (route) => false);
            },
          ).show();
          
        }
        if (state is ErrorOccurred) {
          Navigator.of(context).pushReplacementNamed("otpScreen");
          
          String errorMsg = (state).errorMsg;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: Colors.black,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: Container(),
    );
  }

  @override
  void initState() {
    startTimer();
    super.initState();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          timer.cancel();
          setState(() {
            _timerExpired = true;
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 88),
          child: ListView(
            children: [
              Form(
                key: otpKey,
                child: Column(
                  children: [
                    _buildIntroTexts(),
                    const SizedBox(
                      height: 88,
                    ),
                    _buildPinCodeFields(context),
                    if (_timerExpired)
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          "تعديل رقم الهاتف",
                          style: TextStyle(),
                        ),
                      ),
                    const SizedBox(
                      height: 60,
                    ),
                    _buildVrifyButton(context),
                    _buildPhoneVerificationBloc(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

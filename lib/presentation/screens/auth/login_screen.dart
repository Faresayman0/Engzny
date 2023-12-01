import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_launcher_icons/xml_templates.dart';
import 'package:gradution_project2/bussines_logic/cubit/phone_auth_cubit.dart';
import 'package:gradution_project2/constant/my_color.dart';
import 'package:gradution_project2/constant/strings.dart';
import 'package:gradution_project2/presentation/widgets/constant_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late String phoneNumber;

  GlobalKey<FormState> phoneFormKey = GlobalKey();

  TextEditingController phoneController = TextEditingController();

  bool isLoadin = false;

  Widget _buildFormFeild() {
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            decoration: BoxDecoration(
                border: Border.all(
                  color: MyColor.lightGrey,
                ),
                borderRadius: BorderRadius.circular(10)),
            child: Text(
              "${generateCountryFlag()} +20",
              style: const TextStyle(fontSize: 18, letterSpacing: 1),
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          flex: 3,
          child: Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(10)),
              child: TextFormField(
                maxLength: 11,
                controller: phoneController,
                cursorColor: Colors.black,
                style: const TextStyle(fontSize: 18, letterSpacing: 2),
                autofocus: true,
                keyboardType: TextInputType.phone,
                decoration:  const InputDecoration(
                  labelText: " رقم الهاتف",
                    focusColor: Colors.blue,
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2)),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue))),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "ادخل رقم هاتفك";
                  } else if (value.length < 11) {
                    return "اكمل باقي الرقم";
                  }
                  if (value == 11) {
                    _register;
                  }
                  return null;
                },
                onSaved: (value) {
                  phoneNumber = value!;
                },
              )),
        )
      ],
    );
  }

  String generateCountryFlag() {
    String countryCode = "eg";

    String flag = countryCode.toUpperCase().replaceAllMapped(RegExp(r"[A-Z]"),
        (match) => String.fromCharCode(match.group(0)!.codeUnitAt(0) + 127397));
    return flag;
  }

  Future<void> _register(BuildContext context) async {
    if (!phoneFormKey.currentState!.validate()) {
      Navigator.pop(context);
    } else {
      Navigator.pop(context);
      phoneFormKey.currentState!.save();
      BlocProvider.of<PhoneAuthCubit>(context).submitPhoneNumber(phoneNumber);
    }
  }

  Widget _buildNextButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if ((phoneFormKey.currentState!.validate())) {
          showProgressIndecator(context);
          _register(context);
        }
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: MyColor.blue,
          minimumSize: const Size(double.infinity, 50)),
      child: const Text(
        "التالي",
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }

  void showProgressIndecator(BuildContext context) {
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
        barrierDismissible: false,
        barrierColor: Colors.white.withOpacity(0),
        context: context,
        builder: (context) {
          return alertDialog;
        });
  }

  Widget _buildPhoneNumberSubmitedBloc() {
    return BlocListener<PhoneAuthCubit, PhoneAuthState>(
      listenWhen: (previos, curent) {
        return previos != curent;
      },
      listener: (context, stat) {
        if (stat is Loading) {
          showProgressIndecator(context);
        }
        if (stat is PhoneNumberSubmited) {
          Navigator.pop(context);
          Navigator.of(context).pushNamed(
            otpScreen,
            arguments: phoneNumber,
          );
        }
        if (stat is ErrorOccurred) {
          Navigator.pop(context);
          String errorMsg = (stat).errorMsg;

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.black,
            duration: const Duration(seconds: 3),
          ));
        }
      },
      child: Container(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: (Scaffold(
        body: Form(
            key: phoneFormKey,
            child: ListView(
              children: [
                Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 200, child: ConstantWidget()),
                        const SizedBox(
                          height: 50,
                        ),
                        _buildFormFeild(),
                        const SizedBox(
                          height: 70,
                        ),
                        _buildNextButton(context),
                        _buildPhoneNumberSubmitedBloc()
                      ],
                    ),
                  ),
                ),
              ],
            )),
      )),
    );
  }
}

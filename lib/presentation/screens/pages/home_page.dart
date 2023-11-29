import 'package:auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gradution_project2/bussines_logic/cubit/phone_auth_cubit.dart';
import 'package:gradution_project2/constant/strings.dart';
import 'package:gradution_project2/presentation/screens/components/drop_down.dart';
import 'package:gradution_project2/presentation/widgets/constant_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
    String? selectedCity;

 Map cityDestinations = {
    'الفيوم': [
      {
        "حلوان": {
          "سعر الاجره": 4,
          "نمرة السيارة": "ا ب ج 456",
          "التقييم": "4.2",
          "عددالعربيات": "10/6"
        }
      },{
        "حلوان": {
          "سعر الاجره": 4,
          "نمرة السيارة": "ا ب ج 456",
          "التقييم": "4.2",
          "عددالعربيات": "10/6"
        }
      },{
        "حلوان": {
          "سعر الاجره": 4,
          "نمرة السيارة": "ا ب ج 456",
          "التقييم": "4.2",
          "عددالعربيات": "10/6"
        }
      },{
        "حلوان": {
          "سعر الاجره": 4,
          "نمرة السيارة": "ا ب ج 456",
          "التقييم": "4.2",
          "عددالعربيات": "10/6"
        }
      },
      {
        "السلام": {
          "سعر الاجره": 5,
          "نمرة السيارة": "ا ب ج 123",
          "التقييم": 4.3,
          "عددالعربيات": "10/6"
        }
      }
    ],
    'حلوان': [
      {
        "المعصره": {
          "سعر الاجره": 4,
          "نمرة السيارة": "ا ب ج 456",
          "التقييم": "4.2",
          "عددالعربيات": "10/6"
        }
      },
      {
        "المنيب": {
          "سعر الاجره": 5,
          "نمرة السيارة": "ا ب ج 123",
          "التقييم": 4.3,
          "عددالعربيات": "10/6"
        }
      }
    ],
    'السلام': [
      {
        "بنها": {
          "سعر الاجره": 4,
          "نمرة السيارة": "ا ب ج 456",
          "التقييم": "4.2",
          "عددالعربيات": "10/6"
        }
      },
      {
        "المنيب": {
          "سعر الاجره": 5,
          "نمرة السيارة": "ا ب ج 123",
          "التقييم": 4.3,
          "عددالعربيات": "10/6"
        }
      }
    ],
    'التحرير': [
      {
        "حلوان": {
          "سعر الاجره": 4,
          "نمرة السيارة": "ا ب ج 456",
          "التقييم": "4.2",
          "عددالعربيات": "10/6"
        }
      },
      {
        "المنيب": {
          "سعر الاجره": 5,
          "نمرة السيارة": "ا ب ج 123",
          "التقييم": 4.3,
          "عددالعربيات": "10/6"
        }
      }
    ],
  };

  @override
  PhoneAuthCubit phoneAuthCubit = PhoneAuthCubit();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(automaticallyImplyLeading: false,actions: [
          BlocProvider(
            create: (context) => PhoneAuthCubit(),
            child: IconButton(
                onPressed: () async {
                  GoogleSignIn googleSignIn=GoogleSignIn();
                  googleSignIn.disconnect();
                  await phoneAuthCubit.logOut();
                  Navigator.of(context).pushReplacementNamed(choseLogin);
                },
                icon: const Icon(Icons.logout)),
          )
        ]),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
               const SizedBox(
                height: 200,
                child: ConstantWidget(),
              ),
              const SizedBox(
                height: 20,
              ),
              MyDropdownButton(
                cityDestinations: cityDestinations,
                onCityChanged: (String? newValue) {
                  setState(() {
                    selectedCity = newValue;
                  });
                },
              ),
              const SizedBox(height: 20),
              if (selectedCity != null &&
                  cityDestinations.containsKey(selectedCity))
                Column(
                  children: [
                    for (var destination in cityDestinations[selectedCity]!)
                      buildCityWidget(destination),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCityWidget(Map destination) {
    String cityName = destination.keys.first;
    Map cityInfo = destination[cityName];

    return Container(
      height: 100,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey[200],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                '$selectedCity',
                style: const TextStyle(fontSize: 20),
              ),
              const Icon(Icons.arrow_forward),
              Text(
                cityName,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(
                height: 40,
              )
            ],
          ),
          const Divider(
            endIndent: 20,
            indent: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'ج ${cityInfo["سعر الاجره"]}',
                style: const TextStyle(fontSize: 16),
              ),
              Row(
                children: [
                  const Icon(Icons.directions_car),
                  Text(
                    ' رقم السيارة: ${cityInfo["نمرة السيارة"]}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    '  ${cityInfo["عددالعربيات"]}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    '  ${cityInfo["التقييم"]}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Icon(Icons.star, color: Colors.amber)
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}

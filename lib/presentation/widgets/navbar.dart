import 'package:flutter/material.dart';
import 'package:gradution_project2/presentation/screens/pages/home_page.dart';
import 'package:gradution_project2/presentation/screens/pages/profie_page.dart';
import 'package:gradution_project2/presentation/screens/pages/rate_page.dart';
import 'package:gradution_project2/presentation/screens/pages/report_page.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int currentIndex = 0;
  List<Widget> screens = [
    HomePage(),
    const RatePage(),
    const ReportPage(),
    ProfilePage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xff2074EF),
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        selectedFontSize: 16,
        selectedIconTheme: const IconThemeData(size: 30),
        unselectedItemColor: Colors.white,
        unselectedIconTheme: const IconThemeData(size: 20, color: Colors.white),
        onTap: (index) {
          setState(
            () {
              currentIndex = index;
            },
          );
        },
        items: const [
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.home),
            icon: Icon(
              Icons.home_outlined,
            ),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.star),
            icon: Icon(
              Icons.star_border_outlined,
            ),
            label: 'التفيم',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.help),
            icon: Icon(
              Icons.help_outline_outlined,
            ),
            label: 'شكوي ',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.person),
            icon: Icon(
              Icons.person_2_outlined,
            ),
            label: 'حسابي',
          )
        ],
      ),
      body: screens[currentIndex],
    );
  }
}

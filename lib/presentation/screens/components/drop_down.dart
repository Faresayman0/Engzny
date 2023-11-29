import 'package:flutter/material.dart';

class MyDropdownButton extends StatefulWidget {
  final Map cityDestinations;
  final ValueChanged<String?> onCityChanged;

  const MyDropdownButton({
    Key? key,
    required this.cityDestinations,
    required this.onCityChanged,
  }) : super(key: key);

  @override
  _MyDropdownButtonState createState() => _MyDropdownButtonState();
}

class _MyDropdownButtonState extends State<MyDropdownButton> {
  String? selectedCity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButton<String>(
        hint: const Text('إختر الموقف'),
        isExpanded: true,
        value: selectedCity,
        onChanged: (String? newValue) {
          setState(() {
            selectedCity = newValue;
            widget.onCityChanged(newValue);
          });
        },
        items: widget.cityDestinations.keys
            .map<DropdownMenuItem<String>>((value) {
          return DropdownMenuItem<String>(
            value: value,
            key: UniqueKey(),
            child: Text(
              'موقف $value',
              textDirection: TextDirection.rtl,
            ),
          );
        }).toList(),
      ),
    );
  }
}


import 'package:flutter/material.dart';

class MyDropdownButton extends StatefulWidget {
  final List<String> stationName;
  void Function(String?)? onChanged;

  MyDropdownButton({
    super.key, 
    required this.stationName,
    required this.onChanged,
  });

  @override
  _MyDropdownButtonState createState() => _MyDropdownButtonState();
}

class _MyDropdownButtonState extends State<MyDropdownButton> {
  String? selectedCity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonFormField<String>(
        hint: const Text('إختر الموقف'),
        isExpanded: true,
        value: selectedCity,
        onChanged: widget.onChanged,
        items: widget.stationName.map<DropdownMenuItem<String>>((value) {
          return DropdownMenuItem<String>(
            value: value,
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

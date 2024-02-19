import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingWidget extends StatefulWidget {
  const RatingWidget({super.key});

  @override
  _RatingWidgetState createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget> {
  double _rating = 0.0;
  String _carNumberLetters = '';
  String _carNumberDigits = '';
  final TextEditingController _firstController = TextEditingController();
  final TextEditingController _secondController = TextEditingController();
  final TextEditingController _thirdController = TextEditingController();
  final TextEditingController _digitController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late FocusNode _firstFocusNode;
  late FocusNode _secondFocusNode;
  late FocusNode _thirdFocusNode;
  late FocusNode _digitFocusNode;

  Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _controllers = {
      'اول حرف': _firstController,
      'ثاني حرف': _secondController,
      'ثالث حرف': _thirdController,
      'الأرقام': _digitController,
    };

    _firstFocusNode = FocusNode();
    _secondFocusNode = FocusNode();
    _thirdFocusNode = FocusNode();
    _digitFocusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_firstFocusNode);
    });
  }

  @override
  void dispose() {
    _firstFocusNode.dispose();
    _secondFocusNode.dispose();
    _thirdFocusNode.dispose();
    _digitFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RatingBar.builder(
            initialRating: _rating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemSize: 50,
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {
              setState(() {
                _rating = rating;
              });
            },
          ),
          const SizedBox(height: 10),
          const Text(
            "ادخل نمرة السيارة",
            style: TextStyle(fontSize: 25),
          ),
          const SizedBox(height: 16.0),
          buildCarNumberFields(),
          const SizedBox(height: 16.0),
          buildElevatedButton(),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }

  Row buildCarNumberFields() {
    List<String> labels = ['الأرقام', 'ثالث حرف', 'ثاني حرف', 'اول حرف'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: labels.map((label) {
        TextEditingController controller = _controllers[label]!;
        bool isDigit = label == 'الأرقام';
        int maxLength = isDigit ? 3 : 1;
        FocusNode focusNode;
        FocusNode? nextFocusNode;

        switch (label) {
          case 'اول حرف':
            focusNode = _firstFocusNode;
            nextFocusNode = _secondFocusNode;
            break;
          case 'ثاني حرف':
            focusNode = _secondFocusNode;
            nextFocusNode = _thirdFocusNode;
            break;
          case 'ثالث حرف':
            focusNode = _thirdFocusNode;
            nextFocusNode = _digitFocusNode;
            break;
          case 'الأرقام':
            focusNode = _digitFocusNode;
            break;
          default:
            focusNode = FocusNode();
        }

        return Expanded(
          child: buildTextField(
            label,
            isDigit: isDigit,
            maxLength: maxLength,
            controller: controller,
            focusNode: focusNode,
            nextFocusNode: nextFocusNode,
          ),
        );
      }).toList(),
    );
  }

  TextField buildTextField(
    String labelText, {
    bool isDigit = false,
    int maxLength = 1,
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocusNode,
  }) {
    return TextField(
      cursorColor: Colors.blue,
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.blue, fontSize: 12),
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
      ),
      textAlign: TextAlign.center,
      keyboardType: isDigit ? TextInputType.number : TextInputType.text,
      onChanged: (value) {
        setState(() {
          if (isDigit) {
            _carNumberDigits = value;
          } else {
            _carNumberLetters = '';
            for (var entry in _controllers.entries) {
              _carNumberLetters += entry.value.text;
            }
          }
        });

        if (value.length == maxLength) {
          if (nextFocusNode != null) {
            _moveToNextField(nextFocusNode);
          }
        }
      },
      maxLength: maxLength,
      focusNode: focusNode,
      onEditingComplete: () {
        if (nextFocusNode != null) {
          _moveToNextField(nextFocusNode);
        } else {
          checkCarExistenceAndAddRating();
          FocusScope.of(context).requestFocus(_firstFocusNode);
        }
      },
    );
  }

  ElevatedButton buildElevatedButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        minimumSize: const Size(double.infinity, 40),
      ),
      onPressed: () async {
        if ((_carNumberLetters.length == 3 || _carNumberLetters.length == 2) &&
            (_carNumberDigits.length == 3 || _carNumberDigits.length == 2)) {
          String carNumber = '$_carNumberLetters$_carNumberDigits';
          await checkCarExistenceAndAddRating(carNumber);
          _firstController.selection = const TextSelection.collapsed(offset: 0);

          _firstFocusNode.requestFocus();
        } else {
          showValidationDialog();
        }
      },
      child: const Text(
        'ارسل التقييم ',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  void _moveToNextField(FocusNode focusNode) {
    FocusScope.of(context).requestFocus(focusNode);
  }

  Future<void> checkCarExistenceAndAddRating([String? carNumber]) async {
    carNumber ??= '$_carNumberLetters$_carNumberDigits';

    try {
      var querySnapshot = await _firestore
          .collection('AllCars')
          .where('numberOfCar', isEqualTo: carNumber)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var carDocument = querySnapshot.docs.first;
        if (carDocument.data().containsKey('rating')) {
          if (carDocument['rating'] != null) {
            await updateExistingRating(carDocument.id);
          } else {
            await addNewRating(carDocument.id);
          }
        } else {
          await addRatingField(carDocument.id);
        }
      } else {
        showCarNotFoundErrorDialog(carNumber);
      }
    } catch (error) {
      print('Error checking car existence: $error');
    }
  }

  Future<void> addRatingField(String documentId) async {
    await _firestore.collection('AllCars').doc(documentId).update({
      'rating': _rating,
      'numberOfRatings': 1,
      'averageRating': _rating.toStringAsFixed(1),
    });

    showSuccessDialog(_rating);
  }

  Future<void> updateExistingRating(String documentId) async {
    await _firestore.runTransaction((transaction) async {
      var documentSnapshot = await transaction.get(
        _firestore.collection('AllCars').doc(documentId),
      );

      if (documentSnapshot.exists) {
        double currentRating = documentSnapshot['rating'] ?? 0.0;
        int numberOfRatings = documentSnapshot['numberOfRatings'] ?? 0;

        double newTotalRating = currentRating + _rating;
        int newNumberOfRatings = numberOfRatings + 1;

        double averageRating = newTotalRating / newNumberOfRatings;

        transaction.update(
          _firestore.collection('AllCars').doc(documentId),
          {
            'rating': newTotalRating,
            'numberOfRatings': newNumberOfRatings,
            'averageRating': averageRating.toStringAsFixed(1),
          },
        );

        showSuccessDialog(averageRating);
      }
    });
  }

  Future<void> addNewRating(String carNumber) async {
    await _firestore.collection('AllCars').doc().set({
      'numberOfCar': carNumber,
      'rating': _rating,
      'numberOfRatings': 1,
      'averageRating': _rating,
      'timestamp': FieldValue.serverTimestamp(),
    });

    showSuccessDialog(_rating);
  }

  void showSuccessDialog(double averageRating) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تم بنجاح'),
          content: Text(
            'تمت إضافة التقييم بنجاح. المتوسط: ${averageRating.toStringAsFixed(1)}',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetFields();
              },
              child: const Text(
                'حسنا',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  void showCarNotFoundErrorDialog(String carNumber) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('خطأ'),
          content: Text('نمرة السيارة $carNumber غير موجودة.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetFields();
              },
              child: const Text(
                'حسنا',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  void showValidationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('خطأ'),
          content: const Text('الرجاء إدخال نمرة السيارة والتقييم'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'حسنا',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  void _resetFields() {
    setState(() {
      _rating = 0.0;
      _carNumberLetters = '';
      _carNumberDigits = '';
      for (var controller in _controllers.values) {
        controller.clear();
      }
    });
  }
}

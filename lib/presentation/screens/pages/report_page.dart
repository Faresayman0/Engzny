import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gradution_project2/presentation/widgets/constant_widget.dart';
import 'package:intl/intl.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  late User _user;
  String? userEmail;
  String? userPhoneNumber;

  String? selectedStartingLocation;
  String? selectedEndingLocation;

  final TextEditingController _firstController = TextEditingController();
  final TextEditingController _secondController = TextEditingController();
  final TextEditingController _thirdController = TextEditingController();
  final TextEditingController _digitController = TextEditingController();
  final TextEditingController _complaintController = TextEditingController();

  final FocusNode _firstFocusNode = FocusNode();
  final FocusNode _secondFocusNode = FocusNode();
  final FocusNode _thirdFocusNode = FocusNode();
  final FocusNode _digitFocusNode = FocusNode();

  List<String> parkingLocations = [];

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
    fetchUserData();
    fetchParkingLocations();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        FocusScope.of(context).requestFocus(_firstFocusNode);
      }
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

  Future<void> fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      if (mounted) {
        setState(() {
          userEmail = user.email;
          userPhoneNumber = user.phoneNumber;
        });
      }
    }
  }

  Future<void> fetchParkingLocations() async {
    try {
      final parkingQuerySnapshot =
          await FirebaseFirestore.instance.collection('المواقف').get();

      if (mounted && parkingQuerySnapshot.docs.isNotEmpty) {
        setState(() {
          parkingLocations = parkingQuerySnapshot.docs
              .map((doc) => doc['name'] as String)
              .toList();
        });
      }
    } catch (e) {
      print('Error fetching parking locations: $e');
    }
  }

  Future<void> _sendComplaint() async {
    String first = _firstController.text.trim();
    String second = _secondController.text.trim();
    String third = _thirdController.text.trim();
    String digit = _digitController.text.trim();
    String carNumber = '$first$second$third$digit';
    String complaint = _complaintController.text.trim();

    if (first.isEmpty ||
        second.isEmpty ||
        third.isEmpty ||
        digit.isEmpty ||
        complaint.isEmpty ||
        selectedStartingLocation == null ||
        selectedEndingLocation == null) {
      _showAlertDialog(
          'الرجاء ادخال جميع نمرة السيارة والشكوى واختيار المواقف');
      return;
    }

    try {
      final carQuerySnapshot = await FirebaseFirestore.instance
          .collection('AllCars')
          .where('numberOfCar', isEqualTo: carNumber)
          .get();

      if (mounted && carQuerySnapshot.docs.isEmpty) {
        _showAlertDialog("نمرة السيارة غير صحيحه");
        return;
      }

      CollectionReference messages =
          FirebaseFirestore.instance.collection('messages');

      await messages.add({
        'carNumber': carNumber,
        'complaint': complaint,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': _user.uid,
        'userName': userEmail ?? userPhoneNumber,
        'startingLocation': selectedStartingLocation,
        'endingLocation': selectedEndingLocation,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إرسال الشكوى بنجاح')),
        );

        _clearInputFields();
      }
    } catch (e) {
      if (mounted) {
        _showAlertDialog('حدث خطأ أثناء إرسال الشكوى، يرجى المحاولة مرة أخرى');
      }
    }
  }

  void _showAlertDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Center(child: Text('OK')),
            ),
          ],
        );
      },
    );
  }

  void _clearInputFields() {
    if (mounted) {
      setState(() {
        _firstController.clear();
        _secondController.clear();
        _thirdController.clear();
        _digitController.clear();
        _complaintController.clear();
        selectedStartingLocation = null;
        selectedEndingLocation = null;
      });
    }
  }

  DateTime? _getTimestamp(Map<String, dynamic> messageData) {
    final timestamp = messageData['timestamp'];
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    return null;
  }

  Widget _buildMessageCard(Map<String, dynamic> messageData) {
    DateTime? timestamp = _getTimestamp(messageData);

    if (timestamp != null) {
      String formattedTime = DateFormat('HH:mm').format(timestamp);
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildMessageText(
                  'رقم السيارة:', messageData['carNumber'].toString()),
              _buildMessageText(
                  'محتوى الشكوى:', messageData['complaint'].toString()),
              _buildMessageText(
                  "ركبت من:", messageData['startingLocation'].toString()),
              _buildMessageText(
                  'رايح الي:', messageData['endingLocation'].toString()),
              _buildMessageText('الوقت:', formattedTime),
            ],
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget _buildMessageText(String label, String value) {
    return Text(
      '$label $value',
      style: const TextStyle(fontSize: 18),
    );
  }

  Widget _buildCarNumberInput() {
    return Column(
      children: [
        Row(
          children: [
            _buildTextField('الارقام', _digitController, _digitFocusNode, 3,
                TextInputType.number),
            const SizedBox(width: 8),
            _buildTextField('ثالث حرف', _thirdController, _thirdFocusNode, 1,
                TextInputType.text),
            const SizedBox(width: 8),
            _buildTextField('ثاني حرف', _secondController, _secondFocusNode, 1,
                TextInputType.text),
            const SizedBox(width: 8),
            _buildTextField('اول حرف', _firstController, _firstFocusNode, 1,
                TextInputType.text),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            DropdownButton<String>(
              iconSize: 40,
              value: selectedEndingLocation,
              hint: const Text(
                "رايح فين",
              ),
              items: parkingLocations
                  .map((location) => DropdownMenuItem(
                        value: location,
                        child: Text(location),
                      ))
                  .toList(),
              onChanged: (value) {
                if (mounted) {
                  setState(() {
                    selectedEndingLocation = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              iconSize: 40,
              value: selectedStartingLocation,
              hint: const Text('ركبت منين'),
              items: parkingLocations
                  .map((location) => DropdownMenuItem(
                        value: location,
                        child: Text(location),
                      ))
                  .toList(),
              onChanged: (value) {
                if (mounted) {
                  setState(() {
                    selectedStartingLocation = value;
                  });
                }
              },
            ),
          ],
        )
      ],
    );
  }

  Widget _buildTextField(String labelText, TextEditingController controller,
      FocusNode focusNode, int maxLength, TextInputType keyboardType) {
    return Expanded(
      child: TextField(
        cursorColor: Colors.blue,
        controller: controller,
        textAlign: TextAlign.center,
        focusNode: focusNode,
        onChanged: (value) {
          if (value.length == maxLength) {
            _moveToNextField(focusNode, maxLength);
          }
        },
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(color: Colors.blue, fontSize: 10),
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
        ),
        keyboardType: keyboardType,
        maxLength: maxLength,
        onEditingComplete: () {
          _moveToNextField(focusNode, maxLength);
        },
      ),
    );
  }

  void _moveToNextField(FocusNode focusNode, int maxLength) {
    FocusNode? nextFocusNode;
    if (focusNode == _firstFocusNode) {
      nextFocusNode = _secondFocusNode;
    } else if (focusNode == _secondFocusNode) {
      nextFocusNode = _thirdFocusNode;
    } else if (focusNode == _thirdFocusNode) {
      nextFocusNode = _digitFocusNode;
    }

    if (nextFocusNode != null) {
      FocusScope.of(context).requestFocus(nextFocusNode);
    }
  }

  Widget _buildComplaintInput() {
    return TextField(
      cursorColor: Colors.blue,
      maxLines: 2,
      controller: _complaintController,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
        labelText: 'اضف شكوتك ',
        labelStyle: const TextStyle(color: Colors.blue),
      ),
    );
  }

  Widget _buildSendComplaintButton() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          onPressed: _sendComplaint,
          child: const Text(
            'ارسل الشكوي',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildSentComplaints() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        const Text(
          'الشكاوي المرسلة',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('messages')
                .where('userId', isEqualTo: _user.uid)
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
              if (snapshot.hasError) {
                print("error: ${snapshot.error}");
                return Text('Error: ${snapshot.error}');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.blue));
              }

              final List<QueryDocumentSnapshot<Map<String, dynamic>>>
                  documents = snapshot.data?.docs ?? [];

              return ListView.builder(
                itemCount: documents.length,
                itemBuilder: (BuildContext context, int index) {
                  final Map<String, dynamic> messageData =
                      documents[index].data();

                  return _buildMessageCard(messageData);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            const ConstantWidget(),
            const SizedBox(
              height: 10,
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                "ادخل نمرة السيارة",
                style: TextStyle(fontSize: 25),
              ),
            ),
            _buildCarNumberInput(),
            const SizedBox(height: 16),
            _buildComplaintInput(),
            const SizedBox(height: 16),
            _buildSendComplaintButton(),
            const SizedBox(height: 32),
            _buildSentComplaints(),
          ],
        ),
      ),
    );
  }
}

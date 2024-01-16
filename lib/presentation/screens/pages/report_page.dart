// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final TextEditingController _firstController = TextEditingController();
  final TextEditingController _secondController = TextEditingController();
  final TextEditingController _thirdController = TextEditingController();
  final TextEditingController _digitController = TextEditingController();
  final TextEditingController _complaintController = TextEditingController();

  late User _user;
  String? userEmail;
  String? userPhoneNumber;

  final FocusNode _secondFocusNode = FocusNode();
  final FocusNode _thirdFocusNode = FocusNode();
  final FocusNode _digitFocusNode = FocusNode();
  late FocusNode _firstFocusNode;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
    fetchUserData();
    _firstFocusNode = FocusNode();
    Future.delayed(Duration.zero, () {
      FocusScope.of(context).requestFocus(_firstFocusNode);
    });
  }

  @override
  void dispose() {
    _secondFocusNode.dispose();
    _thirdFocusNode.dispose();
    _digitFocusNode.dispose();
    _firstFocusNode.dispose();
    super.dispose();
  }

  Future<void> fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      setState(() {
        userEmail = user.email;
        userPhoneNumber = user.phoneNumber;
      });
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
        complaint.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            content: const Text('الرجاء ادخال جميع نمرة السيارة والشكوى'),
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
      return;
    }

    try {
      final carQuerySnapshot = await FirebaseFirestore.instance
          .collection('AllCars')
          .where('numberOfCar', isEqualTo: carNumber)
          .get();

      if (carQuerySnapshot.docs.isEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              content: const Text("نمرة السيارة غير صحيحه"),
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
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال الشكوى بنجاح')),
      );

      _firstController.clear();
      _secondController.clear();
      _thirdController.clear();
      _digitController.clear();
      _complaintController.clear();
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            content: const Text(
                'حدث خطأ أثناء إرسال الشكوى، يرجى المحاولة مرة أخرى'),
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
              Text(
                'رقم السيارة: ${messageData['carNumber']}',
                style: const TextStyle(fontSize: 18),
              ),
              Text(
                'محتوى الشكوى: ${messageData['complaint']}',
                style: const TextStyle(fontSize: 18),
              ),
              Text(
                'الوقت: $formattedTime',
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('صفحة الشكاوي'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: _digitController,
                        textAlign: TextAlign.center,
                        focusNode: _digitFocusNode,
                        maxLength: 3,
                        decoration: InputDecoration(
                          labelText: 'الارقام',
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _thirdController,
                        textAlign: TextAlign.center,
                        focusNode: _thirdFocusNode,
                        onChanged: (value) {
                          if (value.length == 1) {
                            FocusScope.of(context)
                                .requestFocus(_digitFocusNode);
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'ثالث حرف',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _secondController,
                        textAlign: TextAlign.center,
                        focusNode: _secondFocusNode,
                        onChanged: (value) {
                          if (value.length == 1) {
                            FocusScope.of(context)
                                .requestFocus(_thirdFocusNode);
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'ثاني حرف',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _firstController,
                        textAlign: TextAlign.center,
                        focusNode: _firstFocusNode,
                        onChanged: (value) {
                          FocusScope.of(context).requestFocus(_secondFocusNode);
                        },
                        decoration: InputDecoration(
                          labelText: 'اول حرف',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  maxLines: 4,
                  controller: _complaintController,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelText: 'اضف الشكوي ',
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _sendComplaint,
                      child: const Text(
                        'أضف الشكوي',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
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
                        AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                            snapshot) {
                      if (snapshot.hasError) {
                        print("error: ${snapshot.error}");
                        return Text('Error: ${snapshot.error}');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
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
            ),
          ],
        ),
      ),
    );
  }
}

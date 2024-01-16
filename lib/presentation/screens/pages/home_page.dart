// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:math';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gradution_project2/bussines_logic/cubit/phone_auth_cubit.dart';
import 'package:gradution_project2/constant/strings.dart';
import 'package:gradution_project2/presentation/screens/components/drop_down.dart';
import 'package:gradution_project2/presentation/widgets/constant_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final StreamController<double> _fadeController = StreamController<double>();

  List<QueryDocumentSnapshot>? stationName;
  Map<String, List<QueryDocumentSnapshot>> lineAvailableMap = {};
  String? selectedCity;

  late GoogleMapController _mapController;
  late LatLng _currentLocation = const LatLng(0.0, 0.0);
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    fetchData();
    _markers = <Marker>{};
    getCurrentLocation();
  }

  @override
  void dispose() {
    _fadeController.close();
    super.dispose();
  }

  Future<void> fetchData() async {
    await getStationName();
    await fetchLineDataForEachStation();
  }

  Future<void> getStationName() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection("المواقف").get();
    stationName = querySnapshot.docs;
  }

  Future<void> fetchLineDataForEachStation() async {
    if (stationName != null) {
      for (var station in stationName!) {
        await fetchDataForSelectedCity(station.id);
      }
    }
  }

  Future<void> fetchDataForSelectedCity(String cityId) async {
    try {
      final lineData = await getLineAvailable(cityId);
      lineAvailableMap[cityId] = lineData;

      setState(() {});
    } catch (e) {
      print("Error fetching data for $cityId: $e");
    }
  }

  Future<List<QueryDocumentSnapshot>> getLineAvailable(String stationId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection("المواقف")
          .doc(stationId)
          .collection("line")
          .get();

      return querySnapshot.docs;
    } catch (e) {
      return [];
    }
  }

  Future<List<QueryDocumentSnapshot>> getCarDataForLine(
      String stationId, String lineId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection("المواقف")
        .doc(stationId)
        .collection("line")
        .doc(lineId)
        .collection("car")
        .orderBy("timestamp", descending: false)
        .get();

    return querySnapshot.docs;
  }

  Future<Map<String, dynamic>> getCarData(String carNumber) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('AllCars')
        .where('numberOfCar', isEqualTo: carNumber)
        .get();

    return querySnapshot.docs.isNotEmpty ? querySnapshot.docs.first.data() : {};
  }

  void refreshData() {
    setState(() {
      stationName = null;
      lineAvailableMap.clear();
      selectedCity = null;
    });
    fetchData();
    getCurrentLocation();
  }

  Future<void> launchMap(String name, GeoPoint location) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // إذا كانت خدمة الموقع معطلة، يظهر دايلوج لتفعيلها
        await _showEnableLocationServiceDialog();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // إذا كانت الصلاحيات مرفوضة، يطلب من المستخدم تفعيلها
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // إذا كان المستخدم قد رفض تفعيل الصلاحيات، يظهر دايلوج لتفعيلها
          await _showEnableLocationPermissionDialog();
          return;
        }
      }

      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        if (mounted) {
          print(
              "Current Location: ${position.latitude}, ${position.longitude}");

          if (position.latitude != 0.0 && position.longitude != 0.0) {
            setState(() {
              _currentLocation = LatLng(position.latitude, position.longitude);
              _markers.add(
                Marker(
                  markerId: const MarkerId("currentLocation"),
                  position: _currentLocation,
                  infoWindow: const InfoWindow(title: "Your Location"),
                ),
              );
            });
          } else {}
        }
      } else {
        // إذا كانت الصلاحيات لم تتم تفعيلها، يظهر دايلوج لتفعيلها
        await _showEnableLocationPermissionDialog();
      }
    } catch (e) {
      print("Error getting current location: $e");
      // Handle the error as needed
    }
  }

  Future<void> _showEnableLocationServiceDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("تفعيل خدمة الموقع"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  "خدمة الموقع غير مفعلة. يرجى تفعيل خدمة الموقع للاستمرار."),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  if (await Geolocator.openLocationSettings()) {
                    await getCurrentLocation();
                  }
                  Navigator.of(context).pop();
                },
                child: const Text("فتح إعدادات الموقع"),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("إلغاء"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEnableLocationPermissionDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("تفعيل الصلاحيات"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  "الوصول إلى الموقع غير مسموح به. يرجى تفعيل الصلاحيات للاستمرار."),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  await Geolocator.openAppSettings();
                  Navigator.of(context).pop();
                },
                child: const Text("فتح إعدادات التطبيق"),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("إلغاء"),
            ),
          ],
        );
      },
    );
  }

  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    const double earthRadius = 6371.0;
    double dLat = _degreesToRadians(endLatitude - startLatitude);
    double dLon = _degreesToRadians(endLongitude - startLongitude);

    double a = pow(sin(dLat / 2), 2) +
        cos(_degreesToRadians(startLatitude)) *
            cos(_degreesToRadians(endLatitude)) *
            pow(sin(dLon / 2), 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distanceInKm = earthRadius * c;
    return distanceInKm;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180.0);
  }

  Future<double> getDistance(LatLng origin, LatLng destination) async {
    // Use the Google Directions API to get the distance
    const apiKey = 'AIzaSyDh3__9kh_BOO31Jph0XNt2VhSYVsMYobo';
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final routes = data['routes'] as List<dynamic>;
        if (routes.isNotEmpty) {
          final legs = routes[0]['legs'] as List<dynamic>;
          if (legs.isNotEmpty) {
            final distance = legs[0]['distance']['value'] as int;
            // Convert meters to kilometers
            return distance / 1000.0;
          }
        }
      }
    }

    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: refreshData,
          icon: const Icon(Icons.refresh),
        ),
        actions: [
          BlocProvider(
            create: (context) => PhoneAuthCubit(),
            child: IconButton(
              onPressed: () async {
                final phoneAuthCubit = PhoneAuthCubit();
                final googleSignIn = GoogleSignIn();

                try {
                  await googleSignIn.disconnect();
                } catch (error) {
                  print("Error disconnecting Google Sign In: $error");
                }

                try {
                  await FirebaseAuth.instance.signOut();
                } catch (error) {
                  print("Error signing out of Firebase: $error");
                }

                await phoneAuthCubit.logOut();

                Navigator.of(context).pushNamedAndRemoveUntil(
                  choseLogin,
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue,
        onPressed: () async {
          await getCurrentLocation();
          if (_currentLocation.latitude != 0.0 &&
              _currentLocation.longitude != 0.0) {
            _showNearestStationDialog();
            print(
                "============================= ${_currentLocation.latitude}, ${_currentLocation.longitude}");
          } else {
            print("Location not available");
          }
        },
        label: const Text("اقرب موقف لك"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: StreamBuilder<double>(
            stream: _fadeController.stream,
            builder: (context, snapshot) {
              double fadeValue = snapshot.data ?? 1.0;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(
                    height: 200,
                    child: ConstantWidget(),
                  ),
                  const SizedBox(height: 20),
                  if (stationName != null && stationName!.isNotEmpty)
                    MyDropdownButton(
                      stationName: stationName!
                          .map<String>((doc) => doc['name'] as String)
                          .toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCity = newValue;
                        });
                      },
                    ),
                  const SizedBox(height: 20),
                  for (var station in stationName ?? [])
                    if (selectedCity == station["name"])
                      Column(
                        children: [
                          if (lineAvailableMap.containsKey(station.id)) ...[
                            const SizedBox(height: 10),
                            Text(
                              "الخطوط التي توجد في موقف ${station["name"]} (${lineAvailableMap[station.id]!.length} خط)",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue),
                              onPressed: () {
                                launchMap(station["name"], station["location"]);
                              },
                              child: Text(
                                "موقع موقف ${station["name"]}",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            for (var line
                                in lineAvailableMap[station.id] ?? []) ...[
                              const SizedBox(height: 10),
                              SingleChildScrollView(
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 20),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.grey[200],
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Text(
                                            "${line['nameLine']}",
                                            style: const TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                          const Icon(Icons.arrow_back),
                                          Text(
                                            "$selectedCity",
                                            style:
                                                const TextStyle(fontSize: 20),
                                          ),
                                        ],
                                      ),
                                      FutureBuilder(
                                        future: getCarDataForLine(
                                            station.id, line.id),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const CircularProgressIndicator();
                                          } else if (snapshot.hasError) {
                                            return Text(
                                                "Error: ${snapshot.error}");
                                          } else if (!snapshot.hasData ||
                                              (snapshot.data as List).isEmpty) {
                                            return const Text(
                                                "لا توجد عربيات متاحه الان");
                                          } else {
                                            List<dynamic> carsData =
                                                snapshot.data as List;

                                            int numberOfAvailableCars =
                                                carsData.length;
                                            var firstCarData =
                                                carsData.isNotEmpty
                                                    ? carsData[0]
                                                    : null;

                                            if (firstCarData != null) {
                                              String carNumber =
                                                  firstCarData['numberOfCar'];
                                              return Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      Text(
                                                        "عدد العربيات المتاحه :$numberOfAvailableCars",
                                                        style: const TextStyle(
                                                            fontSize: 20),
                                                      ),
                                                      Text(
                                                        "سعر الاجره:${line['priceLine']}",
                                                        style: const TextStyle(
                                                          fontSize: 20,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      Text(
                                                        "نمرة السيارة: ${firstCarData['numberOfCar']}",
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Row(
                                                        children: [
                                                          const Icon(
                                                            Icons.star,
                                                            color: Colors.amber,
                                                          ),
                                                          FutureBuilder(
                                                            future: getCarData(
                                                                carNumber),
                                                            builder: (context,
                                                                snapshot) {
                                                              if (snapshot
                                                                      .connectionState ==
                                                                  ConnectionState
                                                                      .waiting) {
                                                                return const CircularProgressIndicator();
                                                              } else if (snapshot
                                                                  .hasError) {
                                                                return Text(
                                                                    "Error: ${snapshot.error}");
                                                              } else {
                                                                var carRatingData =
                                                                    snapshot.data
                                                                        as Map<
                                                                            String,
                                                                            dynamic>;
                                                                double?
                                                                    averageRating;
                                                                try {
                                                                  averageRating =
                                                                      double
                                                                          .parse(
                                                                    carRatingData['averageRating']
                                                                            ?.toString() ??
                                                                        '0.0',
                                                                  );
                                                                } catch (e) {
                                                                  averageRating =
                                                                      0.0;
                                                                }

                                                                return Text(
                                                                  "التقييم المتوسط: ${averageRating.toStringAsFixed(1) ?? '0.0'}",
                                                                  style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                );
                                                              }
                                                            },
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              );
                                            } else {
                                              return const SizedBox.shrink();
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ],
                        ],
                      ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showNearestStationDialog() async {
    if (stationName == null || stationName!.isEmpty) {
      return;
    }

    double minDistance = double.infinity;
    QueryDocumentSnapshot? nearestStation;

    for (var station in stationName!) {
      GeoPoint stationLocation = station['location'];
      double distance = await getDistance(
        LatLng(_currentLocation.latitude, _currentLocation.longitude),
        LatLng(stationLocation.latitude, stationLocation.longitude),
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearestStation = station;
      }
    }

    if (nearestStation != null) {
      final distanceInKm = minDistance;
      final distanceInMeters = minDistance * 1000;

      if (await Geolocator.isLocationServiceEnabled()) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("أقرب موقف"),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("الموقف الأقرب إليك هو: ${nearestStation?['name']}"),
                  const SizedBox(height: 10),
                  const Text("المسافة:"),
                  Text("${distanceInKm.toStringAsFixed(1)} كم"),
                  Text("${distanceInMeters.toStringAsFixed(1)} متر"),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("حسنًا"),
                ),
                TextButton(
                  onPressed: () {
                    launchMap(
                        nearestStation?['name'], nearestStation?['location']);
                    Navigator.of(context).pop();
                  },
                  child: const Text("عرض الموقع على الخريطة"),
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("تفعيل الموقع"),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                      "يرجى تفعيل خدمة الموقع للحصول على المزيد من المزايا."),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      if (await Geolocator.openLocationSettings()) {
                        await getCurrentLocation();
                      }
                      Navigator.of(context).pop();
                    },
                    child: const Text("فتح إعدادات الموقع"),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("إلغاء"),
                ),
              ],
            );
          },
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("أقرب موقف"),
            content: const Text("لا يمكن العثور على المواقف القريبة."),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("حسنًا"),
              ),
            ],
          );
        },
      );
    }
  }
}

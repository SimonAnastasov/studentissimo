import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:studentissimo/subjects_list.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:sensors/sensors.dart';
import 'package:flutter_sensors/flutter_sensors.dart';

import 'add_subject.dart';
import 'firebase_options.dart';
import 'package:studentissimo/sign_in.dart';

import 'my_account.dart';
import 'my_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Studentissimo',
      theme: ThemeData(
        useMaterial3: true,
      ),
      // home: const MainScreen(),
      home: SignInPage(),
    );
  }
}

class MainScreen extends MyWidget {
  MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends MyWidgetState<MainScreen> {
  StreamSubscription? _accelerometerSubscription;
  static const shakeThreshold = 3.0;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  void _startListening() {
    _accelerometerSubscription = userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      if (event.x.abs() > shakeThreshold || event.y.abs() > shakeThreshold || event.z.abs() > shakeThreshold) {
        Fluttertoast.showToast(
          msg: "Happy studying!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    });
  }

  @override
  Widget render() {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Subjects - Studentissimo',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFFBF586B),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: const Column(
          children: [
            Expanded(child: SubjectsList()),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AddSubjectForm();
            },
          );
        },
        backgroundColor: const Color(0xFFBF586B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
          side: const BorderSide(color: Colors.black),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFFBF586B),
        shape: const CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text('Home', style: TextStyle(color: Colors.white)),
              Container(), // This is to take up space in the middle
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => MyAccount()));
                },
                child: const Text('Account', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

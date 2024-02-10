import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import 'package:studentissimo/main.dart';
import 'package:studentissimo/user_settings.dart';

class MyAccount extends StatefulWidget {
  const MyAccount({super.key});

  @override
  _MyAccountState createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  File _image = File('');

  @override
  void initState() {
    super.initState();
    _loadNameAndImage();
  }

  Future<void> _loadNameAndImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('imagePath');

    setState(() {
      UserSettings().name = prefs.getString('name') ?? '';
      _image = (imagePath != null ? File(imagePath) : null)!;
    });
  }

  Future<void> _editName() async {
    final prefs = await SharedPreferences.getInstance();
    final newName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        final _nameController = TextEditingController();
        return AlertDialog(
          title: const Text('Edit your name'),
          content: TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Submit'),
              onPressed: () {
                Navigator.of(context).pop(_nameController.text);
              },
            ),
          ],
        );
      },
    );

    if (newName != null) {
      await prefs.setString('name', newName);

      setState(() {
        UserSettings().name = newName;
      });

      Fluttertoast.showToast(
          msg: "Name changed to $newName",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }


  Future<void> _editProfilePicture() async {
    final prefs = await SharedPreferences.getInstance();
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final savedImage = await File(pickedFile.path).copy('${appDir.path}/$fileName.png');

      await prefs.setString('imagePath', savedImage.path);

      setState(() {
        _image = savedImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Account',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFFBF586B),
      ),
      body: Container(
        padding: const EdgeInsets.all(32.0),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            children: [
              ValueListenableBuilder(
                valueListenable: UserSettings().userNameNotifier,
                builder: (context, value, child) {
                  return Text(value.isNotEmpty ? 'Name: $value' : 'No name set', style: TextStyle(fontSize: 24, color: Colors.white));
                },
              ),Container(
                width: 300.0,
                child: _image != null ? Image.file(_image, fit: BoxFit.cover) : const Text('No image selected.', style: TextStyle(fontSize: 24, color: Colors.white)),
              ),
              ElevatedButton(
                onPressed: _editName,
                child: const Text('Edit your name'),
              ),
              ElevatedButton(
                onPressed: _editProfilePicture,
                child: const Text('Edit your profile picture'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFFBF586B),
        shape: const CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => MainScreen()));
                },
                child: const Text('Home', style: TextStyle(color: Colors.white)),
              ),
              Container(), // This is to take up space in the middle
              const Text('Account', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddSubjectForm extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _gradeController = TextEditingController();

  AddSubjectForm({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add new subject'),
      content: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the name';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _gradeController,
              decoration: const InputDecoration(labelText: 'Grade'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the grade';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Submit'),
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              FirebaseFirestore.instance.collection('subjects').add({
                'name': _nameController.text,
                'grade': _gradeController.text,
              });
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}
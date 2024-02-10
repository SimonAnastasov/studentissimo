import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubjectsList extends StatelessWidget {
  const SubjectsList({super.key});

  Future<void> _showEditGradeDialog(BuildContext context, String subjectName, String docId) async {
    final _gradeController = TextEditingController();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter new grade for ${subjectName ?? 'No Name'}'),
          content: TextField(
            controller: _gradeController,
            decoration: const InputDecoration(labelText: 'Grade'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Submit'),
              onPressed: () {
                FirebaseFirestore.instance.collection('subjects').doc(docId).update({
                  'grade': _gradeController.text,
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddCriteriaDialog(BuildContext context, String docId) async {
    final _nameController = TextEditingController();
    final _gradeController = TextEditingController();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add new criteria'),
          content: Column(
            children: <Widget>[
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Criteria Name'),
              ),
              TextField(
                controller: _gradeController,
                decoration: const InputDecoration(labelText: 'Criteria Grade'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Submit'),
              onPressed: () {
                FirebaseFirestore.instance.collection('subjects').doc(docId).update({
                  'criteria': FieldValue.arrayUnion([{
                    'name': _nameController.text,
                    'grade': _gradeController.text,
                  }]),
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('subjects').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading");
        }

        return ListView.builder(
          itemCount: snapshot.data?.docs.length ?? 0,
          itemBuilder: (BuildContext context, int index) {
            DocumentSnapshot document = snapshot.data!.docs[index];
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFBF586B),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            data['name'] ?? 'No Name',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          Row(
                            children: <Widget>[
                              Text(
                                'Grade: ${data['grade'] ?? 'No Grade'}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              TextButton(
                                onPressed: () => _showEditGradeDialog(context, data['name'], document.id),
                                child: const Text('✏️', style: TextStyle(color: Colors.white)),
                              ),
                              TextButton(
                                onPressed: () => FirebaseFirestore.instance.collection('subjects').doc(document.id).delete(),
                                child: const Text('🗑️', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      ...((data['criteria'] as List<dynamic>?)?.map((dynamic criteria) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              '${criteria['name']} - Grade: ${criteria['grade']}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            TextButton(
                              onPressed: () {
                                FirebaseFirestore.instance.collection('subjects').doc(document.id).update({
                                  'criteria': FieldValue.arrayRemove([criteria]),
                                });
                              },
                              child: const Text('🗑️', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        );
                      })?.toList() ?? []),
                      TextButton(
                        onPressed: () => _showAddCriteriaDialog(context, document.id),
                        child: const Text('Add Criteria', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
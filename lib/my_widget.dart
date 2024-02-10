import 'package:flutter/cupertino.dart';

// Factory method pattern
abstract class MyWidget extends StatefulWidget {
  MyWidget({Key? key}) : super(key: key);

  @override
  MyWidgetState createState();
}

abstract class MyWidgetState<T extends MyWidget> extends State<T> {
  Widget render();

  @override
  Widget build(BuildContext context) {
    return render();
  }
}
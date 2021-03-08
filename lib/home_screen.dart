import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "HEHEHE  ងហើយហាហា I LOVE YOU",
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ),
    );
  }
}

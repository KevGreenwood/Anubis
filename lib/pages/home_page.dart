import 'package:flutter/material.dart';
import 'package:anubis/utils/adb.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("${Device.brand} ${Device.model}"),
      ),
    );
  }
}
import 'dart:io';

import 'package:flutter/material.dart';

class AppInfo {
  final String packageName;
  final String appName;
  final String iconPath;

  AppInfo({required this.packageName, required this.appName, required this.iconPath});
}

Widget appCard(AppInfo app) {
  return Card(
    child: ListTile(
      leading: Image.file(File(app.iconPath)),
      title: Text(app.appName),
      subtitle: Text(app.packageName),
      trailing: IconButton(
        icon: Icon(Icons.delete),
        onPressed: () {
        },
      ),
    ),
  );
}

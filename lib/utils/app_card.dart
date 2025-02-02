import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'adb.dart';

class AppInfo
{
  final String packageName;
  final String appName;
  final String iconPath;

  AppInfo({
    required this.packageName,
    required this.appName,
    required this.iconPath,
  });
}

Widget appCard(Application app, {required VoidCallback onDelete}) {
  return Card(
    child: ListTile(
      leading: Image.network(
        app.iconPath,
        errorBuilder: (context, error, stackTrace) {
          return SvgPicture.asset('assets/generic_apk.svg', width: 50,
            height: 50,
            fit: BoxFit.cover);
        },
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      ),
      title: Text(app.appName),
      subtitle: Text(app.packageName),
      trailing: IconButton(
        icon: Icon(Icons.delete),
        onPressed: onDelete,
      ),
    ),
  );
}
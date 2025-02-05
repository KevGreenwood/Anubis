import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'adb.dart';
import 'scrapper.dart';


class AppManager
{
  // singleton
  static final AppManager _instance = AppManager._internal();

  late List<Application> applications;
  bool _isLoaded = false;

  AppManager._internal();

  factory AppManager() => _instance;

  Future<void> fetchAllApplications() async
  {
    if (!_isLoaded)
    {
      String listApps = await ADB.runCommand("pm list packages");
      List<String> packageNames = listApps.split('\n')
          .where((line) => line.startsWith('package:'))
          .map((line) => line.replaceFirst('package:', '').trim())
          .toList();

      applications = [];
      List<Future<void>> futures = [];

      print("Getting info...");

      for (int i = 0; i < packageNames.length; i++)
      {
        print("App #$i");
        futures.add(Scrapper().fetchAppDetails(packageNames[i]).then((details)
        {
          applications.add(Application(
            packageName: packageNames[i],
            appName: details['appName']!,
            author: details['author']!,
            iconPath: details['iconPath']!,
          ));
        }));

        if (futures.length == maxConcurrency || i == packageNames.length - 1)
        {
          await Future.wait(futures);
          futures.clear();
        }
      }
      _isLoaded = true;
    }
  }

  Future<void> reloadApplications() async
  {
    _isLoaded = false;
    await fetchAllApplications();
  }

  final int maxConcurrency = 30;
}

Widget appCard(Application app, {required VoidCallback onDelete})
{
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 3,
    child: ListTile(
      leading: Image.network(
        app.iconPath,
        errorBuilder: (context, error, stackTrace) {
          return SvgPicture.asset('assets/generic_apk.svg', width: 50, height: 50, fit: BoxFit.cover);
        },
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      ),
      title: Text(app.appName, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 6,
            children: [
              if (app.author.isNotEmpty)
                Chip(
                  label: Text(app.author, style: const TextStyle(fontSize: 12)),
                  backgroundColor: Colors.grey[200],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide.none),
                ),
              if (app.packageName != app.appName)
                Chip(
                  label: Text(app.packageName, style: const TextStyle(fontSize: 12)),
                  backgroundColor: Colors.grey[200],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide.none),
                ),
            ],
          ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: onDelete,
      ),
    ),
  );
}
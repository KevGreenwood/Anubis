import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'adb.dart';


class AppManager
{
  final int maxConcurrency = 20;
  late List<Application> applications;

  Future<void> fetchAllApplications() async
  {
    String listApps = await ADB_Shell.runCommand("pm list packages");
    List<String> packageNames = listApps.split('\n')
        .where((line) => line.startsWith('package:'))
        .map((line) => line.replaceFirst('package:', '').trim()).toList();

    applications = [];
    List<Future<void>> futures = [];

    print("Getting info...");

    for (int i = 0; i < packageNames.length; i++)
    {
      print("App #$i");
      futures.add(Scrapper().fetchAppDetails(packageNames[i]).then((details) {
        applications.add(Application(
            packageName: packageNames[i],
            appName: details['appName']!,
            author: details['author']!,
            iconPath: details['iconPath']!
        ));
      }));

      if (futures.length == maxConcurrency || i == packageNames.length - 1)
      {
        await Future.wait(futures);
        futures.clear();
      }
    }
  }
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
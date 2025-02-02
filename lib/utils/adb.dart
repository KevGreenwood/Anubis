import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';


class Scrapper
{
  Future<Map<String, String>> fetchAppDetails(String packageName) async
  {
    final response = await http.get(Uri.parse("https://play.google.com/store/apps/details?id=$packageName"));
    try
    {
      if (response.statusCode != 200)
      {
        throw Exception("No se pudo obtener la información de la app");
      }

      var document = parse(response.body);
      String? appName = document.querySelector('span[itemprop="name"]')?.text.trim();
      String? author = document.querySelector('a[href^="/store/apps/developer?id="] span, a[href^="/store/apps/dev?id="] span')?.text.trim();
      String? iconPath = document.querySelector('.RhBWnf img')?.attributes['src'];

      return
        {
          'appName': appName ?? '',
          'author': author ?? '',
          'iconPath': iconPath ?? ''
        };
    }
    catch (e)
    {
      return {'appName': '', 'author': '', 'iconPath': ''};
    }
  }
}

class ADB
{
  Future<String> runAdbCommand(List<String> arguments) async
  {
    try
    {
      ProcessResult result = await Process.run("adb-tools/adb.exe", arguments);
      print(result.stdout);
      if (result.exitCode != 0)
      {
        throw Exception(result.stderr);
      }
      return result.stdout.toString().trim();
    }
    catch (e)
    {
      return "$e";
    }
  }
}

class Device
{
  static String brand = '';
  static String model = '';
  static String os = '';

  static Future<void> fetchDeviceInfo() async
  {
    brand = await ADB().runAdbCommand(["shell", "getprop ro.product.manufacturer"]);
    String fakeModel = await ADB().runAdbCommand(["shell", "getprop ro.product.model"]);
    String realModel = await ADB().runAdbCommand(["shell", "getprop ro.product.vendor.marketname"]);
    String osVersion = await ADB().runAdbCommand(["shell", "getprop ro.build.version.release"]);

    model = "$realModel ($fakeModel)";
    os = "Android $osVersion";
  }
}

class Application
{
  String packageName;
  String appName;
  String author;
  String iconPath;

  Application({required this.packageName, required this.appName, required this.author, required this.iconPath});

  @override
  String toString()
  {
    return 'Application(appName: $appName, packageName: $packageName, author: $author, iconPath: $iconPath)';
  }
}

class AppManager
{
  final int maxConcurrency = 20;
  late List<Application> applications;

  Future<void> fetchAllApplications() async
  {
    String listApps = await ADB().runAdbCommand(["shell", "pm list packages | grep gl"]);
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
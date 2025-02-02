import 'dart:io';
import 'dart:async';
import 'dart:convert';
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
  static Future<String> runCommand(List<String> arguments) async
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


class ADB_Shell
{
  static Process? _process;
  static StreamSubscription<String>? _outputSubscription;
  static Completer<void> _ready = Completer<void>();
  static Completer<String>? _commandResponse;
  static String _buffer = '';
  static const String _delimiter = "END_OF_COMMAND";

  static Future<void> start() async
  {
    if (_process != null) return;
    _process = await Process.start("adb-tools/adb.exe", ["shell"], mode: ProcessStartMode.normal);

    _outputSubscription = _process!.stdout.transform(utf8.decoder).listen((data)
    {
      _buffer += data;

      if (_commandResponse != null && _buffer.contains(_delimiter))
      {
        _commandResponse!.complete(_buffer.replaceAll(_delimiter, '').trim());
        _commandResponse = null;
        _buffer = '';
      }
    });

    _process!.stderr.transform(utf8.decoder).listen((data) { print("Error: $data"); });
    _ready.complete();
  }

  static Future<String> runCommand(String command) async
  {
    await _ready.future;
    _commandResponse = Completer<String>();
    _process?.stdin.writeln("$command; echo $_delimiter");
    return _commandResponse!.future;
  }

  static Future<void> close() async
  {
    await runCommand("exit");
    await _outputSubscription?.cancel();
    _process?.kill();
    _process = null;
  }
}

class Device
{
  static String brand = '';
  static String model = '';
  static String os = '';

  static Future<void> fetchDeviceInfo() async
  {
    brand = await ADB_Shell.runCommand("getprop ro.product.manufacturer");
    String fakeModel = await ADB_Shell.runCommand("getprop ro.product.model");
    String realModel = await ADB_Shell.runCommand("getprop ro.product.vendor.marketname");
    String osVersion = await ADB_Shell.runCommand("getprop ro.build.version.release");

    model = "$realModel ($fakeModel)";
    os = "Android $osVersion";
  }
}

class Application {
  String packageName;
  String appName;
  String author;
  String iconPath;

  Application({
    required this.packageName,
    required String appName,
    required String author,
    required this.iconPath,
  })  : appName = appName.isEmpty ? packageName : appName,
        author = _getAuthor(packageName, author);


  static String _getAuthor(String packageName, String author)
  {
    if (author.isEmpty && (packageName.startsWith("com.android") || packageName.startsWith("android") || packageName.contains(Device.brand.toLowerCase())) )
    {
      return "OEM";
    }
    else if (author.isEmpty && packageName.startsWith("com.google"))
    {
      return "Google LLC";
    }
    else
    {
      return author;
    }
  }

  @override
  String toString() {
    return 'Application(appName: $appName, packageName: $packageName, author: $author, iconPath: $iconPath)';
  }
}
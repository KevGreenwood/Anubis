import 'dart:io';
import 'dart:async';
import 'dart:convert';


class ADB
{
  static Process? _shellProcess;
  static StreamSubscription<String>? _outputSubscription;
  static final Completer<void> _ready = Completer<void>();
  static Completer<String>? _commandResponse;
  static String _buffer = '';
  static const String _delimiter = "END_OF_COMMAND";


  static Future<String> runArgs(List<String> args) async
  {
    try
    {
      ProcessResult? result;

      result = await Process.run("adb-tools/${Platform.isWindows ? "adb.exe" : "adb"}", args);

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

  static Future<void> start() async
  {
    if (_shellProcess != null) return;

    _shellProcess = await Process.start("adb-tools/${Platform.isWindows ? "adb.exe" : "adb"}", ["shell"], mode: ProcessStartMode.normal);

    _outputSubscription = _shellProcess!.stdout.transform(utf8.decoder).listen((data)
    {
      _buffer += data;

      if (_commandResponse != null && _buffer.contains(_delimiter))
      {
        _commandResponse!.complete(_buffer.replaceAll(_delimiter, '').trim());
        _commandResponse = null;
        _buffer = '';
      }
    });

    _shellProcess!.stderr.transform(utf8.decoder).listen((data) { print("Error: $data"); });
    _ready.complete();
  }

  static Future<String> runCommand(String command) async
  {
    start();
    await _ready.future;
    _commandResponse = Completer<String>();
    _shellProcess?.stdin.writeln("$command; echo $_delimiter");
    return _commandResponse!.future;
  }

  static Future<void> close() async
  {
    await runCommand("exit");
    await _outputSubscription?.cancel();
    _shellProcess?.kill();
    _shellProcess = null;
  }
}

class Device
{
  static String brand = '';
  static String model = '';
  static String os = '';

  static Future<void> fetchDeviceInfo() async
  {
    brand = await ADB.runCommand("getprop ro.product.manufacturer");
    String fakeModel = await ADB.runCommand("getprop ro.product.model");
    String realModel = await ADB.runCommand("getprop ro.product.vendor.marketname");
    String osVersion = await ADB.runCommand("getprop ro.build.version.release");

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
  String toString() => 'Application(appName: $appName, packageName: $packageName, author: $author, iconPath: $iconPath)';
}
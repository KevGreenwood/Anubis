import 'dart:io';


void main() async
{
  try
  {
    Future<String> runAdbCommand(List<String> arguments) async
    {
      ProcessResult result = await Process.run("adb-tools/adb.exe", arguments);
      if (result.exitCode != 0)
      {
        throw Exception("Error ejecutando comando ADB: ${result.stderr}");
      }
      return result.stdout.toString().trim();
    }

    String manufacturer = await runAdbCommand(["shell", "getprop ro.product.manufacturer"]);
    String model = await runAdbCommand(["shell", "getprop ro.product.model"]);
    String androidVersion = await runAdbCommand(["shell", "getprop ro.build.version.release"]);
    String listApps = await runAdbCommand(["shell", "pm list packages"]);

    print("Device: $manufacturer $model");
    print("Android Version: $androidVersion");
    print(listApps);
  }
  catch (e)
  {
    print("Ocurrió un error: $e");
  }
}

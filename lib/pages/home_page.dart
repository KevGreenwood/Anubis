import 'package:flutter/material.dart';
import 'package:anubis/utils/adb.dart';


class HomePage extends StatefulWidget
{
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
{
  final DeviceState deviceState = DeviceState();
  bool _isInitialized = false;

  @override
  void initState()
  {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async
  {
    if (!_isInitialized) {
      await deviceState.checkDeviceConnection();
      _isInitialized = true;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              deviceState.isDeviceConnected ? Icons.phone_android : Icons.error,
              color: deviceState.isDeviceConnected ? Colors.green : Colors.redAccent,
              size: 100,
            ),
            Text(deviceState.device ?? "Loading..."),
            ElevatedButton(
              onPressed: () async {
                await deviceState.checkDeviceConnection();
                setState(() {});
              },
              child: const Text("Refresh"),
            ),
          ],
        ),
      ),
    );
  }
}

class DeviceState
{
  static final DeviceState _instance = DeviceState._internal();
  String? device;
  bool isDeviceConnected = false;

  DeviceState._internal();

  factory DeviceState()
  {
    return _instance;
  }

  Future<void> checkDeviceConnection() async
  {
    var deviceList = await ADB.run(["devices"]);
    bool isConnected = deviceList.toString().contains('\tdevice');

    if (isConnected)
    {
      Device.fetchDeviceInfo();
      await Future.delayed(const Duration(seconds: 1));
      device = "${Device.brand} ${Device.model}";
      isDeviceConnected = true;
    }
    else
    {
      device = "Connect your device and click Refresh";
      isDeviceConnected = false;
    }
  }
}
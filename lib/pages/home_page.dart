import 'package:flutter/material.dart';
import 'package:anubis/utils/adb.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DeviceState deviceState = DeviceState();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.usb,
                  size: 100,
                ),
                ElevatedButton(
                  onPressed: () async {
                    await deviceState.checkDeviceConnection_usb();
                    setState(() {});
                  },
                  child: const Text("Connect Phone via USB Cable"),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                 Icons.wifi,
                  size: 100,
                ),
                ElevatedButton(
                  onPressed: () async {
                    await deviceState.checkDeviceConnection_wifi();
                    setState(() {});
                  },
                  child: const Text("Connect Phone via Wifi"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DeviceState {
  String? device;
  bool isDeviceReady = false;
  static final DeviceState _instance = DeviceState._internal();

  DeviceState._internal();

  factory DeviceState() {
    return _instance;
  }

  Future<void> checkDeviceConnection_usb() async {
    var deviceList = await ADB.runArgs(["devices"]);
    bool isConnected = deviceList.toString().contains('\tdevice');

    if (isConnected) {
      Device.fetchDeviceInfo();
      await Future.delayed(const Duration(seconds: 1));
      device = "${Device.brand} ${Device.model}";
      isDeviceReady = true;
    } else {
      device = "Connect your device and click Refresh";
      isDeviceReady = false;
    }
  }
  
  Future <void> checkDeviceConnection_wifi() async
  {
    await ADB.runArgs(["kill-server"]);
    await ADB.runArgs(["tcpip", "5555"]);
    var response = await ADB.runArgs(["connect", "192.168.0.103:5555"]);
    print(response);

    bool isConnected = response.toString().contains('connected to');
    if (isConnected) {
      Device.fetchDeviceInfo();
      device = "${Device.brand} ${Device.model}";

      isDeviceReady = device != "" ? true : false;
    } else {
      device = "Connect your device and click Refresh";
      isDeviceReady = false;
    }

  }
  
}

/*
Icon(
deviceState.isDeviceReady ? Icons.phone_android : Icons.error,
color: deviceState.isDeviceReady ? Colors.green : Colors.redAccent,
size: 100,
),
Text(deviceState.device ?? "Loading..."),
ElevatedButton(
onPressed: () async
{
await deviceState.checkDeviceConnection();
setState(() {});
},
child: const Text("Refresh"),
),],),*/

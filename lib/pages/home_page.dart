import 'package:flutter/material.dart';
import 'package:anubis/utils/adb.dart';

class HomePage extends StatefulWidget
{
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
{
  String device = "Connect your device and click Refresh";
  int selectedOption = 1;

  final TextEditingController lmao = TextEditingController();
  final TextEditingController lol = TextEditingController();

  @override
  void initState()
  {
    super.initState();
    init();
  }

  void init() async
  {
    var lol = await ADB.runCommand(["devices"]);
    if (lol.toString() == "List of devices attached")
    {
      setState(() {
        device = "Connect your device and click Refresh";
      });
      await ADB_Shell.close();

    }
    else
    {
      await ADB_Shell.start();
      await Device.fetchDeviceInfo();
      setState(() {
        device = "${Device.brand} ${Device.model}";
      });
    }
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Insert your device IP address'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(controller: lmao,),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Connect'),
              onPressed: () {
                ADB.runCommand(["pair ${lmao.text}"]);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pairing() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Insert your device IP address'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(controller: lol,),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(children: [Icon(Icons.error, color: Colors.redAccent, size: 100,), Text(device),
          ListTile(
            title: const Text('USB Connection'),
            leading: Radio<int>(
              value: 1,
              groupValue: selectedOption,
              onChanged: (value)
              {
                ADB.runCommand(["usb"]);
                ADB.runCommand(["devices"]);
                setState(() {
                  selectedOption = value!;
                });
              },
            ),
          ),
          ListTile(
            title: const Text('Wifi Connection'),
            leading: Radio<int>(
              value: 2,
              groupValue: selectedOption,
              onChanged: (value)
              {
                _showMyDialog();
                setState(() {
                  selectedOption = value!;
                });
              },
            ),
          ),
          ElevatedButton(onPressed: () async { init(); }, child: const Text("Refresh")), ]),
      ),
    );
  }
}


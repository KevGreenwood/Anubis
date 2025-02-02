import 'package:flutter/material.dart';
import 'package:anubis/utils/adb.dart';

class HomePage extends StatefulWidget
{
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
{
  int selectedOption = 1;

  final TextEditingController lmao = TextEditingController();
  final TextEditingController lol = TextEditingController();


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
        child: Column(children: [Icon(Icons.error, color: Colors.redAccent, size: 100,), Text("${Device.brand} ${Device.model}"),
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
          ElevatedButton(onPressed: () {ADB.runCommand(["devices"]);}, child: const Text("Refresh")), ]),
      ),
    );
  }
}


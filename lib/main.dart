import 'package:anubis/pages/android_page.dart';
import 'package:anubis/pages/clean_page.dart';
import 'package:anubis/pages/home_page.dart';
import 'package:anubis/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'utils/adb.dart';

void main() async
{
  await ADB_Shell.start();
  await Device.fetchDeviceInfo();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget
{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context)
  {
    return MaterialApp(
      title: 'Anubis',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Anubis'),
    );
  }
}

class MyHomePage extends StatefulWidget
{
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
{
  static List<Widget> _pageOptions = [
    HomePage(),
    AndroidPage(),
    CleanPage(),
    SettingsPage()
  ];
  int _selectedIndex = 0;

  @override
  void dispose()
  {
    ADB_Shell.close();
    super.dispose();
  }


  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.greenAccent,
        title: Text(widget.title),
      ),
      body: Row(
        children: <Widget>[
          NavigationRail(
          selectedIndex: _selectedIndex,
          groupAlignment: -1,
          onDestinationSelected: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          labelType: NavigationRailLabelType.all,
          destinations: const <NavigationRailDestination>[
            NavigationRailDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: Text('Home'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.android_outlined),
              selectedIcon: Icon(Icons.android),
              label: Text('Apps'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.delete_outline),
              selectedIcon: Icon(Icons.delete),
              label: Text('Cleaning'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: Text('Settings'),
            ),
          ],
            backgroundColor: Colors.greenAccent,

      ),
          const VerticalDivider(thickness: 1, width: 1,),
          Expanded(child: _pageOptions[_selectedIndex])
        ]
      )
    );
  }
}
import 'package:anubis/pages/android_page.dart';
import 'package:anubis/pages/clean_page.dart';
import 'package:anubis/pages/home_page.dart';
import 'package:anubis/pages/settings_page.dart';
import 'package:anubis/utils/downloader.dart';
import 'package:flutter/material.dart';
import 'utils/adb.dart';


void main() async
{
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
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
{
  static final List<Widget> _pageOptions = [ const HomePage(), const AndroidPage(), const CleanPage(), const SettingsPage()];
  int _selectedIndex = 0;

  @override
  void initState()
  {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_)
    {
      if (!Downloader.adbExists())
        {
          Downloader.showDownloadPreparationDialogs(context);
        }
    });
  }

  @override
  void dispose()
  {
    ADB.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
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
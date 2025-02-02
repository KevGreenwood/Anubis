import 'package:flutter/material.dart';
import '../utils/app_card.dart';
import '../utils/adb.dart';

class AndroidPage extends StatefulWidget
{
  @override
  _AndroidPageState createState() => _AndroidPageState();
}

class _AndroidPageState extends State<AndroidPage>
{
  final AppManager appManager = AppManager();
  bool isLoading = true;

  @override
  void initState()
  {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async
  {
    await appManager.fetchAllApplications();
    setState(() {
      isLoading = false;
    });
  }

  void _deleteApp(Application app)
  {
    ADB().runAdbCommand(["shell", "pm uninstall --user 0 ${app.packageName}"]);
    setState(() {
      appManager.applications.remove(app);

    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${app.appName} eliminada')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Aplicaciones Instaladas')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: appManager.applications.length,
        itemBuilder: (context, index) {
          final app = appManager.applications[index];
          return appCard(
            app,
            onDelete: () => _deleteApp(app),
          );
        },
      ),
    );
  }
}

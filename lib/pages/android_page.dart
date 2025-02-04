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
    setState(() => isLoading = false);
  }

  void _deleteApp(Application app) async
  {
    String output = await ADB.runCommand("pm uninstall --user 0 ${app.packageName}");

    if (output.contains("Success"))
    {
      setState(() => appManager.applications.remove(app));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${app.appName} eliminada'),
          backgroundColor: Colors.greenAccent,
        ),
      );
    }
    else
    {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${app.appName} $output'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aplicaciones Instaladas'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () async {
              setState(() {
                isLoading = true;
              });
              await appManager.reloadApplications();
              setState(() {
                isLoading = false;
              });
            },
          ),
        ],
      ),
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
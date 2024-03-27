import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Microphone Permission Checker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PermissionCheckPage(),
    );
  }
}

class PermissionCheckPage extends StatefulWidget {
  @override
  _PermissionCheckPageState createState() => _PermissionCheckPageState();
}

class _PermissionCheckPageState extends State<PermissionCheckPage> {
  List<ApplicationWithPermission> appsWithMicPermission = [];

  @override
  void initState() {
    super.initState();
    // Check microphone permission when the widget initializes
    _checkMicrophonePermission();
  }

  Future<void> _checkMicrophonePermission() async {
    // Check if microphone permission is granted
    PermissionStatus status = await Permission.microphone.status;
    if (!status.isGranted) {
      // If permission is not granted, request it
      await Permission.microphone.request();
      // Check again after permission request
      status = await Permission.microphone.status;
    }

    // If permission is granted, proceed to get apps with microphone permission
    if (status.isGranted) {
      await _getAppsUsingMicrophone();
    } else {
      // Handle the case when permission is denied
      print('Microphone permission denied');
    }
  }

  Future<void> _getAppsUsingMicrophone() async {
    List<ApplicationWithPermission> apps = [];
    List<Application> allApps = await DeviceApps.getInstalledApplications(
      onlyAppsWithLaunchIntent: true,
      includeAppIcons: true,
    );
    for (Application app in allApps) {
      // Check if the app has microphone permission
      if (await _hasMicrophonePermission(app.packageName)) {
        apps.add(ApplicationWithPermission(
          appName: app.appName,
          packageName: app.packageName,
        ));
      }
    }
    setState(() {
      appsWithMicPermission = apps;
    });
  }

  Future<bool> _hasMicrophonePermission(String packageName) async {
    // Check if the app has microphone permission
    PermissionStatus status = await Permission.microphone.status;
    return status.isGranted;
  }

  void _refreshList() {
    // Refresh the list of apps with microphone permission
    _getAppsUsingMicrophone();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Microphone Permission Checker'),
      ),
      body: ListView.builder(
        itemCount: appsWithMicPermission.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(appsWithMicPermission[index].appName),
            subtitle: Text(appsWithMicPermission[index].packageName),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _checkMicrophonePermission,
            tooltip: 'Scan for Apps with Microphone Permission',
            child: Icon(Icons.search),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _refreshList,
            tooltip: 'Refresh List',
            child: Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}

class ApplicationWithPermission {
  final String appName;
  final String packageName;

  ApplicationWithPermission({required this.appName, required this.packageName});
}

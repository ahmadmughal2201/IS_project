// import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Microphone Permission Checker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PermissionCheckPage(),
    );
  }
}

class PermissionCheckPage extends StatefulWidget {
  const PermissionCheckPage({Key? key}) : super(key: key);

  @override
  _PermissionCheckPageState createState() => _PermissionCheckPageState();
}

class _PermissionCheckPageState extends State<PermissionCheckPage> {
  List<ApplicationWithIcon> appsWithMicPermission = [];

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
    List<ApplicationWithIcon> apps = [];
    List<Application> allApps = await DeviceApps.getInstalledApplications(
      includeSystemApps: true, // Include system apps
      includeAppIcons: true, // Include app icons
      onlyAppsWithLaunchIntent: true, // Only list applications with launch intents
    );
    for (Application app in allApps) {
      // Check if the app has microphone permission
      if (await _hasMicrophonePermission(app.packageName)) {
        apps.add(app as ApplicationWithIcon);
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
  void _openAppSettings(ApplicationWithIcon app) async {
    await DeviceApps.openAppSettings(app.packageName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Microphone Permission Checker'),
      ),
      body: ListView.builder(
        itemCount: appsWithMicPermission.length,
        itemBuilder: (context, index) {
          final app = appsWithMicPermission[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: MemoryImage(appsWithMicPermission[index].icon),
            ),
            title: Text(appsWithMicPermission[index].appName),
            subtitle: Text(appsWithMicPermission[index].packageName),
             onTap: () => _openAppSettings(app),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _refreshList,
            tooltip: 'Refresh List',
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}

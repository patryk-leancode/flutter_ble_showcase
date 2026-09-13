import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ble_showcase/features/home/home_page.dart';
import 'package:flutter_ble_showcase/usecase/check_ble_permissions_usecase.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class FlutterBleShowcaseApp extends StatelessWidget {
  const FlutterBleShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GlobalProviders(
      child: MaterialApp(
        title: 'Flutter Łódź BLE',
        theme: ThemeData(
          colorScheme: .fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}

class GlobalProviders extends StatefulWidget {
  const GlobalProviders({super.key, required this.child});

  final Widget child;

  @override
  State<GlobalProviders> createState() => _GlobalProvidersState();
}

class _GlobalProvidersState extends State<GlobalProviders> {
  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<CheckBlePermissionsUsecase>(
          create: (context) => CheckBlePermissionsUsecase(),
        ),
      ],
      child: widget.child,
    );
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      await Permission.bluetoothAdvertise.request();
      await Permission.bluetoothConnect.request();
      await Permission.bluetoothScan.request();
    }
  }
}

import 'dart:io';

import 'package:bluetooth_ble/bluetooth_ble.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

import 'device_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: new HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ble = BluetoothBle();

  List<BleDevice> get devices => ble.devices;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ESVS Projector app'),
      ),
      body: StreamBuilder<BleDevice>(
          stream: ble.deviceStream,
          builder: (context, _) {
            return ListView(
              children: <Widget>[
                RaisedButton(
                  onPressed: _scan,
                  child: Text("Scan Device"),
                ),
                // RaisedButton(
                //   onPressed: () => _scanWithService(macServiceId),
                //   child: Text("Scan 1801 device"),
                // ),
                // RaisedButton(
                //   onPressed: () => _scanWithService("1801"),
                //   child: Text("扫描1801设备"),
                // ),
                // RaisedButton(
                //   onPressed: () => _scanWithService("FFF0"),
                //   child: Text("扫描FFF0设备"),
                // ),
                for (final device in devices) _buildItem(device)
              ],
            );
          }),
    );
  }

  void _scan() async {
    try {
      await ble.scan();
    } catch (e) {
      print(e.message);
    }
  }

  void _scanWithService(String uuid) async {
    try {
      await ble.scan(
        services: [uuid],
      );
    } on Exception catch (e) {
      print(e);
    }
  }

  void showLoadingDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return Center(
          child: Container(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  String get macServiceId {
    if (Platform.isIOS) {
      return "1811";
    }
    return "00001801-0000-1000-8000-00805f9b34fb";
  }

  String get serviceUUID {
    if (Platform.isIOS) {
      return "1801";
    } else {
      return "00001801-0000-1000-8000-00805f9b34fb";
    }
  }

  Widget _buildItem(BleDevice device) {
    return ListTile(
      title: Text(device.name),
      subtitle: Text(device.id),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DevicePage(
            device: device,
          ),
        ),
      ),
    );
  }
}

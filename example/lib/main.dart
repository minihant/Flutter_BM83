import 'dart:io';
import 'package:bluetooth_ble/bluetooth_ble.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'device_page.dart';
import 'service_page.dart';

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
        title: const Text('ESVS Projector'),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                _scan();
                // _scanWithService(serviceUUID);
              },
              child: Icon(
                Icons.search,
                size: 40.0,
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<BleDevice>(
          stream: ble.deviceStream,
          builder: (context, _) {
            return ListView(
              children: <Widget>[
                // RaisedButton(
                //   onPressed: _scan,
                //   child: Text("Scan Device"),
                // ),
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

  bool showProgress = true;
  void _scan() async {
    try {
      print("scan start");
      await ble.scan();

      print("scan finish");
      FlutterBeep.playSysSound(AndroidSoundIDs.TONE_PROP_BEEP2);
      // var drvCount = 0;
      // for (final drv in devices) {
      //   if (drv.name == 'BLE_BM83SDK') {
      //   drvCount++;
      //   }
      // }
      // if (drvCount == 1) {
      //   //--- jump to navagator -----
      //   for (final drv in devices) {
      //     if (drv.name == 'BLE_BM83SDK') {
      //       print("find device : " + drv.name);
      //       Navigator.push(
      //         context,
      //         MaterialPageRoute(
      //           builder: (_) => DevicePage(
      //             device: drv,
      //           ),
      //         ),
      //       );
      //     }
      //   }
      // }
    } catch (e) {
      print("bluetooth error : " + e.toString());
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
      // return "49535343-fe7d-4ae5-8fa9-9fafd205e455";
      // return "49535343-FE7D-4AE5-8FA9-9FAF82853364";
      return "0000fee0-0000-1000-8000-00805f9b34fb";
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

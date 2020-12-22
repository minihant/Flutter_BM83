import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:bluetooth_ble/bluetooth_ble.dart';
// import 'package:flutter/services.dart';
// import 'package:oktoast/oktoast.dart';
import 'service_page.dart';
// import 'package:soundpool/soundpool.dart';
import 'package:flutter_beep/flutter_beep.dart';

class DevicePage extends StatefulWidget {
  final BleDevice device;

  const DevicePage({
    Key key,
    @required this.device,
  }) : super(key: key);

  @override
  _DevicePageState createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  BleDevice get device => widget.device;

  int serviceID;
  int chrsID;
  int _selectedIndex = 0;

  Future _discoverCharacteristics(List<BleService> services) async {
    List<BleCh> _charsService;
    for (var i = 0; i < services.length; i++) {
      if (services[i].id == serviceUUID) {
        print(("serviceid= " + services[i].id));
        serviceID = i;
        chrsID = serviceID;
        await device.discoverCharacteristics(services[serviceID]);

        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (_) => ServicePage(
        //       device: device,
        //       service: services[sid],
        //     ),
        //   ),
        // );

        //-------------------------------------------------
        _charsService = services[serviceID].chs;
        for (var i = 0; i < _charsService.length; i++) {
          if (_charsService[i].id == rxUUID) {
            chrsID = i;
            FlutterBeep.playSysSound(AndroidSoundIDs.TONE_SUP_CONFIRM);
            break;
          }
        }
        break;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final services = device.service;
    device.connect();
    StreamSubscription sub;
    sub = device.connectStateStream.listen((data) async {
      sub.cancel();
      await device.requestMtu(512);
      await device.discoverServices();
      await _discoverCharacteristics(services);
      print("init ok");
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: device,
        builder: (context, _) {
          return buildScaffold();
        });
  }

  void _onItemTapped(int index) {
    final services = device.service;
    setState(() {
      _selectedIndex = index;
      print("selected Navi: " + _selectedIndex.toString());
      switch (_selectedIndex) {
        case 0:
          writeKey(services[serviceID].chs[chrsID], "K100");
          break;
        case 1:
          writeKey(services[serviceID].chs[chrsID], "K101");
          break;
        case 2:
          writeKey(services[serviceID].chs[chrsID], "K102");
          break;
        case 3:
          writeKey(services[serviceID].chs[chrsID], "K103");
          break;
      }
    });
  }

  Scaffold buildScaffold() {
    var device = widget.device;
    final isConnect = device.isConnect;
    final services = device.service;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              device.disconnect();
              Navigator.of(context).pop();
            }),
        title: Text(widget.device.name),
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                child: Icon(
                  // Icons.bluetooth_searching,
                  (!isConnect) ? Icons.check : Icons.cancel,
                  size: 26.0,
                ),
                onTap: () {
                  if (!isConnect) {
                    StreamSubscription sub;
                    sub = device.connectStateStream.listen((data) async {
                      sub.cancel();
                      await device.requestMtu(512);
                      await device.discoverServices();
                      await _discoverCharacteristics(services);
                    });
                    device.connect();
                  } else {
                    device.disconnect();
                  }
                },
              )),
        ],
        backgroundColor: Colors.blue[300],
      ),
      body: ListView(
        children: <Widget>[
          Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.videocam_off),
                iconSize: 100,
                color: isConnect ? Colors.black : Colors.white,
                onPressed: () {
                  setState(() {
                    if (isConnect == true) {
                      writeKey(services[serviceID].chs[chrsID], "K01");
                      FlutterBeep.playSysSound(AndroidSoundIDs.TONE_PROP_BEEP);
                    }
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.video_call),
                iconSize: 100,
                color: isConnect ? Colors.green : Colors.white,
                onPressed: () {
                  setState(() {
                    if (isConnect == true)
                      writeKey(services[serviceID].chs[chrsID], "K02");
                    FlutterBeep.playSysSound(AndroidSoundIDs.TONE_PROP_BEEP);
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.build),
                iconSize: 80,
                color: isConnect ? Colors.blueGrey : Colors.white,
                onPressed: () {
                  setState(() {
                    if (isConnect == true)
                      writeKey(services[serviceID].chs[chrsID], "K99");
                    FlutterBeep.playSysSound(AndroidSoundIDs.TONE_PROP_BEEP);
                  });
                },
              ),
            ],
          ),
          Container(
            height: 10,
          ),
          Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.volume_off),
                iconSize: 100,
                color: isConnect ? Colors.lightGreen : Colors.white,
                onPressed: () {
                  setState(() {
                    writeKey(services[serviceID].chs[chrsID], "K03");
                    FlutterBeep.playSysSound(AndroidSoundIDs.TONE_PROP_BEEP);
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.volume_down),
                iconSize: 100,
                color: isConnect ? Colors.lightBlue : Colors.white,
                tooltip: 'Decress volume by 10',
                onPressed: () {
                  setState(() {
                    writeKey(services[serviceID].chs[chrsID], "K04");
                    FlutterBeep.playSysSound(AndroidSoundIDs.TONE_PROP_BEEP);
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.volume_up),
                iconSize: 100,
                color: isConnect ? Colors.red : Colors.white,
                tooltip: 'Increase volume by 10',
                onPressed: () {
                  setState(() {
                    writeKey(services[serviceID].chs[chrsID], "K05");
                    FlutterBeep.playSysSound(AndroidSoundIDs.TONE_PROP_BEEP);
                  });
                },
              ),
            ],
          ),
        ],
      ),
      //---- Buttom Navigation -------------------
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.headset),
            label: 'Pairing',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.phone_forwarded),
            label: 'Tx mode',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.phone_callback),
            label: 'Rx mode',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }

//   Widget _buildService(BleService service) {
//     return ListTile(
//       title: Text(service.id),
//       onTap: () async {
//         await device.discoverCharacteristics(service);
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => ServicePage(
//               device: device,
//               service: service,
//             ),
//           ),
//         );
//       },
//     );
//   }
  // void writeData1(BleCh ch) {
  //   // String data = "abc\n";
  //   // String data = "12345678901234567890qwertyuiopasdfghjklzxcvbnm" * 20;
  //   // data = "$data\n";
  //   // String data = "abc234567890-34567890-4567890567890\n";
  //   // final list = utf8.encode(data);
  //   final data = <int>[0x1D, 0x67, 0x68];

  //   device.writeData(ch: ch, data: Uint8List.fromList(data));
  // }

  // void writeData2(BleCh ch) {
  //   final data = <int>[0x1D, 0x69, 0x70];
  //   device.writeData(ch: ch, data: Uint8List.fromList(data));
  // }

  void writeKey(BleCh ch, String str) {
    // String data = "K01";
    List<int> bytes = utf8.encode(str);
    device.writeData(ch: ch, data: Uint8List.fromList(bytes));
  }
}

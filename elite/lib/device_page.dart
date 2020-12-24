import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:bluetooth_ble/bluetooth_ble.dart';
import 'service_page.dart';
// import 'package:soundpool/soundpool.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'IR_Key.dart';

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
          writeKey(services[serviceID].chs[chrsID], KeyID["btPairingKey"]);
          break;
        case 1:
          writeKey(services[serviceID].chs[chrsID], KeyID["btTxModeKey"]);
          break;
        case 2:
          writeKey(services[serviceID].chs[chrsID], KeyID["btRxModeKey"]);
          break;
        case 3:
          writeKey(services[serviceID].chs[chrsID], 103);
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
                icon: Icon(Icons.power_settings_new),
                iconSize: 60,
                color: isConnect ? Colors.black : Colors.white,
                onPressed: () {
                  setState(() {
                    if (isConnect == true) {
                      writeKey(services[serviceID].chs[chrsID], KeyID['PJKey']);
                      FlutterBeep.playSysSound(AndroidSoundIDs.TONE_PROP_BEEP);
                    }
                  });
                },
              ),
              Container(
                width: 60,
              ),
              IconButton(
                icon: Icon(Icons.wb_sunny_sharp),
                iconSize: 60,
                color: isConnect ? Colors.green : Colors.white,
                onPressed: () {
                  setState(() {
                    if (isConnect == true)
                      writeKey(services[serviceID].chs[chrsID],
                          KeyID['btPJShortKey']);
                    FlutterBeep.playSysSound(AndroidSoundIDs.TONE_PROP_BEEP);
                  });
                },
              ),
              Container(
                width: 60,
              ),
              IconButton(
                icon: Icon(Icons.home_rounded),
                iconSize: 60,
                color: isConnect ? Colors.blueGrey : Colors.white,
                onPressed: () {
                  setState(() {
                    if (isConnect == true)
                      writeKey(
                          services[serviceID].chs[chrsID], KeyID['HOMEKey']);
                    FlutterBeep.playSysSound(AndroidSoundIDs.TONE_PROP_BEEP);
                  });
                },
              ),
            ],
          ),
          // Container(
          //   height: 1,
          // ),
          Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.volume_off),
                iconSize: 50,
                color: isConnect ? Colors.lightGreen : Colors.white,
                onPressed: () {
                  setState(() {
                    writeKey(services[serviceID].chs[chrsID], KeyID["MuteKey"]);
                    FlutterBeep.playSysSound(AndroidSoundIDs.TONE_PROP_BEEP);
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.volume_down),
                iconSize: 50,
                color: isConnect ? Colors.lightBlue : Colors.white,
                tooltip: 'Decress volume by 10',
                onPressed: () {
                  setState(() {
                    writeKey(
                        services[serviceID].chs[chrsID], KeyID["VolDownKey"]);
                    FlutterBeep.playSysSound(AndroidSoundIDs.TONE_PROP_BEEP);
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.volume_up),
                iconSize: 50,
                color: isConnect ? Colors.red : Colors.white,
                tooltip: 'Increase volume by 10',
                onPressed: () {
                  setState(() {
                    writeKey(
                        services[serviceID].chs[chrsID], KeyID["VolUpKey"]);
                    FlutterBeep.playSysSound(AndroidSoundIDs.TONE_PROP_BEEP);
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.rotate_left_sharp),
                iconSize: 50,
                color: isConnect ? Colors.red : Colors.white,
                tooltip: 'Increase volume by 10',
                onPressed: () {
                  setState(() {
                    writeKey(
                        services[serviceID].chs[chrsID], KeyID["FocusFwKey"]);
                    FlutterBeep.playSysSound(AndroidSoundIDs.TONE_PROP_BEEP);
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.rotate_right_sharp),
                iconSize: 50,
                color: isConnect ? Colors.red : Colors.white,
                tooltip: 'Increase volume by 10',
                onPressed: () {
                  setState(() {
                    writeKey(
                        services[serviceID].chs[chrsID], KeyID["FocusBwKey"]);
                    FlutterBeep.playSysSound(AndroidSoundIDs.TONE_PROP_BEEP);
                  });
                },
              ),
            ],
          ),
          // Container(
          //   height: 1,
          // ),
          Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.settings_input_hdmi),
                iconSize: 50,
                color: isConnect ? Colors.black : Colors.white,
                onPressed: () {
                  setState(() {
                    if (isConnect == true) {
                      writeKey(
                          services[serviceID].chs[chrsID], KeyID['HDMI1Key']);
                      FlutterBeep.playSysSound(AndroidSoundIDs.TONE_PROP_BEEP);
                    }
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.settings_input_hdmi),
                iconSize: 50,
                color: isConnect ? Colors.green : Colors.white,
                onPressed: () {
                  setState(() {
                    if (isConnect == true)
                      writeKey(
                          services[serviceID].chs[chrsID], KeyID['HDMI2Key']);
                    FlutterBeep.playSysSound(AndroidSoundIDs.TONE_PROP_BEEP);
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.settings_display),
                iconSize: 50,
                color: isConnect ? Colors.blueGrey : Colors.white,
                onPressed: () {
                  setState(() {
                    if (isConnect == true)
                      writeKey(services[serviceID].chs[chrsID], KeyID['DPKey']);
                    FlutterBeep.playSysSound(AndroidSoundIDs.TONE_PROP_BEEP);
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.bluetooth_audio_sharp),
                iconSize: 50,
                color: isConnect ? Colors.blueGrey : Colors.white,
                onPressed: () {
                  setState(() {
                    if (isConnect == true)
                      writeKey(
                          services[serviceID].chs[chrsID], KeyID['AudioBTKey']);
                    FlutterBeep.playSysSound(AndroidSoundIDs.TONE_PROP_BEEP);
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.speaker),
                iconSize: 50,
                color: isConnect ? Colors.blueGrey : Colors.white,
                onPressed: () {
                  setState(() {
                    if (isConnect == true)
                      writeKey(
                          services[serviceID].chs[chrsID], KeyID['AudioPJKey']);
                    FlutterBeep.playSysSound(AndroidSoundIDs.TONE_PROP_BEEP);
                  });
                },
              ),
            ],
          ),
          // Container(
          //   height: 1,
          // ),
          Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.filter_1),
                iconSize: 50,
                color: isConnect ? Colors.lightGreen : Colors.white,
                onPressed: () {
                  setState(() {
                    writeKey(services[serviceID].chs[chrsID], KeyID["F1Key"]);
                    FlutterBeep.playSysSound(AndroidSoundIDs.TONE_PROP_BEEP);
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.filter_2),
                iconSize: 50,
                color: isConnect ? Colors.lightBlue : Colors.white,
                tooltip: 'Decress volume by 10',
                onPressed: () {
                  setState(() {
                    writeKey(services[serviceID].chs[chrsID], KeyID["F2Key"]);
                    FlutterBeep.playSysSound(AndroidSoundIDs.TONE_PROP_BEEP);
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.filter_3),
                iconSize: 50,
                color: isConnect ? Colors.red : Colors.white,
                tooltip: 'Increase volume by 10',
                onPressed: () {
                  setState(() {
                    writeKey(services[serviceID].chs[chrsID], KeyID["F3Key"]);
                    FlutterBeep.playSysSound(AndroidSoundIDs.TONE_PROP_BEEP);
                  });
                },
              ),
            ],
          ),
          // Container(
          //   height: 1,
          // ),
          Row(
            children: <Widget>[
              Container(
                width: 80,
              ),
              IconButton(
                icon: Icon(Icons.select_all_sharp),
                iconSize: 50,
                color: isConnect ? Colors.lightGreen[100] : Colors.white,
                onPressed: () {
                  //   setState(() {
                  //     writeKey(services[serviceID].chs[chrsID], KeyID["UpKey"]);
                  //     FlutterBeep.playSysSound(AndroidSoundIDs.TONE_PROP_BEEP);
                  //   });
                },
              ),
              IconButton(
                icon: Icon(Icons.arrow_upward),
                iconSize: 50,
                color: isConnect ? Colors.lightGreen : Colors.white,
                onPressed: () {
                  setState(() {
                    writeKey(services[serviceID].chs[chrsID], KeyID["UpKey"]);
                    FlutterBeep.playSysSound(AndroidSoundIDs.TONE_PROP_BEEP);
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.select_all_sharp),
                iconSize: 50,
                color: isConnect ? Colors.lightGreen[100] : Colors.white,
                onPressed: () {
                  // setState(() {
                  //   writeKey(services[serviceID].chs[chrsID], KeyID["UpKey"]);
                  //   FlutterBeep.playSysSound(AndroidSoundIDs.TONE_PROP_BEEP);
                  // });
                },
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Container(
                width: 80,
              ),
              IconButton(
                icon: Icon(Icons.arrow_back),
                iconSize: 50,
                color: isConnect ? Colors.lightGreen : Colors.white,
                tooltip: 'Increase volume by 10',
                onPressed: () {
                  setState(() {
                    writeKey(services[serviceID].chs[chrsID], KeyID["LeftKey"]);
                    FlutterBeep.playSysSound(AndroidSoundIDs.TONE_PROP_BEEP);
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.center_focus_strong),
                iconSize: 50,
                color: isConnect ? Colors.lightGreen : Colors.white,
                tooltip: 'Increase volume by 10',
                onPressed: () {
                  setState(() {
                    writeKey(services[serviceID].chs[chrsID], KeyID["OkKey"]);
                    FlutterBeep.playSysSound(AndroidSoundIDs.TONE_PROP_BEEP);
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward),
                iconSize: 50,
                color: isConnect ? Colors.lightGreen : Colors.white,
                tooltip: 'Increase volume by 10',
                onPressed: () {
                  setState(() {
                    writeKey(
                        services[serviceID].chs[chrsID], KeyID["RightKey"]);
                    FlutterBeep.playSysSound(AndroidSoundIDs.TONE_PROP_BEEP);
                  });
                },
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Container(
                width: 80,
              ),
              IconButton(
                icon: Icon(Icons.select_all_sharp),
                iconSize: 50,
                color: isConnect ? Colors.lightGreen[100] : Colors.white,
                onPressed: () {
                  // setState(() {
                  //   writeKey(services[serviceID].chs[chrsID], KeyID["UpKey"]);
                  //   FlutterBeep.playSysSound(AndroidSoundIDs.TONE_PROP_BEEP);
                  // });
                },
              ),
              IconButton(
                icon: Icon(Icons.arrow_downward),
                iconSize: 50,
                color: isConnect ? Colors.lightGreen : Colors.white,
                tooltip: 'Decress volume by 10',
                onPressed: () {
                  setState(() {
                    writeKey(services[serviceID].chs[chrsID], KeyID["DownKey"]);
                    FlutterBeep.playSysSound(AndroidSoundIDs.TONE_PROP_BEEP);
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.select_all_sharp),
                iconSize: 50,
                color: isConnect ? Colors.lightGreen[100] : Colors.white,
                onPressed: () {
                  // setState(() {
                  //   writeKey(services[serviceID].chs[chrsID], KeyID["UpKey"]);
                  //   FlutterBeep.playSysSound(AndroidSoundIDs.TONE_PROP_BEEP);
                  // });
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
            icon: Icon(Icons.library_music_outlined),
            label: 'Rx mode',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.headset),
            label: 'Pairing',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.send_rounded),
            label: 'Tx mode',
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

  void writeKey(BleCh ch, int keynum) {
    // String data = "K01";
    List<int> bytes = utf8.encode('K' + keynum.toString());
    device.writeData(ch: ch, data: Uint8List.fromList(bytes));
  }
}

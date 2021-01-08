import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:bluetooth_ble/bluetooth_ble.dart';
import 'package:flutter/material.dart';

// final String serviceUUID = "49535343-fe7d-4ae5-8fa9-9fafd205e455";
// final String rxUUID = "49535343-8841-43f4-a8d4-ecbe34729bb3";
final String serviceUUID = "49535343-fe7d-4ae5-8fa9-9faf82853364";
final String rxUUID = "49535343-8841-43f4-a8d4-ec0222990568";

class ServicePage extends StatefulWidget {
  final BleDevice device;
  final BleService service;

  const ServicePage({
    Key key,
    this.device,
    this.service,
  }) : super(key: key);

  @override
  _ServicePageState createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  BleDevice get device => widget.device;

  StreamSubscription<BleNotifyData> sub;

  List<String> receiveData = [];

  @override
  void initState() {
    super.initState();
    sub = device.notifyDataStream.listen((data) {
      print("Receive message: ${data.data.toList()}");
      receiveData.add(utf8.decode(data.data.toList()));
      if (mounted) {
        setState(() {});
      }
    });
    device.addListener(_onChange);
  }

  @override
  void dispose() {
    device.removeListener(_onChange);
    sub?.cancel();
    super.dispose();
  }

  void _onChange() {
    if (mounted && !device.isConnect) {
      showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Text("close connection, Quite?"),
              actions: <Widget>[
                FlatButton(
                  child: Text("No"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text("Yes"),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: widget.service,
        builder: (_, __) {
          final chs = widget.service.chs;
          return Scaffold(
            appBar: AppBar(
              title: Text("${device.name}"),
            ),
            body: ListView(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 100,
                      child: Column(
                        children: <Widget>[
                          RaisedButton(
                            child: Text("Write data1"),
                            onPressed: () {
                              for (var i = 0; i < chs.length; i++) {
                                if (chs[i].id == rxUUID) {
                                  writeData1(chs[i]);
                                  break;
                                }
                              }
                            },
                          ),
                          Container(
                            height: 10,
                          ),
                          RaisedButton(
                            child: Text("Write data2"),
                            onPressed: () {
                              for (var i = 0; i < chs.length; i++) {
                                if (chs[i].id == rxUUID) {
                                  writeData2(chs[i]);
                                  break;
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }

  // Widget _buildItem(BleCh ch) {
  //   return Row(
  //     children: <Widget>[
  //       Expanded(
  //         child: ListTile(
  //           title: Text(ch.id),
  //           subtitle: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: <Widget>[
  //               // Text("Monitoring: ${ch.notifying}"),
  //               // Container(height: 10),
  //               // Text("notifiable: ${ch.notifiable}"),
  //               Text("service: ${ch.service.id}"),
  //               // Text("read: ${ch.read}"),
  //               // Text("write: ${ch.write}"),
  //               // Text("writeNoResponse: ${ch.writeNoResponse}"),
  //             ],
  //           ),
  //         ),
  //       ),
  //       Container(
  //         width: 100,
  //         child: Column(
  //           children: <Widget>[
  //             RaisedButton(
  //               child: Text("Write data1"),
  //               onPressed: () {
  //                 writeData(ch);
  //               },
  //             ),
  //             Container(
  //               height: 10,
  //             ),
  //             RaisedButton(
  //               child: Text("Write data2"),
  //               onPressed: () {
  //                 writeData2(ch);
  //               },
  //             ),
  //             // RaisedButton(
  //             //   child: Text("Monitor"),
  //             //   onPressed: () {
  //             //     device.changeNotify(ch);
  //             //   },
  //             // ),
  //             // Container(
  //             //   height: 10,
  //             // ),
  //             // RaisedButton(
  //             //   child: Text("show message"),
  //             //   onPressed: () {
  //             //     final style = Theme.of(context).textTheme.body2;
  //             //     showDialog(
  //             //       context: context,
  //             //       builder: (_) => Center(
  //             //         child: Container(
  //             //           color: Colors.white,
  //             //           child: ListView.builder(
  //             //             itemBuilder: (BuildContext context, int index) {
  //             //               return Container(
  //             //                 height: 30,
  //             //                 alignment: Alignment.center,
  //             //                 child: Text(
  //             //                   receiveData[index],
  //             //                   style: style,
  //             //                 ),
  //             //               );
  //             //             },
  //             //             itemCount: receiveData.length,
  //             //             shrinkWrap: true,
  //             //           ),
  //             //         ),
  //             //       ),
  //             //     );
  //             //   },
  //             // ),
  //             // RaisedButton(
  //             //   child: Text("Copy message"),
  //             //   onPressed: () {
  //             //     final serviceUUID = ch.service.id;
  //             //     final characteristicsUUID = ch.id;
  //             //     final deviceName = ch.service.device.name;
  //             //     final deviceId = ch.service.device.id;
  //             //     final text = "deviceName: $deviceName\n"
  //             //         "deviceId: $deviceId\n"
  //             //         "service: $serviceUUID\n"
  //             //         "characteristics: $characteristicsUUID";
  //             //     Clipboard.setData(ClipboardData(text: text));
  //             //     showToast("Copied:\n $text");
  //             //   },
  //             // ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  void writeData1(BleCh ch) {
    // String data = "abc\n";
    // String data = "12345678901234567890qwertyuiopasdfghjklzxcvbnm" * 20;
    // data = "$data\n";
    // String data = "abc234567890-34567890-4567890567890\n";
    // final list = utf8.encode(data);

    final data = <int>[0x1D, 0x67, 0x68];
    device.writeData(ch: ch, data: Uint8List.fromList(data));
  }

  void writeData2(BleCh ch) {
    final data = <int>[0x1D, 0x69, 0x70];
    device.writeData(ch: ch, data: Uint8List.fromList(data));
  }
}

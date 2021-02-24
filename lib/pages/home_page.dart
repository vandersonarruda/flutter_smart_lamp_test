import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_lamp_app/components/message_screen.dart';
import 'package:smart_lamp_app/models/device_model.dart';
import 'package:smart_lamp_app/pages/details_page.dart';
import 'package:smart_lamp_app/pages/device_page.dart';
import 'package:smart_lamp_app/pages/search_device_page.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BluetoothState>(
        stream: FlutterBlue.instance.state,
        initialData: BluetoothState.unknown,
        builder: (c, snapshot) {
          final state = snapshot.data;
          if (state == BluetoothState.on) {
            return ListDevicesPage();
          }
          return BluetoothOffScreen(state: state);
        });
  }
}

class ListDevicesPage extends StatefulWidget {
  @override
  _ListDevicesPageState createState() => _ListDevicesPageState();
}

class _ListDevicesPageState extends State<ListDevicesPage> {
  List<Device> _devices = [];
  SharedPreferences sharedPreferences;

  FlutterBlue flutterBlue = FlutterBlue.instance;

  @override
  void initState() {
    initSharedPreferences();
    super.initState();
  }

  initSharedPreferences() async {
    sharedPreferences = await SharedPreferences.getInstance();
    loadData();
    //saveData();
    checkDeviceAvailable();
    //checkDeviceConnected();

    //print(getInfoDevice("FF956A9B-BC85-6C6A-6AB4-71971FB58ECE"));

    //checkDeviceStatus();

    // FF956A9B-BC85-6C6A-6AB4-71971FB58ECE
    // AAF2D70D-0CBE-D3AD-4A29-D9957EC122C0

    // Device temp = getInfoDevice("AAF2D70D-0CBE-D3AD-4A29-D9957EC122C0");
    // print(temp);

    // _devices.map((e) {
    //   print("aaaa");
    //   //print("ID ${e.id.toString()}");
    //   // if (e.id.contains(id)) {
    //   //   tmp = e;
    //   // }
    // });

    Timer.periodic(Duration(seconds: 5), (timer) {
      //print(DateTime.now());
      //checkDeviceStatus();
      checkDeviceConnected();
    });
  }

  // Device getInfoDevice(String id) {
  //   print("aaaa");
  //   Device tmp;
  //   print(_devices.length);
  //   _devices.map((e) {
  //     print("dff");
  //     //print("ID ${e.id.toString()}");
  //     // if (e.id.contains(id)) {
  //     //   tmp = e;
  //     // }
  //   });
  //   return tmp;
  // }

  // checkDeviceStatus() {
  //   _devices.map((e) {
  //     print("aaa");
  //   });
  //   // _devices.map((e) {
  //   //   print(e.device.state.toString());
  //   //   // if (e.connected == false) {
  //   //   //   flutterBlue.connectedDevices.then((value) {
  //   //   //     value.map((item) {
  //   //   //       if (e.id == item.id.toString()) {
  //   //   //         print(item.id.toString());
  //   //   //         setState(() {
  //   //   //           e.connected = true;
  //   //   //           e.device = item;
  //   //   //         });
  //   //   //       }
  //   //   //     }).toList();
  //   //   //   });
  //   //   // }
  //   // }).toList();
  // }

  checkDeviceAvailable() {
    flutterBlue.startScan(timeout: Duration(seconds: 4));

    flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
        _devices.map((e) async {
          if (e.id.contains(r.device.id.toString())) {
            // setState(() {
            //   e.connected = true;
            //   e.device = r.device;
            // });

            await r.device.connect(autoConnect: true);
            await r.device.discoverServices();

            flutterBlue.stopScan();
          }
        }).toList();
      }
    });

    flutterBlue.stopScan();
  }

  checkDeviceConnected() {
    _devices.map((e) {
      flutterBlue.connectedDevices.then((value) {
        if ((value.singleWhere((it) => it.id.toString() == e.id.toString(),
                orElse: () => null)) !=
            null) {
          //print('Exists! ${e.id.toString()}');
          setState(() {
            e.connected = true;
          });
        } else {
          //print('NO!  ${e.id.toString()}');
          setState(() {
            e.connected = false;
          });

          //checkDeviceAvailable();
        }
      });
    }).toList();
  }

  Device getInfoDevice(String id) {
    Device tmp;
    _devices.map((e) {
      if (e.id.contains(id)) {
        tmp = e;
      }
    }).toList();
    return tmp;
  }

  bool checkDeviceID({String id}) {
    bool contain = false;
    _devices.map((d) {
      if (d.id == id.toString()) contain = true;
    }).toList();
    return contain;
  }

  void addDevice(Device item) {
    if (!checkDeviceID(id: item.id)) {
      setState(() => _devices.add(item));
      saveData();
    }
  }

  void removeDevice(Device item) {
    setState(() => _devices.remove(item));
    saveData();
  }

  void saveData() {
    List<String> spList = _devices.map((e) => json.encode(e.toMap())).toList();
    sharedPreferences.setStringList('list', spList);
    setState(() {});
  }

  void loadData() {
    List<String> spList = sharedPreferences.getStringList('list');
    setState(() {
      _devices = spList.map((e) => Device.fromMap(json.decode(e))).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Smart Lamp"),
        actions: [
          FlatButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return SearchDevicePage(addDevice);
                }));
              },
              child: Icon(
                Icons.add,
                color: Colors.white,
              )),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              children: _devices.map((e) {
                //print(_devices.length);
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text("${e.name}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.id),
                        Text("Power: ${e.power}"),
                        Text("Connected: ${e.connected}"),
                        if (e.device != null) Text("Device: ${e.device.name}"),
                        Text(
                            "Scene: ${e.scene} | RGB: ${e.red}-${e.green}-${e.blue}"),
                      ],
                    ),
                    tileColor: Colors.amber,
                    onTap: () {
                      checkDeviceAvailable();
                      // Navigator.of(context)
                      //     .push(MaterialPageRoute(builder: (context) {
                      //   return DetailsPage(
                      //     device: e.device,
                      //     detail: e,
                      //     onDelete: removeDevice,
                      //     onUpdate: saveData,
                      //   );
                      // }));
                    },
                  ),
                );
              }).toList(),
            ),
            StreamBuilder<List<BluetoothDevice>>(
              stream: Stream.periodic(Duration(seconds: 2))
                  .asyncMap((_) => FlutterBlue.instance.connectedDevices),
              initialData: [],
              builder: (c, snapshot) {
                //print("DEVICE ${_devices.length}");
                // print(_devices);

                //device.add(Device(title: "Test", id: 1));
                //print(device[0].id);
                //print("Devices: ${snapshot.data.length}");
                //print(device.length);

                if (snapshot.data.length < 1) {
                  return Text('Nenhum device');
                  // return MessageOnScreen(
                  //   title: 'Nenhum Dispositivo\nConfigurado',
                  //   description:
                  //       'Para visualizar seus dispositivos conectados,\nhabilite o bluetooth nas preferências.',
                  //   icon: Icons.lightbulb_outline_sharp,
                  // );
                } else {
                  return Column(
                    children: snapshot.data.map((d) {
                      //if (d.name.contains(kBluetoothName)) {
                      // final Device dev = Device(title: "Test", id: 1, device: d);
                      // if (!device.contains(d)) {
                      //   device.add(Device(title: "Test", id: 1, device: d));
                      // }
                      //print(device);

                      //print(device[0]);
                      //print(d);

                      Device dataLight = getInfoDevice(d.id.toString());

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          color: Colors.lightBlue[100],
                          child: ListTile(
                            title: Column(
                              children: [
                                Text(d.name),
                                if (dataLight != null)
                                  Text("POWER ${dataLight.power.toString()}"),
                                if (dataLight != null)
                                  Text("SCENE ${dataLight.scene.toString()}"),
                              ],
                            ),
                            subtitle: Text(d.id.toString()),
                            onTap: () {
                              _devices.map((e) {
                                if (e.id == d.id.toString()) {
                                  // print(e.id);
                                  // print(e.name);
                                  // print(e.power);

                                  /* Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return DetailsPage(
                                      device: d,
                                      detail: dataLight,
                                      onDelete: removeDevice,
                                      onUpdate: saveData,
                                    );
                                  })); */

                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return DevicePage(
                                      device: d,
                                      detail: dataLight,
                                      onDelete: removeDevice,
                                      onUpdate: saveData,
                                    );
                                  }));
                                }
                              }).toList();

                              print("----");
                              // Navigator.of(context)
                              //     .push(MaterialPageRoute(builder: (context) {
                              //   return DetailsPage(device: d);
                              // }));
                            },
                            trailing: StreamBuilder<BluetoothDeviceState>(
                              stream: d.state,
                              initialData: BluetoothDeviceState.disconnected,
                              builder: (c, snapshot) {
                                if (snapshot.data ==
                                    BluetoothDeviceState.connected) {}
                                return Icon(Icons.bluetooth_connected_rounded);
                                // if (snapshot.data ==
                                //     BluetoothDeviceState.disconnected) {}
                                // return Icon(Icons.bluetooth_disabled_rounded);
                                //return Text(snapshot.data.toString());
                                // return Icon(
                                //   Icons.bluetooth,
                                //   color: Colors.blueAccent,
                                // );
                              },
                            ),
                          ),
                        ),
                      );
                      // } else {
                      //   return Container();
                      // }
                    }).toList(),
                  );
                }
              },
            ),
          ],
        ),
      ),

      // body: Container(
      //   child: MessageScreen(
      //     title: "Nenhum Dispositivo\nCadastrado",
      //     body: "Configure uma nova luminária\nclicando no botão +",
      //     icon: Icons.lightbulb_outline_rounded,
      //   ),
      // ),
    );
  }
}

class BluetoothOffScreen extends StatelessWidget {
  final BluetoothState state;

  const BluetoothOffScreen({Key key, this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: MessageScreen(
          title: "Bluetooth Desligado",
          body:
              "Para visualizar seus dispositivos conectados,\nhabilite o bluetooth nas preferências.",
          icon: Icons.bluetooth_disabled_rounded,
        ),
      ),
    );
  }
}

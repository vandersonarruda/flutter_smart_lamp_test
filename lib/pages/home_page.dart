import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_lamp_app/components/message_screen.dart';
import 'package:smart_lamp_app/models/device_model.dart';
import 'package:smart_lamp_app/pages/details_page.dart';
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

    checkDeviceAvailable();
    checkDeviceConnected();

    //connectDeviceAvailable();
    //checkIsConnected();
  }

  checkDeviceAvailable() {
    flutterBlue.startScan(timeout: Duration(seconds: 4));

    flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
        _devices.map((e) async {
          if (e.id.contains(r.device.id.toString())) {
            setState(() {
              e.connected = true;
              e.device = r.device;
            });

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
      print("DEV ${e.connected}");

      if (e.connected == false) {
        flutterBlue.connectedDevices.then((value) {
          value.map((item) {
            if (e.id == item.id.toString()) {
              print(item.id.toString());
              setState(() {
                e.connected = true;
                e.device = item;
              });
            }
          }).toList();
        });
      }
    }).toList();
  }

  checkIsConnected() {
    flutterBlue.connectedDevices.then((value) {
      if (value.length > 0) {
        // if ((_devices.singleWhere(
        //         (it) => it.id == "AAF2D70D-0CBE-D3AD-4A29-D9957EC122C0",
        //         orElse: () => null)) !=
        //     null) {
        //   print('Tem!');
        // } else {
        //   print('Nao tem!');
        // }
        // value.map((item) {
        //   print(item.id.toString());
        // }).toList();
      }
    });

    // AAF2D70D-0CBE-D3AD-4A29-D9957EC122C0
    // 23A69362-00F9-6E01-FCAB-8DF2D7A0421E
    /*
    if ((_devices.singleWhere(
            (it) => it.id == "AAF2D70D-0CBE-D3AD-4A29-D9957EC122C0",
            orElse: () => null)) !=
        null) {
      print('Tem!');
    } else {
      print('Nao tem!');
    }
    */
    /*
    _devices.map((d) {
      bool temp = false;
      flutterBlue.connectedDevices.then((value) {
        if (value.length > 0) {
          value.map((item) {
            print("check");
            print(d.id);
            print(item.id.toString());
            if (d.id.contains(item.id.toString())) temp = true;
          }).toList();
        }
      });
      d.connected = temp;
    }).toList();
    */
    /*
    flutterBlue.connectedDevices.then((value) {
      print("CHECK ${value.length}");
      if (value.length > 0) {
        value.map((item) {
          _devices.map((d) {
            if (d.id.contains(item.id.toString())) {
              d.connected = true;
            }
          }).toList();
        }).toList();
      }
      // } else {
      //   searchDeviceAvailable();
      // }
    });
    */
  }

  connectDeviceAvailable() {
    flutterBlue.startScan(timeout: Duration(seconds: 4));

    flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
        _devices.map((e) async {
          if (e.id.contains(r.device.id.toString())) {
            print("Device Connected: ${r.device.id}");
            await r.device.connect(autoConnect: true);
            await r.device.discoverServices();
            //e.connected = true;
          } else {
            //e.connected = false;
          }
        }).toList();
      }
    });

    flutterBlue.stopScan();
  }

  bool checkDeviceID({String id}) {
    bool contain = false;
    _devices.map((d) {
      if (d.id == id.toString()) contain = true;
    }).toList();
    return contain;
  }

  // _devices.map((dev) {
  //   if (dev.id.contains(item.id.toString())) {
  //     dev.connected = true;
  //   }
  // }).toList();

  /////////

  // if ((_devices.singleWhere((it) => it.connected == false,
  //         orElse: () => null)) !=
  //     null) {
  //   print('Already exists!');
  // } else {
  //   print('Added!');
  // }

  // flutterBlue.connectedDevices.then((value) {
  //   print("> Devices conectados: ${value.length}");

  //   if (value.length > 0) {}

  //   /*
  //   if (value.length > 0) {
  //     value.map((e) {
  //       print(e.id.toString());
  //       if (e.id.toString() == d.id) {
  //         print("> Device encontrado");
  //         d.connected = true;
  //       }
  //     }).toList();
  //   }
  //   */
  // });

  /*
    print("####");

    _devices.map((d) {
      print("id: ${d.id}");
      print("connected: ${d.connected}");

      //if (d.connected == false || d.connected == null) {

      flutterBlue.connectedDevices.then((value) {
        print("> Devices conectados: ${value.length}");

        if (value.length > 0) {
          value.map((e) {
            print(e.id.toString());
            if (e.id.toString() == d.id) {
              print("> Device encontrado");
              d.connected = true;
            } 
          }).toList();
        }
      });
    }).toList();

    searchDeviceAvailable();
    */

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
      body: Column(
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
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return DetailsPage(
                        device: e.device,
                        detail: e,
                        onDelete: removeDevice,
                        onUpdate: saveData,
                      );
                    }));
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
                return Text('asdas');
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
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        color: Colors.lightBlue[100],
                        child: ListTile(
                          title: Text(d.name),
                          subtitle: Text(d.id.toString()),
                          onTap: () {
                            print("----");
                            _devices.map((e) {
                              if (e.id == d.id.toString()) {
                                print(e.id);
                                print(e.name);
                                print(e.power);

                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (context) {
                                  return DetailsPage(
                                    device: d,
                                    detail: e,
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
                              //return Text(snapshot.data.toString());
                              return Icon(
                                Icons.bluetooth,
                                color: Colors.blueAccent,
                              );
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

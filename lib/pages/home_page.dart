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

  @override
  void initState() {
    initSharedPreferences();
    super.initState();
  }

  initSharedPreferences() async {
    sharedPreferences = await SharedPreferences.getInstance();
    loadData();
  }

  void addDevice(Device item) {
    _devices.add(item);
    saveData();
  }

  void removeDevice(Device item) {
    _devices.remove(item);
    saveData();
  }

  void saveData() {
    List<String> spList = _devices.map((e) => json.encode(e.toMap())).toList();
    sharedPreferences.setStringList('list', spList);
    print("SPLIST $spList");
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
                  title: Text("${e.name} (${e.power})"),
                  subtitle: Text(e.id),
                  tileColor: Colors.amber,
                  onTap: () {
                    // Navigator.of(context)
                    //     .push(MaterialPageRoute(builder: (context) {
                    //   //return Container();
                    //   return DetailsPage(
                    //     device: e.device,
                    //     data: [e],
                    //   );
                    // })
                    //);
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

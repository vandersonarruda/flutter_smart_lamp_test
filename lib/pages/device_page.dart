import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:smart_lamp_app/models/device_model.dart';

class DevicePage extends StatefulWidget {
  final BluetoothDevice device;
  final Device detail;
  final void Function(Device) onDelete;
  final void Function() onUpdate;

  const DevicePage(
      {Key key, this.device, this.detail, this.onDelete, this.onUpdate})
      : super(key: key);

  @override
  _DevicePageState createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  List<BluetoothService> services;

  serviceDevice() async {
    services = await widget.device.discoverServices();
    services.forEach((service) async {
      var characteristics = service.characteristics;
      for (BluetoothCharacteristic c in characteristics) {
        List<int> value = await c.read();
        print(utf8.decode(value));
      }
    });
  }

  sendMessage(String msg) async {
    services = await widget.device.discoverServices();
    services.forEach((service) async {
      var characteristics = service.characteristics;
      for (BluetoothCharacteristic c in characteristics) {
        print(msg);
        await c.write(utf8.encode(msg));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //widget.device.discoverServices();
    serviceDevice();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name),
        centerTitle: false,
        elevation: 0,
        actions: [
          StreamBuilder<BluetoothDeviceState>(
            stream: widget.device.state,
            initialData: BluetoothDeviceState.connecting,
            builder: (c, snapshot) {
              VoidCallback onPressed;
              String text;
              switch (snapshot.data) {
                case BluetoothDeviceState.connected:
                  onPressed = () {
                    widget.onDelete(widget.detail);
                    widget.device.disconnect();
                    return Navigator.of(context).pop();
                  };
                  text = 'DESCONECTAR';
                  break;
                default:
                  onPressed = null;
                  text = snapshot.data.toString().substring(21).toUpperCase();
                  break;
              }
              return FlatButton(
                  onPressed: onPressed,
                  child: Text(
                    text,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .button
                        .copyWith(color: Colors.white),
                  ));
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder<List<BluetoothService>>(
              stream: widget.device.services,
              initialData: [],
              builder: (c, snapshot) {
                //print(snapshot.data);
                return Column(
                  children: [
                    Text("Servicos"),
                    FlatButton(
                        color: Colors.amber,
                        minWidth: 200,
                        height: 50,
                        onPressed: () {
                          sendMessage("Vandeco");
                        },
                        child: Text(
                          "test",
                          style: TextStyle(fontSize: 20),
                        )),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

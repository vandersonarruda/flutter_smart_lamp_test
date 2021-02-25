import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:smart_lamp_app/components/circle_color_picker.dart';
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

  bool releaseMessage = true;
  Color _currentColor = Colors.blue;
  // List<int> currentRGB = [0, 0, 0];

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
        //print(msg);
        await c.write(utf8.encode(msg));
      }
    });
  }

  sendChangeColor(Color color) {
    if (releaseMessage) {
      releaseMessage = false;
      sendMessage(color.toString());

      Future.delayed(
          const Duration(milliseconds: 500), () => releaseMessage = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    //widget.device.discoverServices();
    serviceDevice();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name),
        // backgroundColor: _currentColor,
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
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
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
                        sendMessage("Envio Teste");
                      },
                      child: Text(
                        "test",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    Switch.adaptive(
                      // activeColor: Theme.of(context).primaryColor,
                      value: widget.detail.power,
                      onChanged: (value) {
                        setState(
                            () => widget.detail.power = !widget.detail.power);
                        sendMessage("p:${widget.detail.power}");
                        widget.onUpdate();
                      },
                    ),
                    CircleColorPicker(
                      size: Size(
                        MediaQuery.of(context).size.width * 0.7,
                        MediaQuery.of(context).size.width * 0.7,
                      ),
                      initialColor: _currentColor,
                      onChanged: (Color color) {
                        _currentColor = color;
                        //print(_currentColor);
                        //sendChangeColor(_currentColor);
                      },
                      onRelease: () {
                        setState(() {});

                        //sendChangeColor(_currentColor);
                        sendMessage(
                            "r:${widget.detail.red}-g:${widget.detail.green}-b:${widget.detail.blue}");
                        widget.onUpdate();
                      },
                      strokeWidth: 25.0,
                      thumbSize: 50,
                      colorCodeBuilder: (context, color) {
                        widget.detail.red = color.red;
                        widget.detail.green = color.green;
                        widget.detail.blue = color.blue;

                        return Container();
                        // return Text(
                        //   'rgb(${color.red}, ${color.green}, ${color.blue})',
                        //   style: const TextStyle(
                        //     fontSize: 24,
                        //     fontWeight: FontWeight.bold,
                        //     color: Colors.black,
                        //   ),
                        // );
                      },
                    ),
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

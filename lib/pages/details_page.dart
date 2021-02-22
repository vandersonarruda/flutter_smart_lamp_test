import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:smart_lamp_app/components/widgets.dart';
import 'package:smart_lamp_app/models/device_model.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({
    Key key,
    @required this.device,
    @required this.detail,
    @required this.onDelete,
    @required this.onUpdate,
  }) : super(key: key);

  final BluetoothDevice device;
  final Device detail;
  final void Function(Device) onDelete;
  final void Function() onUpdate;

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  List<int> _getRandomBytes() {
    final math = Random();
    return [
      math.nextInt(255),
      math.nextInt(255),
      math.nextInt(255),
      math.nextInt(255)
    ];
  }

  List<Widget> _buildServiceTiles(List<BluetoothService> services) {
    return services
        .map(
          (s) => ServiceTile(
            service: s,
            characteristicTiles: s.characteristics
                .map(
                  (c) => CharacteristicTile(
                    characteristic: c,
                    onReadPressed: () async {
                      print('recebido');
                      print(await c.read());
                      return c.read();
                    },
                    onWritePressed: () async {
                      print('enviado');
                      await c.write(utf8.encode("Vanderson"));
                      // await c.write(_getRandomBytes());
                      //c.read();
                    },
                    onNotificationPressed: () async {
                      await c.setNotifyValue(!c.isNotifying);
                      await c.read();
                    },
                    descriptorTiles: c.descriptors
                        .map(
                          (d) => DescriptorTile(
                            descriptor: d,
                            onReadPressed: () => d.read(),
                            onWritePressed: () => d.write(_getRandomBytes()),
                          ),
                        )
                        .toList(),
                  ),
                )
                .toList(),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    print("Details->");
    print(widget.device);
    print(widget.detail.name);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name),
        centerTitle: false,
        elevation: 0,
        // actions: [Switch(value: true, onChanged: (value) {})],
        actions: <Widget>[
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
                // case BluetoothDeviceState.disconnected:
                //   onPressed = () {
                //     return widget.device.connect();
                //   };
                //   text = 'CONECTAR';
                //   break;
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
          children: <Widget>[
            Text("${Platform.isIOS}"),
            Switch.adaptive(
              // activeColor: Theme.of(context).primaryColor,
              value: widget.detail.power,
              onChanged: (value) {
                setState(() => widget.detail.power = !widget.detail.power);
                widget.onUpdate();
              },
            ),
            StreamBuilder<BluetoothDeviceState>(
              stream: widget.device.state,
              initialData: BluetoothDeviceState.connecting,
              builder: (c, snapshot) {
                // return IconButton(
                //   icon: Icon(Icons.send),
                //   onPressed: () {},
                // );

                return ListTile(
                  leading: (snapshot.data == BluetoothDeviceState.connected)
                      ? Icon(Icons.bluetooth_connected)
                      : Icon(Icons.bluetooth_disabled),
                  title: Text(
                      'Device is ${snapshot.data.toString().split('.')[1]}.'),
                  subtitle: Text('${widget.device.id}'),
                  trailing: StreamBuilder<bool>(
                    stream: widget.device.isDiscoveringServices,
                    initialData: false,
                    builder: (c, snapshot) => IndexedStack(
                      index: snapshot.data ? 1 : 0,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.refresh),
                          onPressed: () => widget.device.discoverServices(),
                        ),
                        IconButton(
                          icon: SizedBox(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.grey),
                            ),
                            width: 18.0,
                            height: 18.0,
                          ),
                          onPressed: null,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            // StreamBuilder<int>(
            //   stream: widget.device.mtu,
            //   initialData: 0,
            //   builder: (c, snapshot) => ListTile(
            //     title: Text('MTU Size'),
            //     subtitle: Text('${snapshot.data} bytes'),
            //     trailing: IconButton(
            //       icon: Icon(Icons.edit),
            //       onPressed: () => widget.device.requestMtu(223),
            //     ),
            //   ),
            // ),
            // StreamBuilder<List<BluetoothService>>(
            //   stream: widget.device.services,
            //   initialData: [],
            //   builder: (c, snapshot) {
            //     return Column(
            //       children: _buildServiceTiles(snapshot.data),
            //     );
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}

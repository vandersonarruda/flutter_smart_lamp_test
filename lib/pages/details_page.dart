import 'dart:convert';

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
  Color _color = Colors.blue;
  Color _color2 = Colors.red;
  Color pickerColor = Color(0xff443a49);
  Color currentColor = Color(0xff443a49);

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  // List<int> _getRandomBytes() {
  //   final math = Random();
  //   return [
  //     math.nextInt(255),
  //     math.nextInt(255),
  //     math.nextInt(255),
  //     math.nextInt(255)
  //   ];
  // }

  List<Widget> _buildServiceTiles(List<BluetoothService> services) {
    return services.map(
      (s) {
        return ServiceTile(
          service: s,
          characteristicTiles: s.characteristics.map(
            (c) {
              return CharacteristicTile(
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
                onSendMessage: (String msg) async {
                  print('msg ${msg}');
                  await c.write(utf8.encode(msg));
                  // await c.write(_getRandomBytes());
                  //c.read();
                },
                descriptorTiles: c.descriptors
                    .map(
                      (d) => DescriptorTile(
                        descriptor: d,
                        onReadPressed: () => d.read(),
                        // onWritePressed: () => d.write(_getRandomBytes()),
                      ),
                    )
                    .toList(),
              );
            },
          ).toList(),
        );
      },
    ).toList();
  }

  test() async {
    // print("OK");

    // List<BluetoothService> services = await widget.device.discoverServices();
    // services.forEach((service) async {
    //   var characteristics = service.characteristics;
    //   for (BluetoothCharacteristic c in characteristics) {
    //     List<int> value = await c.read();
    //     print(utf8.decode(value));
    //     await c.write(utf8.encode("Arruda"));
    //   }
    //});

//     var descriptors = characteristic.descriptors;
// for(BluetoothDescriptor d in descriptors) {
//     List<int> value = await d.read();
//     print(value);
// }

// // Writes to a descriptor
// await d.write([0x12, 0x34])
  }

  @override
  Widget build(BuildContext context) {
    // print("Details->");
    // print(widget.device);
    // print(widget.detail.name);

    //test();

    widget.device.discoverServices();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name),
        centerTitle: false,
        elevation: 0,
        // actions: [Switch(value: true, onChanged: (value) {})],
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
          children: [
            // Text("${Platform.isIOS}"),
            Switch.adaptive(
              // activeColor: Theme.of(context).primaryColor,
              value: widget.detail.power,
              onChanged: (value) {
                setState(() => widget.detail.power = !widget.detail.power);
                widget.onUpdate();
              },
            ),

            StreamBuilder<List<BluetoothService>>(
              stream: widget.device.services,
              initialData: [],
              builder: (c, snapshot) {
                return Column(
                  children: _buildServiceTiles(snapshot.data),
                );
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

                //test();

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
                        // IconButton(
                        //   icon: Icon(Icons.refresh),
                        //   onPressed: () => widget.device.discoverServices(),
                        // ),
                        // IconButton(
                        //   icon: SizedBox(
                        //     child: CircularProgressIndicator(
                        //       valueColor: AlwaysStoppedAnimation(Colors.grey),
                        //     ),
                        //     width: 18.0,
                        //     height: 18.0,
                        //   ),
                        //   onPressed: null,
                        // ),
                        IconButton(
                          icon: Icon(Icons.home),
                          onPressed: () {
                            return widget.device.discoverServices();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 30),
            /* StreamBuilder<List<BluetoothService>>(
              stream: widget.device.services,
              initialData: [],
              builder: (c, snapshot) {
                return Column(
                    children: snapshot.data.map(
                  (s) {
                    // print(s);
                    if (s.characteristics.length > 0) {
                      s.characteristics.map((c) {
                        return StreamBuilder<List<int>>(
                          stream: c.value,
                          initialData: c.lastValue,
                          builder: (c, snapshot) {
                            final value = snapshot.data;
                            return ExpansionTile(
                              title: ListTile(
                                title: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Characteristic'),
                                    // Text(
                                    //     '0x${c.uuid.toString().toUpperCase().substring(4, 8)}',
                                    //     style: Theme.of(context)
                                    //         .textTheme
                                    //         .bodyText1
                                    //         .copyWith(
                                    //             color: Theme.of(context)
                                    //                 .textTheme
                                    //                 .caption
                                    //                 .color))
                                  ],
                                ),
                                subtitle: Text(value.toString()),
                                contentPadding: EdgeInsets.all(0.0),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  // IconButton(
                                  //   icon: Icon(
                                  //     Icons.file_download,
                                  //     color: Theme.of(context).iconTheme.color.withOpacity(0.5),
                                  //   ),
                                  //   onPressed: onReadPressed,
                                  // ),
                                  // IconButton(
                                  //   icon: Icon(Icons.send_outlined,
                                  //       color: Theme.of(context).iconTheme.color.withOpacity(0.5)),
                                  //   onPressed: onWritePressed,
                                  // ),
                                  // IconButton(
                                  //   icon: Icon(
                                  //       characteristic.isNotifying
                                  //           ? Icons.sync_disabled
                                  //           : Icons.sync,
                                  //       color: Theme.of(context).iconTheme.color.withOpacity(0.5)),
                                  //   onPressed: onNotificationPressed,
                                  // )
                                ],
                              ),
                              //children: descriptorTiles,
                            );
                          },
                        );
                      });

                      // return Column(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: [
                      //     Text("Testando"),
                      //     CircleColorPicker(
                      //       initialColor: _color2,
                      //       onChanged: (Color color) {
                      //         setState(() {
                      //           _color2 = color;
                      //           // onWritePressed();
                      //           print("eeeee");
                      //           //c.write(utf8.encode(color.toString()));
                      //         });
                      //       },
                      //       strokeWidth: 13.0,
                      //       thumbSize: 26,
                      //       colorCodeBuilder: (context, color) {
                      //         return Container();

                      //       },
                      //     ),

                      //     // Text('Service'),
                      //     // Text('0x${service.uuid.toString().toUpperCase().substring(4, 8)}',
                      //     //     style: Theme.of(context)
                      //     //         .textTheme
                      //     //         .bodyText1
                      //     //         .copyWith(color: Theme.of(context).textTheme.caption.color))
                      //   ],
                      // );
                    } else {
                      return Container();
                    }

                    /* return ServiceTile(
                      service: s,
                      characteristicTiles: s.characteristics.map(
                        (c) {
                          return CharacteristicTile(
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
                                    // onWritePressed: () => d.write(_getRandomBytes()),
                                  ),
                                )
                                .toList(),
                          );
                        },
                      ).toList(),
                    ); */
                  },
                ).toList());
              },
            ), */
            // CircleColorPicker(
            //   initialColor: _color,
            //   onChanged: (Color color) {
            //     setState(() {
            //       _color = color;
            //     });
            //   },
            //   textStyle: TextStyle(color: Colors.white, fontSize: 30.0),
            // ),
            // ColorPicker(
            //   pickerColor: pickerColor,
            //   onColorChanged: changeColor,
            //   //showLabel: true,
            //   pickerAreaHeightPercent: 0.8,
            // ),

            /* CircleColorPicker(
              initialColor: _color2,
              onChanged: (Color color) {
                setState(() {
                  _color2 = color;
                  // onWritePressed();
                  print("aaaa");
                  //c.write(utf8.encode(color.toString()));
                });
              },
              strokeWidth: 13.0,
              thumbSize: 26,
              colorCodeBuilder: (context, color) {
                return Container();
                // return Text(
                //   'RGB(${color.red},${color.green},${color.blue})',
                //   style: TextStyle(
                //     fontSize: 24,
                //     color: Colors.black,
                //     // fontWeight: FontWeight.bold,
                //   ),
                //);
              },
            ),
 */
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

            /* StreamBuilder<List<BluetoothService>>(
              stream: widget.device.services,
              initialData: [],
              builder: (c, snapshot) {
                return Column(
                    children: snapshot.data.map(
                  (s) {
                    return ServiceTile(
                      service: s,
                      characteristicTiles: s.characteristics.map(
                        (c) {
                          return CharacteristicTile(
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
                                    // onWritePressed: () => d.write(_getRandomBytes()),
                                  ),
                                )
                                .toList(),
                          );
                        },
                      ).toList(),
                    );
                  },
                ).toList());
              },
            ), */

            /* StreamBuilder<List<BluetoothService>>(
              stream: widget.device.services,
              initialData: [],
              builder: (c, snapshot) {
                return Column(
                    children: snapshot.data.map(
                  (s) {
                    return ServiceTile(
                      service: s,
                      characteristicTiles: s.characteristics.map(
                        (c) {
                          return CharacteristicTile(
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
                                    // onWritePressed: () => d.write(_getRandomBytes()),
                                  ),
                                )
                                .toList(),
                          );
                        },
                      ).toList(),
                    );
                  },
                ).toList());
              },
            ), */
          ],
        ),
      ),
    );
  }
}

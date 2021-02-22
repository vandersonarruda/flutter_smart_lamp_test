import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:smart_lamp_app/components/widgets.dart';
import 'package:smart_lamp_app/models/device_model.dart';

class SearchDevicePage extends StatelessWidget {
  final void Function(Device) onSubmit;

  SearchDevicePage(this.onSubmit);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Buscando Dispositivos"),
        actions: [
          StreamBuilder<bool>(
            stream: FlutterBlue.instance.isScanning,
            initialData: false,
            builder: (c, snapshot) {
              if (snapshot.data) {
                return FlatButton(
                  onPressed: () {
                    FlutterBlue.instance.stopScan();
                  },
                  child: Icon(
                    Icons.pause_circle_filled,
                    color: Colors.white,
                  ),
                );
              } else {
                return FlatButton(
                  onPressed: () {
                    FlutterBlue.instance
                        .startScan(timeout: Duration(seconds: 4));
                  },
                  child: Icon(
                    Icons.refresh_rounded,
                    color: Colors.white,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return FlutterBlue.instance.startScan(timeout: Duration(seconds: 4));
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Luminárias Smart",
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 10),
                StreamBuilder<List<ScanResult>>(
                    stream: FlutterBlue.instance.scanResults,
                    initialData: [],
                    builder: (c, snapshot) {
                      // onStart
                      FlutterBlue.instance
                          .startScan(timeout: Duration(seconds: 4));

                      return Column(
                        children: snapshot.data.map((r) {
                          //if (r.device.name.contains(kBluetoothName)) {
                          return ScanResultTile(
                            result: r,
                            onTap: () async {
                              await r.device.connect(autoConnect: true);
                              await r.device.discoverServices();

                              //Device(id: id, name: name)
                              //final String bleID = r.device.id.toString();
                              final item = Device(
                                  id: r.device.id.toString(),
                                  name: r.device.name);
                              onSubmit(item);

                              return Navigator.of(context).pop();
                            },
                          );
                          // } else {
                          //   return Container();
                          // }
                        }).toList(),
                      );
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

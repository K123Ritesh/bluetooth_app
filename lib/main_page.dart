import 'dart:convert';

import 'package:bluetooth_app/device_tile.dart';
import 'package:bluetooth_app/response_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;
  BluetoothDevice? selectedDeviceHere;
  BluetoothConnection? connection;
  bool isConnected = false;
  List<Response> incomeData = [
    Response(response: 'Income Data 1', time: DateTime.now(), isInput: true),
    Response(response: 'Income Data 2', time: DateTime.now(), isInput: true),
    Response(response: 'Income Data 3', time: DateTime.now(), isInput: true)
  ];
  Future<void> getBondedDevices() async {
    List<BluetoothDevice> bondedDevices = [];
    try {
      bondedDevices = await FlutterBluetoothSerial.instance.getBondedDevices();
    } catch (e) {
      print('Error getting bonded devices: $e');
    }

    setState(() {
      devices = bondedDevices;
    });
  }

  Future<void> enableBluetooth() async {
    final isEnabled = await bluetooth.isEnabled ?? false;
    if (!isEnabled) {
      await bluetooth.requestEnable();
      return;
    }
    await getBondedDevices();
    if (mounted) {
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              padding: const EdgeInsets.only(top: 3, left: 20, right: 20),
              width: double.maxFinite,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 6,
                        width: 60,
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 149, 149, 149),
                            borderRadius: BorderRadius.circular(15)),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Text(
                          'Paired Devices',
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                      child: SingleChildScrollView(
                          child: Column(
                    children: [
                      for (int i = 0; i < devices.length; i++) ...[
                        DeviceTile(
                            deviceName: devices[i].name ?? 'Not Avaiblable',
                            deviceId: devices[i].address,
                            onclick: () async {}),
                        const SizedBox(
                          height: 20,
                        )
                      ]
                    ],
                  )))
                ],
              ),
            );
          }).whenComplete(() {
        if (selectedDeviceHere == null) {}
      });
    }
  }

  void checkPermissions() async {
    var statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();

    if (statuses[Permission.bluetooth]!.isGranted &&
        statuses[Permission.bluetoothScan]!.isGranted &&
        statuses[Permission.bluetoothConnect]!.isGranted) {
      await enableBluetooth();
    } else {
      print("Permissions not granted.");
    }
  }

  @override
  void initState() {
    super.initState();
    checkPermissions();
  }

  List<BluetoothDevice> devices = [];

  Future<void> _connect(BluetoothDevice device) async {
    try {
      setState(() {
        incomeData.clear();
      });
      final connection1 = await BluetoothConnection.toAddress(device.address);
      setState(() {
        connection = connection1;
        isConnected = true;
      });
      print('Connected to the device');
      connection1.input?.listen((Uint8List data) {
        print('Without Encoding :- $data');
        print('Data incoming: ${ascii.decode(data)}');
        setState(() {
          incomeData.add(Response(
              response: ascii.decode(data),
              time: DateTime.now(),
              isInput: true));
        });
      }).onDone(() {
        print('Disconnected by remote request');
      });
    } catch (e) {
      print('Cannot connect, exception occurred');
      print(e);
    }
  }

  TextEditingController inputController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 25, bottom: 10, left: 15),
            width: double.maxFinite,
            color: const Color.fromARGB(255, 75, 136, 242),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      flex: 8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bluetooth Connector',
                            style: TextStyle(fontSize: 20),
                          ),
                          Text('Not Connected')
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: IconButton(
                          onPressed: () {
                            checkPermissions();
                          },
                          icon: const Icon(
                            Icons.bluetooth,
                          )),
                    ),
                    Expanded(
                      flex: 2,
                      child: IconButton(
                          onPressed: () {
                            enableBluetooth();
                          },
                          icon: const Icon(
                            Icons.settings,
                          )),
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
          Expanded(
              child: SingleChildScrollView(
            child: Column(
              children: [
                if (isConnected)
                  for (int i = 0; i < incomeData.length; i++)
                    ResponseTile(
                        isInput: incomeData[i].isInput,
                        time: incomeData[i].time,
                        response: incomeData[i].response),
                Container(
                  margin: EdgeInsets.only(top: 40),
                  child: Text(
                    "NOT CONNECTED YET",
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  ),
                )
              ],
            ),
          )),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromARGB(255, 243, 74, 62)),
                  child: const Icon(
                    Icons.delete_sweep,
                    size: 30,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                    child: SizedBox(
                  height: 50,
                  child: Center(
                    child: TextField(
                      controller: inputController,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                          suffixIconColor: Colors.blue,
                          suffix: IconButton(
                              onPressed: () {
                                setState(() {
                                  incomeData.add(Response(
                                      response: inputController.text,
                                      time: DateTime.now(),
                                      isInput: false));
                                });
                              },
                              icon: const Icon(
                                Icons.send,
                                color: Colors.blue,
                              )),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          )),
                    ),
                  ),
                ))
              ],
            ),
          )
        ],
      ),
    );
  }
}

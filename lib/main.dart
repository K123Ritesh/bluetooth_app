import 'dart:convert';
import 'dart:developer';

import 'package:bluetooth_app/main_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MainPage(),
      theme: ThemeData.light(
        useMaterial3: true,
      ).copyWith(
          textTheme: TextTheme(bodyMedium: TextStyle(color: Colors.white)),
          iconTheme: IconThemeData(color: Colors.white)),
    );
  }
}

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({super.key});

  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;
  BluetoothDevice? selectedDeviceHere;
  BluetoothConnection? _connection;
  bool _isConnected = false;
  List<String> incomeData = [];
  @override
  void initState() {
    super.initState();
    checkPermissions();
  }

  TextEditingController _controller = TextEditingController();

  void enableBluetooth() async {
    final isEnabled = await bluetooth.isEnabled ?? false;
    if (!isEnabled) {
      await bluetooth.requestEnable();
    }
  }

  void checkPermissions() async {
    var statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    if (statuses[Permission.bluetooth]!.isGranted &&
        statuses[Permission.bluetoothScan]!.isGranted &&
        statuses[Permission.bluetoothConnect]!.isGranted &&
        statuses[Permission.location]!.isGranted) {
      enableBluetooth();
    } else {
      print("Permissions not granted.");
    }
  }

  Future<void> _connect(BluetoothDevice device) async {
    try {
      setState(() {
        incomeData.clear();
      });
      final connection = await BluetoothConnection.toAddress(device.address);
      setState(() {
        _connection = connection;
        _isConnected = true;
      });
      print('Connected to the device');
      connection.input?.listen((Uint8List data) {
        print('Without Encoding :- $data');
        print('Data incoming: ${ascii.decode(data)}');
        setState(() {
          incomeData.add(ascii.decode(data));
        });
      }).onDone(() {
        print('Disconnected by remote request');
      });
    } catch (e) {
      print('Cannot connect, exception occurred');
      print(e);
    }
  }

  void _disconnect() {
    _connection?.close();
    setState(() {
      _isConnected = false;
    });
    print('Disconnected');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Example'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _isConnected
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.red)),
                          height: 50,
                          width: 200,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 7),
                            child: TextField(
                              controller: _controller,
                            ),
                          )),
                      ElevatedButton(
                        onPressed: () {
                          log('${utf8.encode(_controller.text)}');
                          _connection?.output.add(Uint8List.fromList(
                              utf8.encode(_controller.text)));
                        },
                        child: const Text('Send Command '),
                      ),
                    ],
                  )
                : Container(),
            ElevatedButton(
              onPressed: () async {
                final BluetoothDevice? selectedDevice =
                    await Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const SelectBondedDevicePage()),
                );
                if (selectedDevice != null) {
                  setState(() {
                    selectedDeviceHere = selectedDevice;
                  });
                  _connect(selectedDevice);
                }
              },
              child: Text(_isConnected ? 'Disconnect' : 'Connect'),
            ),
            for (int i = 0; i < incomeData.length; i++) Text(incomeData[i])
          ],
        ),
      ),
    );
  }
}

class SelectBondedDevicePage extends StatefulWidget {
  const SelectBondedDevicePage({super.key});

  @override
  _SelectBondedDevicePage createState() => _SelectBondedDevicePage();
}

class _SelectBondedDevicePage extends State<SelectBondedDevicePage> {
  List<BluetoothDevice> devices = [];

  @override
  void initState() {
    super.initState();
    getBondedDevices();
  }

  void getBondedDevices() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Bonded Device'),
      ),
      body: ListView(
        children: devices
            .map((device) => ListTile(
                  title: Text(device.name ?? 'Unknown device'),
                  subtitle: Text(device.address),
                  onTap: () {
                    Navigator.of(context).pop(device);
                  },
                ))
            .toList(),
      ),
    );
  }
}

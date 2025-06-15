import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:grass_cutting_robot/login_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    // String grassCutterStatus = "";
    return MaterialApp(
      home: BluetoothControlScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class BluetoothControlScreen extends StatefulWidget {
  @override
  _BluetoothControlScreenState createState() => _BluetoothControlScreenState();
}

class _BluetoothControlScreenState extends State<BluetoothControlScreen> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  String selectedDirection = '';
  FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection? connection;
  bool isConnecting = false;
  bool isConnected = false;
  String connectionText = "Disconnected";

  // double _currentTemperature = 0;
  // double _currentHumidity = 0;
  double _currentDistancce = 0;
  bool isSwitched = false;

  StreamController<List<BluetoothDevice>> _devicesStreamController =
      StreamController<List<BluetoothDevice>>.broadcast();

  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice? _selectedDevice;

  // Other variables and methods...

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  void dispose() {
    _devicesStreamController.close();
    super.dispose();
  }

  void requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    bool allGranted = statuses.values.every((status) => status.isGranted);
    if (allGranted) {
      getBondedDevices();
      startScan();
    } else {
      setState(() {
        connectionText = "Permissions not granted";
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(connectionText),
          duration: Duration(seconds: 3),
        ));
      });
    }
  }

  void startScan() {
    _devicesList.clear();
    _devicesStreamController.add(_devicesList);
    setState(() {
      isConnecting = true;
    });

    bluetooth.startDiscovery().listen((r) {
      if (!_devicesList.any((device) => device.address == r.device.address)) {
        _devicesList.add(r.device);
        _devicesStreamController.add(_devicesList);
      }
    }).onDone(() {
      setState(() {
        isConnecting = false;
      });
    });
  }

  void connectToDevice(BluetoothDevice device) async {
    setState(() {
      connectionText = "Connecting to ${device.name}";
      isConnecting = true;
    });

    try {
      await BluetoothConnection.toAddress(device.address).then((_connection) {
        print('Connected to the device');
        connection = _connection;
        setState(() {
          connectionText = "Connected to ${device.name}";
          isConnected = true;
          isConnecting = false;
          _selectedDevice = device;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(connectionText),
            duration: Duration(seconds: 3),
          ));
        });

        connection!.input!.listen((data) {
          String receivedData = String.fromCharCodes(data);
          print('Data incoming: $receivedData');

          if (receivedData.startsWith("dictance: ")) {
            List<String> parts = receivedData.split(",");
            setState(() {
              // _currentTemperature = double.parse(parts[0].substring(2)); // Extracting temperature value and converting to double
              _currentDistancce = double.parse(parts[0].substring(
                  2)); // Extracting distance value and converting to double
              // _currentHumidity = double.parse(parts[1].substring( 2)); // Extracting humidity value and converting to double
            });

            print("the current distance of the robot is: " +
                _currentDistancce.toString());
          }
        }).onDone(() {
          print('Disconnected by remote request');
          setState(() {
            connectionText = "Disconnected";
            isConnected = false;
            _selectedDevice = null;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(connectionText),
              duration: Duration(seconds: 3),
            ));
          });
        });
      });
    } catch (e) {
      print('Cannot connect, exception occurred');
      print(e);
      setState(() {
        connectionText = "Connection error: $e";
        isConnected = false;
        _selectedDevice = null;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("connection error"),
          duration: Duration(seconds: 3),
        ));
      });
    }
  }

  void disconnectFromDevice() async {
    await connection?.close();
    setState(() {
      connectionText = "Disconnected";
      isConnected = false;
      _selectedDevice = null;
    });
  }

//this function sends string data as command
  void sendCommand(String command) async {
    if (connection != null && connection!.isConnected) {
      connection!.output.add(Uint8List.fromList(command.codeUnits));
      await connection!.output.allSent;
    }
  }

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

// this function send int data as command
  // void sendCommand(int command) async {
  //   if (connection != null && connection!.isConnected) {
  //     connection!.output.add(Uint8List.fromList([command]));
  //     await connection!.output.allSent;
  //   }
  // }

// Show About Dialog
  void showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Available Bluetooth Devices'),
          content: Container(
            width: double.maxFinite,
            child: StreamBuilder<List<BluetoothDevice>>(
              stream: _devicesStreamController.stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No devices found');
                } else {
                  List<BluetoothDevice> devicesList = snapshot.data!;
                  return ListView(
                    shrinkWrap: true,
                    children: [
                      if (isConnected && _selectedDevice != null) ...[
                        ListTile(
                          title:
                              Text(_selectedDevice!.name ?? "Unknown Device"),
                          subtitle: Text(_selectedDevice!.address),
                          trailing: TextButton(
                            child: Text("Disconnect"),
                            onPressed: () {
                              disconnectFromDevice();
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                        Divider(),
                      ],
                      ...devicesList.map((device) {
                        return ListTile(
                          title: Text(device.name ?? "Unknown Device"),
                          subtitle: Text(device.address),
                          trailing: TextButton(
                            child: Text(isConnected && _selectedDevice == device
                                ? "Disconnect"
                                : "Connect"),
                            onPressed: () {
                              if (isConnected && _selectedDevice == device) {
                                disconnectFromDevice();
                              } else {
                                connectToDevice(device);
                              }
                              Navigator.of(context).pop();
                            },
                          ),
                        );
                      }).toList(),
                    ],
                  );
                }
              },
            ),
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Refresh'),
              onPressed: () {
                startScan();
                getBondedDevices();
                Navigator.of(context).pop();
                showAboutDialog(context);
              },
            ),
          ],
        );
      },
    );
  }

  void getBondedDevices() async {
    List<BluetoothDevice> bondedDevices = await bluetooth.getBondedDevices();
    _devicesList = bondedDevices;
    _devicesStreamController.add(_devicesList);
  }

  // Update selected direction
  void updateColor(String direction) {
    setState(() {
      selectedDirection = direction;
    });
  }

  // Reset selected direction
  void resetColor() {
    setState(() {
      selectedDirection = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    String grassCutterStatus = "";
    return Scaffold(
      key: _scaffoldMessengerKey,
      appBar: AppBar(
        title: Text("Grass Cutting Robot"),
        actions: [
          IconButton(
            icon: Icon(Icons.bluetooth, color: Colors.black),
            onPressed: () => showAboutDialog(context),
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Text(
            //   isConnected ? "Bluetooth Connected" : "Bluetooth Disconnected",
            //   style: TextStyle(
            //       fontWeight: FontWeight.bold,
            //       fontSize: 20,
            //       color: isConnected ? Colors.green : Colors.red),
            // ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Column(
                //   children: [
                //     SleekCircularSlider(
                //       min: 0,
                //       max: 100,
                //       initialValue: _currentTemperature,
                //       appearance: CircularSliderAppearance(
                //         infoProperties: InfoProperties(
                //           modifier: (double value) {
                //             final roundedValue = value.ceil().toInt().toString();
                //             return '$roundedValue°C';
                //           },
                //         ),
                //         customWidths: CustomSliderWidths(
                //           progressBarWidth: 10,
                //           trackWidth: 10,
                //           handlerSize: 8,
                //         ),
                //         customColors: CustomSliderColors(
                //           trackColor: Colors.grey,
                //           progressBarColors: [Colors.red, Colors.orange],
                //           dotColor: Colors.red,
                //         ),
                //       ),
                //       onChange: (double value) {
                //         setState(() {
                //           _currentTemperature = value;
                //         });
                //       },
                //     ),
                //     SizedBox(height: 10),
                //     Text(
                //       'Temperature Sensor',
                //       style: TextStyle(
                //         fontSize: 20,
                //       ),
                //     ),
                //   ],
                // ),
                SizedBox(width: 20),
                Column(
                  children: [
                    SleekCircularSlider(
                      min: 0,
                      max: 100,
                      initialValue: _currentDistancce,
                      appearance: CircularSliderAppearance(
                        infoProperties: InfoProperties(
                            // modifier: (double value) {
                            //   final roundedValue =
                            //       value.ceil().toInt().toString();
                            //   return '$roundedValue%';
                            // },
                            ),
                        customWidths: CustomSliderWidths(
                          progressBarWidth: 10,
                          trackWidth: 10,
                          handlerSize: 8,
                        ),
                        customColors: CustomSliderColors(
                          trackColor: Colors.grey,
                          progressBarColors: [
                            Colors.blue,
                            Colors.lightBlueAccent
                          ],
                          dotColor: Colors.blue,
                        ),
                      ),
                      onChange: (double value) {
                        setState(() {
                          _currentDistancce = value;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Humidity Sensor',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 30),
            SizedBox(height: 20),
            Column(
              children: [
                Column(
                  children: [
                    Text("Forward"),
                    GestureDetector(
                      onTapDown: (_) {
                        sendCommand('F');
                        print("moving forward");
                        updateColor('forward');
                      },
                      onTapUp: (_) {
                        sendCommand('S');
                        print("stop moving forward");
                      },
                      onSecondaryTap: () => updateColor('forward'),
                      onTapCancel: resetColor,
                      child: Stack(
                        children: [
                          Container(
                            width: 100, // Adjust circle diameter as needed
                            height: 100, // Adjust circle diameter as needed
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.withOpacity(
                                  0.3), // Adjust circle color and opacity as needed
                            ),
                          ),
                          Icon(
                            Icons.arrow_upward,
                            size: 100,
                            color: Colors.cyan,
                          ),
                          // IconButton(
                          //   icon: Icon(Icons.arrow_upward, color: Colors.cyan),
                          //   iconSize: 80,
                          //   onPressed: () {},
                          // ),
                        ],
                      ),
                      // child: Container(
                      //   width: 60, // Set your desired width
                      //   height: 60, // Set your desired height
                      //   child: Image.asset(
                      //     'assets/up-arrow.jpg',
                      //     fit: BoxFit.cover,
                      //   ),
                      // ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text("Left"),
                        GestureDetector(
                          onTapDown: (_) {
                            sendCommand('L');
                            print("moving left");
                            updateColor('left');
                          },
                          onTapUp: (_) {
                            sendCommand('S');
                            print(" stop moving left");
                          },
                          onSecondaryTap: () => updateColor('left'),
                          onTapCancel: resetColor,
                          child: Stack(
                            children: [
                              Container(
                                width: 100, // Adjust circle diameter as needed
                                height: 100, // Adjust circle diameter as needed
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey.withOpacity(
                                      0.3), // Adjust circle color and opacity as needed
                                ),
                              ),
                              Icon(
                                Icons.arrow_back,
                                size: 100,
                                color: Colors.cyan,
                              ),
                            ],
                          ),
                          // child: Container(
                          //   width: 60, // Set your desired width
                          //   height: 60, // Set your desired height
                          //   child: Image.asset(
                          //     'assets/left-arrow.jpg',
                          //     fit: BoxFit.cover,
                          //   ),
                          // ),
                        ),
                      ],
                    ),
                    SizedBox(width: 60),
                    Column(
                      children: [
                        Text("Right"),
                        GestureDetector(
                          onTapDown: (_) {
                            sendCommand('R');
                            print("moving Right");
                            updateColor('right');
                          },
                          onTapUp: (_) {
                            sendCommand('S');
                            print("stop moving right");
                          },
                          onSecondaryTap: () => updateColor('right'),
                          onTapCancel: resetColor,
                          child: Stack(
                            children: [
                              Container(
                                width: 100, // Adjust circle diameter as needed
                                height: 100, // Adjust circle diameter as needed
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey.withOpacity(
                                      0.3), // Adjust circle color and opacity as needed
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward,
                                size: 100,
                                color: Colors.cyan,
                              ),
                            ],
                          ),
                          // child: Container(
                          //   width: 60, // Set your desired width
                          //   height: 60, // Set your desired height
                          //   child: Image.asset(
                          //     'assets/right-arrow.jpg',
                          //     fit: BoxFit.cover,
                          //   ),
                          // ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text("Backward"),
                    GestureDetector(
                      onTapDown: (_) {
                        sendCommand('B');
                        print("moving backward");
                        updateColor('backward');
                      },
                      onTapUp: (_) {
                        sendCommand('S');
                        print("stopped moving backward");
                      },
                      onSecondaryTap: () => updateColor('backward'),
                      onTapCancel: resetColor,
                      child: Stack(
                        children: [
                          Container(
                            width: 100, // Adjust circle diameter as needed
                            height: 100, // Adjust circle diameter as needed
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.withOpacity(
                                  0.3), // Adjust circle color and opacity as needed
                            ),
                          ),
                          Icon(
                            Icons.arrow_downward,
                            size: 100,
                            color: Colors.cyan,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    Switch(
                      value: isSwitched,
                      onChanged: (value) {
                        setState(() {
                          isSwitched = value;
                          if (isSwitched) {
                            sendCommand('x');
                            setState(() {
                              grassCutterStatus = "grass cutter is on";
                            });
                            print("grass cutter is off");
                            // grassCutterStatus = "grass cutter is off";
                          } else {
                            sendCommand('X');
                            setState(() {
                              grassCutterStatus = "grass cutter is off";
                            });
                            print('grass cutter is on');
                          }
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    // Text(
                    //   'Robot Data',
                    //   style: TextStyle(
                    //     color: Colors.black,
                    //     fontSize: 15,
                    //   ),
                    // ),
                    SizedBox(height: 10),
                    // Text(
                    //   grassCutterStatus,
                    //   style: TextStyle(
                    //     color: Colors.purple,
                    //     fontSize: 24,
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
            // Text("Temperature: $_currentTemperature"),
            // Text("Humidity: $_currentHumidity"),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:bbt_new/models/router_model.dart';
import 'package:bbt_new/view/home_page.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../constants.dart';
import '../../controllers/apis.dart';
import '../../controllers/permission.dart';
import '../../widgets/custom/custom_appbar.dart';
import '../../widgets/custom/toast.dart';

class FanFanControl extends StatefulWidget {
  final RouterDetails routerDetails;

  FanFanControl({
    required this.routerDetails,
    super.key,
  });

  @override
  State<FanFanControl> createState() => _FanSwitchControlState();
}

class _FanSwitchControlState extends State<FanFanControl> {
  late String selectedControl = "OFF";
  late Timer _timer;
  final Duration _timerDuration = const Duration(seconds: 30);
  late List<String> switchTypes;
  List<String> controls = [
    "OFF",
    "HIGH",
    "LOW",
    "MEDIUM",
  ];

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? connectivitySubscription;

  @override
  void initState() {
    super.initState();
    switchTypes = widget.routerDetails.switchTypes;
    updateSwitch();
    _initNetworkInfo();
    connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      _updateConnectionStatus(results);
    });
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer(_timerDuration, _navigateToNextPage);
  }

  void updateSwitch() async {
    print("${widget.routerDetails.iPAddress}/Switchstatus");
    String res = await ApiConnect.hitApiGet(
        "${widget.routerDetails.iPAddress}/Switchstatus");
    print(res);
    setState(() {
      if (res.contains("OK5 OPEN")) {
        print("low");
        selectedControl = "LOW";
      } else if (res.contains("OK6 OPEN")) {
        print("medium");
        selectedControl = "MEDIUM";
      } else if (res.contains("OK7 OPEN")) {
        print("high");
        selectedControl = "HIGH";
      } else {
        selectedControl = "OFF";
      }
    });
  }

  @override
  void dispose() {
    connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> results) async {
    for (var result in results) {
      _initNetworkInfo();
    }
  }

  String _connectionStatus = 'Unknown';
  final NetworkInfo _networkInfo = NetworkInfo();
  Future<void> _initNetworkInfo() async {
    String? wifiName,
        wifiBSSID,
        wifiIPv4,
        wifiIPv6,
        wifiGatewayIP,
        wifiBroadcast,
        wifiSubmask;

    try {
      await requestPermission(Permission.nearbyWifiDevices);
      // await requestPermission(Permission.locationWhenInUse);
    } catch (e) {
      print(e.toString());
    }

    try {
      if (!kIsWeb && Platform.isIOS) {
        var status = await _networkInfo.getLocationServiceAuthorization();
        if (status == LocationAuthorizationStatus.notDetermined) {
          status = await _networkInfo.requestLocationServiceAuthorization();
        }
        if (status == LocationAuthorizationStatus.authorizedAlways ||
            status == LocationAuthorizationStatus.authorizedWhenInUse) {
          wifiName = await _networkInfo.getWifiName();
        } else {
          wifiName = await _networkInfo.getWifiName();
        }
      } else {
        wifiName = await _networkInfo.getWifiName();
      }
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi Name', error: e);
      wifiName = 'Failed to get Wifi Name';
    }

    try {
      if (!kIsWeb && Platform.isIOS) {
        // ignore: deprecated_member_use
        var status = await _networkInfo.getLocationServiceAuthorization();
        if (status == LocationAuthorizationStatus.notDetermined) {
          // ignore: deprecated_member_use
          status = await _networkInfo.requestLocationServiceAuthorization();
        }
        if (status == LocationAuthorizationStatus.authorizedAlways ||
            status == LocationAuthorizationStatus.authorizedWhenInUse) {
          wifiBSSID = await _networkInfo.getWifiBSSID();
        } else {
          wifiBSSID = await _networkInfo.getWifiBSSID();
        }
      } else {
        wifiBSSID = await _networkInfo.getWifiBSSID();
      }
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi BSSID', error: e);
      wifiBSSID = 'Failed to get Wifi BSSID';
    }

    try {
      wifiIPv4 = await _networkInfo.getWifiIP();
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi IPv4', error: e);
      wifiIPv4 = 'Failed to get Wifi IPv4';
    }

    try {
      if (!Platform.isWindows) {
        wifiIPv6 = await _networkInfo.getWifiIPv6();
      }
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi IPv6', error: e);
      wifiIPv6 = 'Failed to get Wifi IPv6';
    }

    try {
      if (!Platform.isWindows) {
        wifiSubmask = await _networkInfo.getWifiSubmask();
      }
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi submask address', error: e);
      wifiSubmask = 'Failed to get Wifi submask address';
    }

    try {
      if (!Platform.isWindows) {
        wifiBroadcast = await _networkInfo.getWifiBroadcast();
      }
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi broadcast', error: e);
      wifiBroadcast = 'Failed to get Wifi broadcast';
    }

    try {
      if (!Platform.isWindows) {
        wifiGatewayIP = await _networkInfo.getWifiGatewayIP();
      }
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi gateway address', error: e);
      wifiGatewayIP = 'Failed to get Wifi gateway address';
    }

    setState(() {
      _connectionStatus = wifiName!.toString();
      // 'Wifi BSSID: $wifiBSSID\n'
      //     'Wifi IPv4: $wifiIPv4\n'
      //     'Wifi IPv6: $wifiIPv6\n'
      //     'Wifi Broadcast: $wifiBroadcast\n'
      //     'Wifi Gateway: $wifiGatewayIP\n'
      //     'Wifi Submask: $wifiSubmask\n';
    });
  }

  void _navigateToNextPage() {
    if (mounted) {
      Navigator.pushAndRemoveUntil<dynamic>(
        context,
        MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => const HomePage(),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: appBarColour,
        onPressed: updateSwitch,
        child: const Icon(Icons.refresh_rounded),
      ),
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: CustomAppBar(heading: "Fan Control"),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade400,
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(5, 5),
                    ),
                  ],
                  color: appBarColour,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${widget.routerDetails.switchName}_${widget.routerDetails.selectedFan}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      Icons.wind_power_outlined,
                      size: width * 0.1,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 250,
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.teal.shade600,
                    Colors.blue.shade400,
                    Colors.red.shade400
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    spreadRadius: 2,
                    blurRadius: 6,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: CupertinoSlidingSegmentedControl<String>(
                groupValue: selectedControl,
                backgroundColor: Colors.transparent,
                thumbColor: const Color(0xff2cd2ec),
                children: {
                  for (var control in controls)
                    control: Text(
                      control,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                },
                onValueChanged: (value) async {
                  if (!_connectionStatus
                      .contains(widget.routerDetails.routerName)) {
                    showToast(
                      context,
                      "Please Connect WIFI to ${widget.routerDetails.routerName} to proceed",
                    );
                    setState(() {});
                    return;
                  }
                  setState(() {
                    selectedControl = value!;
                  });
                  print(value);
                  await sendFanCommand(value!);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> sendFanCommand(String command) async {
    try {
      print("${widget.routerDetails.iPAddress}/getSwitchcmd $command ");
      final response = await ApiConnect.hitApiPost(
        "${widget.routerDetails.iPAddress}/getSwitchcmd",
        {
          "Lock_id": widget.routerDetails.switchID,
          "lock_passkey": widget.routerDetails.switchPasskey,
          "lock_cmd": command,
        },
      );
      print(response.runtimeType);
      print(response);
      print(command);
      print("${widget.routerDetails.iPAddress}/getSwitchcmd" "$command ");
      if (response.toLowerCase() == "ok") {
        showToast(context, "Fan '$command' executed successfully");
      } else {
        showToast(context, "Failed to execute. Try again.");
      }
    } on DioException catch (e) {
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("An unexpected error occurred: ${e.toString()}")),
      );
    }
  }
}

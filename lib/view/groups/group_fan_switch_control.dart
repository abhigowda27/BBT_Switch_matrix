import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:bbt_new/view/home_page.dart';
import 'package:bbt_new/widgets/group/group_fan_switch_card.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../constants.dart';
import '../../controllers/apis.dart';
import '../../controllers/permission.dart';
import '../../controllers/storage.dart';
import '../../models/router_model.dart';
import '../../widgets/custom/custom_appbar.dart';

class GroupFanSwitchControl extends StatefulWidget {
  final String groupName;
  final String selectedRouter;
  final List<RouterDetails> selectedSwitches;
  const GroupFanSwitchControl({
    required this.groupName,
    required this.selectedRouter,
    required this.selectedSwitches,
    super.key,
  });

  @override
  State<GroupFanSwitchControl> createState() => _GroupFanSwitchControlState();
}

class _GroupFanSwitchControlState extends State<GroupFanSwitchControl> {
  final StorageController _storageController = StorageController();
  late Timer _timer;
  late String selectedControl = "OFF";
  final Duration _timerDuration = const Duration(seconds: 30);
  List<String> controls = [
    "OFF",
    "HIGH",
  ];
  late bool isSwitchOn = false;
  Future<List<RouterDetails>> fetchRouters() async {
    return widget.selectedSwitches;
  }

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _loadSwitchState();
    _initNetworkInfo();
    connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      _updateConnectionStatus(results);
    });
  }

  @override
  void dispose() {
    connectivitySubscription?.cancel();
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer(_timerDuration, _navigateToNextPage);
  }

  Future<void> _loadSwitchState() async {
    bool state = await _storageController.loadGroupSwitchState();
    setState(() {
      isSwitchOn = state;
    });
  }

  Future<void> _saveGroupSwitchState(bool value) async {
    setState(() {
      isSwitchOn = value;
    });
    await _storageController.saveGroupSwitchState(value);
  }

  void _resetTimer() {
    _startTimer();
    _timer.cancel();
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> results) async {
    for (var result in results) {
      Navigator.pop(context);
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

    return GestureDetector(
      onTap: _resetTimer,
      child: Scaffold(
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: CustomAppBar(heading: "Fan Control"),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
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
                      widget.groupName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.wind_power_outlined,
                      size: width * 0.1,
                      color: Colors.white,
                    ),
                    FutureBuilder<List<RouterDetails>>(
                      future: fetchRouters(),
                      builder: (context, routerSnapshot) {
                        if (routerSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator(
                              color: backGroundColourDark);
                        }
                        if (routerSnapshot.hasError) {
                          return const Text("ERROR");
                        }
                        final List<RouterDetails> routers =
                            routerSnapshot.data ?? [];
                        return Switch(
                          onChanged: (value) async {
                            await _saveGroupSwitchState(value);
                            for (var switchDetails in routers) {
                              var totalSwitches =
                                  widget.selectedSwitches.length;
                              try {
                                for (int i = 1; i <= totalSwitches; i++) {
                                  final response = await ApiConnect.hitApiPost(
                                    "${switchDetails.iPAddress}/getSwitchcmd",
                                    {
                                      "Lock_id": switchDetails.switchID,
                                      "lock_passkey":
                                          switchDetails.switchPasskey,
                                      "lock_cmd": value ? "HIGH" : "OFF",
                                    },
                                  );
                                  // print(command);
                                  print(response);
                                  print(
                                      "${switchDetails.iPAddress}/getSwitchcmd");
                                }
                              } catch (e) {
                                print(
                                    'API call to ${switchDetails.iPAddress} timed out.');
                              }
                            }
                            setState(() {
                              isSwitchOn = value;
                            });
                          },
                          value: isSwitchOn,
                          activeColor: greenButtonColour,
                          activeTrackColor: greenColour,
                          inactiveThumbColor: redButtonColour,
                          inactiveTrackColor: redColour,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              ...widget.selectedSwitches
                  .where((switchDetail) => switchDetail.selectedFan!.isNotEmpty)
                  .map((switchDetail) {
                return GroupFanSwitchCard(
                  switchDetails: switchDetail,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

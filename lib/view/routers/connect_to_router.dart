import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:bbt_new/view/routers/router_fan_switch_control.dart';
import 'package:bbt_new/view/routers/router_on_off.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:open_settings/open_settings.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../constants.dart';
import '../../controllers/permission.dart';
import '../../models/router_model.dart';
import '../../widgets/custom/custom_appbar.dart';
import '../../widgets/custom/custom_button.dart';
import '../../widgets/custom/toast.dart';

final info = NetworkInfo();

class ConnectToRouterPage extends StatefulWidget {
  final RouterDetails routerDetails;
  const ConnectToRouterPage({super.key, required this.routerDetails});

  @override
  _ConnectToRouterPageState createState() => _ConnectToRouterPageState();
}

class _ConnectToRouterPageState extends State<ConnectToRouterPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  ConnectivityResult _connectionStatusS = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _initNetworkInfo();

    connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      _updateConnectionStatus(results);
    });
  }

  @override
  void dispose() {
    connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> results) async {
    for (var result in results) {
      _initNetworkInfo(); // Process each result as needed
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
        // ignore: deprecated_member_use
        var status = await _networkInfo.getLocationServiceAuthorization();
        if (status == LocationAuthorizationStatus.notDetermined) {
          // ignore: deprecated_member_use
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
      // 'Wifi IPv4: $wifiIPv4\n'
      // 'Wifi IPv6: $wifiIPv6\n'
      // 'Wifi Broadcast: $wifiBroadcast\n'
      // 'Wifi Gateway: $wifiGatewayIP\n'
      // 'Wifi Submask: $wifiSubmask\n';
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final height = screenSize.height;
    final width = screenSize.width;
    return GestureDetector(
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: CustomAppBar(heading: widget.routerDetails.routerName)),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 40,
                    ),
                    CustomButton(
                        text: "Open WIFI Settings",
                        icon: Icons.wifi_find,
                        onPressed: () {
                          OpenSettings.openWIFISetting();
                        }),
                    const SizedBox(
                      height: 30,
                    ),
                    if (widget.routerDetails.switchTypes.isNotEmpty) ...[
                      CustomButton(
                          text: "Connect to ${widget.routerDetails.switchName}",
                          onPressed: () {
                            if (!_connectionStatus
                                .contains(widget.routerDetails.routerName)) {
                              showToast(context,
                                  "Please Connect WIFI to ${widget.routerDetails.routerName} to proceed");
                              return;
                            }
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RouterOnOff(
                                          routerDetails: widget.routerDetails,
                                        )));
                          })
                    ],
                    const SizedBox(
                      height: 15,
                    ),
                    if (widget.routerDetails.selectedFan!.isNotEmpty) ...[
                      CustomButton(
                          text:
                              "Connect to ${widget.routerDetails.selectedFan}",
                          onPressed: () {
                            if (!_connectionStatus
                                .contains(widget.routerDetails.routerName)) {
                              showToast(context,
                                  "Please Connect WIFI to ${widget.routerDetails.routerName} to proceed");
                              return;
                            }
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FanFanControl(
                                          routerDetails: widget.routerDetails,
                                        )));
                          })
                    ],
                    const SizedBox(
                      height: 30,
                    ),
                    Align(
                      alignment: AlignmentDirectional(0, 0),
                      child: Text(
                        'WIFI is connected to Wifi Name',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: width * 0.05),
                      ),
                    ),
                    Align(
                      alignment: const AlignmentDirectional(0, 0),
                      child: Text(
                        _connectionStatus.toString(),
                        style: TextStyle(
                            color: appBarColour,
                            fontWeight: FontWeight.bold,
                            fontSize: width * 0.06),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

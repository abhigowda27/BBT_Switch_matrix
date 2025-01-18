import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:bbt_new/view/contacts/contacts_page.dart';
import 'package:bbt_new/view/groups/group_page.dart';
import 'package:bbt_new/view/qr/generate_qr.dart';
import 'package:bbt_new/view/routers/router_page.dart';
import 'package:bbt_new/view/settings.dart';
import 'package:bbt_new/view/switches/switch_page.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:open_settings/open_settings.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../constants.dart';
import '../../controllers/permission.dart';
import '../controllers/storage.dart';
import '../widgets/qr_pin.dart';
import 'mac/mac_page.dart';

class GridItem {
  final String name;
  final String icon;
  final Color? color;
  final Widget navigateTo;

  GridItem(
      {required this.name,
      required this.icon,
      required this.navigateTo,
      required this.color});
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final StorageController _storageController = StorageController();
  final List<GridItem> lists = [
    GridItem(
        name: 'Users',
        icon: "assets/images/user.png",
        navigateTo: const ContactsPage(),
        color: Colors.lightBlue),
    GridItem(
        name: 'Switches',
        icon: "assets/images/switch.png",
        navigateTo: const SwitchPage(),
        color: Colors.redAccent),
    GridItem(
        name: 'Routers',
        icon: "assets/images/wifi-router.png",
        navigateTo: const RouterPage(),
        color: Colors.deepPurple),
    GridItem(
        name: 'Groups',
        icon: "assets/images/group_icon.png",
        navigateTo: const GroupingPage(),
        color: Colors.green),
    GridItem(
        name: 'MACs Page',
        icon: "assets/images/MAC.png",
        navigateTo: const MacsPage(),
        color: null),
    GridItem(
        name: 'Generate QR',
        icon: "assets/images/qr-code.png",
        navigateTo: const SettingsPage(),
        color: Colors.orange),
    GridItem(
        name: 'Settings',
        icon: "assets/images/settings.png",
        navigateTo: const SettingsPage(),
        color: Colors.orange),
  ];
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? connectivitySubscription;

  @override
  void initState() {
    requestPermission(Permission.camera);
    requestPermission(Permission.contacts);
    requestPermission(Permission.location);
    _initNetworkInfo();
    connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      _updateConnectionStatus(results);
    });
    super.initState();
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

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'BelBird Technologies',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: width * 0.06,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'BBT Switch Matrix',
                  style: TextStyle(
                    color: blackColour,
                    fontSize: width * 0.04,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Image.asset(
                  "assets/images/BBT_Logo_2.png",
                  width: height * 0.1,
                  height: height * 0.1,
                ),
              ),
            ],
            backgroundColor: Colors.transparent,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background design or image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.teal.shade200.withOpacity(0.8),
                  Colors.teal.shade400
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 0,
            child: Opacity(
              opacity: 0.2,
              child: Image.asset(
                "assets/images/BBT_Logo_2.png",
                height: height * 0.4,
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            right: 0,
            child: Opacity(
              opacity: 0.2,
              child: Image.asset(
                "assets/images/BBT_Logo_2.png",
                height: height * 0.4,
              ),
            ),
          ),

          // Main content
          SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  alignment: const AlignmentDirectional(0, 0),
                  child: Text(
                    'WIFI is connected to Wifi Name:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: width * 0.05),
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
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: lists.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                    ),
                    itemBuilder: (context, index) {
                      final item = lists[index];
                      return GestureDetector(
                        onTap: () async {
                          if (item.name == 'Generate QR') {
                            final qrPin = await _storageController.getQrPin();
                            PinDialog pinDialog = PinDialog(context);
                            pinDialog.showPinDialog(
                              isFirstTime: qrPin == null,
                              onSuccess: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const GenerateQRPage(),
                                  ),
                                );
                              },
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => item.navigateTo!,
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(1),
                                blurRadius: 5,
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(item.icon,
                                  height: height * .045, color: item.color),
                              const SizedBox(height: 10),
                              Text(
                                item.name,
                                style: TextStyle(
                                  fontSize: width * 0.035,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Stack(
        children: [
          Align(
            alignment: Alignment.bottomRight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    OpenSettings.openWIFISetting();
                  },
                  backgroundColor: backGroundColourDark,
                  child: const Icon(Icons.wifi_find),
                ),
                const SizedBox(height: 15),
                FloatingActionButton(
                  onPressed: () {
                    OpenSettings.openLocationSourceSetting();
                  },
                  backgroundColor: backGroundColourDark,
                  child: const Icon(Icons.location_on_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

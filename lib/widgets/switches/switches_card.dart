import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:bbt_new/view/home_page.dart';
import 'package:bbt_new/view/routers/add_router.dart';
import 'package:bbt_new/widgets/custom/toast.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../constants.dart';
import '../../controllers/permission.dart';
import '../../controllers/storage.dart';
import '../../models/switch_model.dart';
import '../../view/switches/update_switch.dart';

class SwitchCard extends StatefulWidget {
  final SwitchDetails switchDetails;

  const SwitchCard({required this.switchDetails, super.key});

  @override
  State<SwitchCard> createState() => _SwitchCardState();
}

class _SwitchCardState extends State<SwitchCard> {
  final StorageController _storageController = StorageController();
  bool hide = true;

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
    return Padding(
      padding:
          EdgeInsets.symmetric(vertical: width * 0.02, horizontal: width * 0.1),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade400,
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(5, 5),
            ),
          ],
          color: whiteColour,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Switch ID: ",
                  style: TextStyle(
                    fontSize: width * 0.04,
                    color: blackColour,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Flexible(
                  child: Text(
                    widget.switchDetails.switchId,
                    style: TextStyle(
                      fontSize: width * 0.04,
                      color: blackColour,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  "Switch Name: ",
                  style: TextStyle(
                    fontSize: width * 0.04,
                    color: blackColour,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Flexible(
                  child: Text(
                    widget.switchDetails.switchSSID,
                    style: TextStyle(
                      fontSize: width * 0.04,
                      color: blackColour,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ],
            ),
            if (widget.switchDetails.switchTypes.isNotEmpty) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Selected Switches:",
                    style: TextStyle(
                      fontSize: width * 0.04,
                      color: blackColour,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.switchDetails.switchTypes
                        .asMap()
                        .entries
                        .map((entry) {
                      int index = entry.key;
                      String switchType = entry.value;
                      return Row(
                        children: [
                          Text(
                            '${index + 1}: ',
                            style: TextStyle(
                              fontSize: width * 0.04,
                              color: blackColour,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              switchType,
                              style: TextStyle(
                                fontSize: width * 0.04,
                                color: blackColour,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              )
            ],
            if (widget.switchDetails.selectedFan!.isNotEmpty) ...[
              Row(
                children: [
                  Text(
                    "Selected fan: ",
                    style: TextStyle(
                      fontSize: width * 0.04,
                      color: blackColour,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      widget.switchDetails.selectedFan!,
                      style: TextStyle(
                        fontSize: width * 0.04,
                        color: blackColour,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            Row(
              children: [
                Text(
                  "Switch PassKey : ",
                  style: TextStyle(
                      fontSize: width * 0.04,
                      color: blackColour,
                      fontWeight: FontWeight.w600),
                ),
                Flexible(
                  child: Text(
                    hide
                        ? List.generate(
                            widget.switchDetails.switchPassKey!.length,
                            (index) => "*").join()
                        : widget.switchDetails.switchPassKey!,
                    style: TextStyle(
                        fontSize: width * 0.04,
                        color: blackColour,
                        fontWeight: FontWeight.w300),
                  ),
                )
              ],
            ),
            Row(
              children: [
                Text(
                  "Switch Password: ",
                  style: TextStyle(
                      fontSize: width * 0.04,
                      color: blackColour,
                      fontWeight: FontWeight.w600),
                ),
                Flexible(
                  child: Text(
                    hide
                        ? List.generate(
                            widget.switchDetails.switchPassword.length,
                            (index) => "*").join()
                        : widget.switchDetails.switchPassword,
                    style: TextStyle(
                        fontSize: width * 0.04,
                        color: blackColour,
                        fontWeight: FontWeight.w300),
                  ),
                )
              ],
            ),
            Container(
              decoration: BoxDecoration(
                color: appBarColour,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  IconButton(
                      tooltip: "Delete Switch",
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (cont) {
                              final formKey = GlobalKey<FormState>();
                              TextEditingController pinController =
                                  TextEditingController();

                              return Form(
                                key: formKey,
                                child: AlertDialog(
                                  title: Text(widget.switchDetails.switchSSID),
                                  content: const Text(
                                      'Enter the switch pin to proceed'),
                                  actions: [
                                    Column(
                                      children: [
                                        TextFormField(
                                          maxLength: 4,
                                          controller: pinController,
                                          validator: (value) {
                                            if (value!.length <= 3) {
                                              return "Switch Pin cannot be less than 4 letters";
                                            }
                                            if (pinController.text !=
                                                widget
                                                    .switchDetails.privatePin) {
                                              return "Pin does not match";
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              // borderSide: BorderSide(width: 40),
                                            ),
                                            labelText: "Enter Old Pin",
                                            labelStyle:
                                                const TextStyle(fontSize: 15),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            OutlinedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text('CANCEL'),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            OutlinedButton(
                                              onPressed: () {
                                                if (formKey.currentState!
                                                    .validate()) {
                                                  if (pinController.text ==
                                                      widget.switchDetails
                                                          .privatePin) {
                                                    _storageController
                                                        .deleteOneSwitch(widget
                                                            .switchDetails);
                                                    Navigator
                                                        .pushAndRemoveUntil<
                                                            dynamic>(
                                                      context,
                                                      MaterialPageRoute<
                                                          dynamic>(
                                                        builder: (BuildContext
                                                                context) =>
                                                            const HomePage(),
                                                      ),
                                                      (route) => false,
                                                    );
                                                  } else {
                                                    Navigator.pop(context);
                                                    showToast(context,
                                                        "Pin do not match");
                                                  }
                                                }
                                              },
                                              child: const Text('Confirm'),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            });
                      },
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                      )),
                  IconButton(
                      tooltip: "password",
                      onPressed: () {
                        setState(() {
                          hide = !hide;
                        });
                      },
                      icon: hide
                          ? const Icon(Icons.remove_red_eye)
                          : const Icon(
                              CupertinoIcons.eye_slash_fill,
                            )),
                  IconButton(
                      tooltip: "Refresh Switch",
                      onPressed: () {
                        String localConnectStatus = _connectionStatus;
                        localConnectStatus = localConnectStatus.substring(
                            1, localConnectStatus.length - 1);
                        if (localConnectStatus !=
                            widget.switchDetails.switchSSID) {
                          showToast(context,
                              "You should be connected to ${widget.switchDetails.switchSSID} to refresh the switch");
                          return;
                        }
                        showDialog(
                            context: context,
                            builder: (cont) {
                              final formKey = GlobalKey<FormState>();
                              TextEditingController pinController0 =
                                  TextEditingController();
                              return Form(
                                key: formKey,
                                child: AlertDialog(
                                  title: const Text('BBT Switch'),
                                  content: const Text(
                                      'Enter the switch pin to proceed'),
                                  actions: [
                                    Column(
                                      children: [
                                        TextFormField(
                                          maxLength: 4,
                                          controller: pinController0,
                                          validator: (value) {
                                            if (value!.length <= 3) {
                                              return "Switch Pin cannot be less than 4 letters";
                                            }
                                            if (pinController0.text !=
                                                widget
                                                    .switchDetails.privatePin) {
                                              return "Pin does not match";
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            labelText: "Enter Old Pin",
                                            labelStyle:
                                                const TextStyle(fontSize: 15),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            OutlinedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text('CANCEL'),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            OutlinedButton(
                                              onPressed: () {
                                                if (formKey.currentState!
                                                    .validate()) {
                                                  if (pinController0.text ==
                                                      widget.switchDetails
                                                          .privatePin) {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                UpdatePage(
                                                                    switchDetails:
                                                                        widget
                                                                            .switchDetails)));
                                                  } else {
                                                    Navigator.pop(context);
                                                    showToast(context,
                                                        "Pin do not match");
                                                  }
                                                }
                                              },
                                              child: const Text('Confirm'),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            });
                      },
                      icon: const Icon(Icons.edit)),
                  IconButton(
                      tooltip: "Add Router",
                      onPressed: () async {
                        String localConnectStatus = _connectionStatus;
                        localConnectStatus = localConnectStatus.substring(
                            1, localConnectStatus.length - 1);
                        if (localConnectStatus !=
                            widget.switchDetails.switchSSID) {
                          showToast(context,
                              "You should be connected to ${widget.switchDetails.switchSSID} to add the Router");
                          return;
                        }
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddNewRouterPage(
                                      switchDetails: widget.switchDetails,
                                      isFromSwitch: true,
                                    )));
                      },
                      icon: Transform.rotate(
                        angle: -90 * 3.1415926535897932 / 180,
                        child: SvgPicture.asset(
                          color: blackColour,
                          "assets/images/wifi.svg",
                        ),
                      ))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

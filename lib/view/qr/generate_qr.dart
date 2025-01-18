import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:bbt_new/view/qr/qr.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../constants.dart';
import '../../controllers/permission.dart';
import '../../controllers/storage.dart';
import '../../models/contacts.dart';
import '../../models/group_model.dart';
import '../../models/router_model.dart';
import '../../models/switch_model.dart';
import '../../widgets/custom/custom_appbar.dart';
import '../../widgets/custom/toast.dart';

enum GenerateType { Switches, Routers, Groups }

class GenerateQRPage extends StatefulWidget {
  const GenerateQRPage({super.key});

  @override
  State<GenerateQRPage> createState() => _GenerateQRPageState();
}

class _GenerateQRPageState extends State<GenerateQRPage> {
  final StorageController _storageController = StorageController();
  final ConnectivityResult _connectionStatusS = ConnectivityResult.none;
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
        var status = await _networkInfo.getLocationServiceAuthorization();
        if (status == LocationAuthorizationStatus.notDetermined) {
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
    });
  }

  List<ContactsModel> contacts = [];
  List<SwitchDetails> switches = [];
  List<RouterDetails> routers = [];
  List<GroupDetails> groups = [];

  getData() async {
    contacts = await _storageController.readContacts();
    switches = await _storageController.readSwitches();
    routers = await _storageController.readRouters();
    groups = await _storageController.readAllGroups();
    return (contacts, switches, routers, groups);
  }

  GenerateType generateType = GenerateType.Switches;

  SwitchDetails switchh = SwitchDetails(
    switchId: "default",
    switchSSID: "def",
    privatePin: "1234",
    // selectedAppliance: "default",
    switchPassword: "default",
    iPAddress: "0.0.0.0",
    switchTypes: [],
    selectedFan: "",
  );

  RouterDetails router = RouterDetails(
    switchID: "default",
    routerName: "default",
    routerPassword: "default",
    switchPasskey: "default",
    switchName: "default",
    switchTypes: [],
    iPAddress: '',
    selectedFan: '',
  );

  GroupDetails group = GroupDetails(
    groupName: 'default',
    selectedRouter: 'default',
    selectedSwitches: [],
    routerPassword: '',
  );

  ContactsModel contact = ContactsModel(
    accessType: "default",
    endDateTime: DateTime.now(),
    startDateTime: DateTime.now(),
    name: "default",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: CustomAppBar(heading: "Generate QR"),
      ),
      body: Center(
        child: FutureBuilder(
          future: getData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(color: backGroundColourDark);
            }
            print((snapshot.data.runtimeType));
            var x = snapshot.data as (
              List<ContactsModel>,
              List<SwitchDetails>,
              List<RouterDetails>,
              List<GroupDetails>,
            );
            contacts = x.$1;
            switches = x.$2;
            routers = x.$3;
            groups = x.$4;
            return Column(
              children: [
                const SizedBox(height: 30),
                DropdownMenu(
                    initialSelection: generateType,
                    onSelected: (value) async {
                      setState(() {
                        print(value);
                        generateType = value!;
                        contact = ContactsModel(
                          accessType: "default",
                          endDateTime: DateTime.now(),
                          startDateTime: DateTime.now(),
                          name: "default",
                        );
                      });
                    },
                    dropdownMenuEntries: const [
                      DropdownMenuEntry(
                          value: GenerateType.Switches, label: "Switches"),
                      DropdownMenuEntry(
                          value: GenerateType.Routers, label: "Routers"),
                      DropdownMenuEntry(
                          value: GenerateType.Groups, label: "Groups"),
                    ]),
                const SizedBox(height: 10),
                if (generateType == GenerateType.Switches)
                  const Text("Select Switch"),
                if (generateType == GenerateType.Routers)
                  const Text("Select Router"),
                if (generateType == GenerateType.Groups)
                  const Text("Select Group"),
                if (generateType == GenerateType.Switches)
                  DropdownMenu(
                    onSelected: (value) async {
                      switchh = await _storageController.getSwitchBySSID(value);
                    },
                    dropdownMenuEntries: switches
                        .map((e) => DropdownMenuEntry(
                            value: e.switchSSID, label: e.switchSSID))
                        .toList(),
                  ),
                if (generateType == GenerateType.Routers)
                  DropdownMenu(
                    onSelected: (value) async {
                      router = await _storageController.getRouterByName(value);
                    },
                    dropdownMenuEntries: routers
                        .map((e) => DropdownMenuEntry(
                            value: "${e.routerName}_${e.switchName}",
                            label: "${e.routerName}_${e.switchName}"))
                        .toList(),
                  ),
                if (generateType == GenerateType.Groups)
                  DropdownMenu(
                    onSelected: (value) async {
                      group = await _storageController.getGroupByName(value);
                    },
                    dropdownMenuEntries: groups
                        .map((e) => DropdownMenuEntry(
                            value: e.groupName, label: e.groupName))
                        .toList(),
                  ),
                const SizedBox(height: 10),
                const Text("Select Contact"),
                DropdownMenu(
                  onSelected: (value) async {
                    contact = await _storageController.getContactByPhone(value);
                  },
                  dropdownMenuEntries: contacts
                      .map((e) =>
                          DropdownMenuEntry(value: e.name, label: e.name))
                      .toList(),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (generateType == GenerateType.Switches &&
                            switchh.switchId.contains("default")) {
                          showToast(context, "No switch is selected");
                          return;
                        }

                        if (generateType == GenerateType.Routers &&
                            router.switchName.contains("default")) {
                          showToast(context, "No router is selected");
                          return;
                        }
                        if (generateType == GenerateType.Groups &&
                            group.groupName.contains("default")) {
                          showToast(context, "No group is selected");
                          return;
                        }
                        if (contact.accessType.contains("default")) {
                          showToast(context, "No contact is selected");
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QRPage(
                              data: generateType == GenerateType.Switches
                                  ? "${switchh.toSwitchQR()},${contact.toContactsQR()}"
                                  : generateType == GenerateType.Routers
                                      ? "${router.toRouterQR()},${contact.toContactsQR()}"
                                      : "${group.toGroupQR()},${contact.toContactsQR()}",
                              name: generateType == GenerateType.Switches
                                  ? switchh.switchSSID
                                  : generateType == GenerateType.Routers
                                      ? "${router.routerName}_${router.switchName}"
                                      : group.groupName,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        "Generate",
                        style: TextStyle(color: appBarColour),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: appBarColour),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

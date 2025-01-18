import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/contacts.dart';
import '../models/group_model.dart';
import '../models/mac_model.dart';
import '../models/router_model.dart';
import '../models/switch_model.dart';

class StorageController {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  // for Contacts
  void addContacts(ContactsModel contactsModel) async {
    List<ContactsModel> contactList = await readContacts();
    contactList.add(contactsModel);

    List listContentsInJson = contactList.map((e) {
      return e.toJson();
    }).toList();
    storage.write(key: "contacts", value: json.encode(listContentsInJson));
  }

  deleteContacts() async {
    await storage.delete(key: "contacts");
  }

  deleteOneContact(ContactsModel contactsModel) async {
    List<ContactsModel> contactList = await readContacts();
    contactList.removeWhere((element) => element.name == contactsModel.name);
    // for (var element in contactList) {
    //   if(element.name == contactsModel.name){}
    // }
    // contactList.(contactsModel);
    List listContectsInJson = contactList.map((e) {
      return e.toJson();
    }).toList();
    storage.write(key: "contacts", value: json.encode(listContectsInJson));
  }

  getContactByPhone(phone) async {
    List<ContactsModel> switchesList = await readContacts();
    for (var element in switchesList) {
      if (element.name == phone) return element;
    }
    return null;
  }

  Future<List<ContactsModel>> readContacts() async {
    String? contacts = await storage.read(key: "contacts");
    List<ContactsModel> model = [];
    if (contacts == null) {
      List listContectsInJson = model.map((e) {
        return e.toJson();
      }).toList();
      storage.write(key: "contacts", value: json.encode(listContectsInJson));
    } else {
      model = [];
      var jsonContacts = json.decode(contacts);
      for (var element in jsonContacts) {
        model.add(ContactsModel.fromJson(element));
      }
    }
    return model;
  }

  // Switch

  Future<void> updateSwitch(
      String idOfSwitch, SwitchDetails switchDetails) async {
    List<SwitchDetails> switchesList = await readSwitches();
    List<RouterDetails> routersList = await readRouters();

    print("-------------");
    print(
        "Switches before update: ${switchesList.map((e) => e.toJson()).toList()}");
    print(
        "Routers before update: ${routersList.map((e) => e.toJson()).toList()}");

    // Update switch details in the list
    for (var element in switchesList) {
      if (element.switchId == idOfSwitch) {
        element.switchId = switchDetails.switchId;
        element.switchPassword = switchDetails.switchPassword;
        element.switchSSID = switchDetails.switchSSID;
        element.privatePin = switchDetails.privatePin;
        element.switchPassKey = switchDetails.switchPassKey;
        element.selectedFan = switchDetails.selectedFan;
        element.switchTypes = switchDetails.switchTypes;
        break;
      }
    }

    print(
        "Switches after update: ${switchesList.map((e) => e.toJson()).toList()}");

    await deleteSwitches();
    await storage.write(
        key: "switches",
        value: json.encode(switchesList.map((e) => e.toJson()).toList()));

    // Update router details if the router is associated with the switch
    for (var element in routersList) {
      if (element.switchID == idOfSwitch) {
        element.switchID = switchDetails.switchId;
        element.switchName = switchDetails.switchSSID;
        element.switchPasskey = switchDetails.switchPassKey!;
        // Keep the name, password, and ipAddress the same
        element.routerName = element.routerName;
        element.routerPassword = element.routerName;
        element.iPAddress = element.iPAddress;
        break;
      }
    }

    print(
        "Routers after update: ${routersList.map((e) => e.toJson()).toList()}");

    // Update the storage for routers
    await deleteRouters();
    await storage.write(
        key: "routers",
        value: json.encode(routersList.map((e) => e.toJson()).toList()));
  }

  Future<void> updateSwitchIfIdExist(
      String idOfSwitch, String switchName, SwitchDetails switchDetails) async {
    List<SwitchDetails> switchesList = await readSwitches();
    List<RouterDetails> routersList = await readRouters();

    print("-------------");
    print(
        "Switches before update: ${switchesList.map((e) => e.toJson()).toList()}");
    print(
        "Routers before update: ${routersList.map((e) => e.toJson()).toList()}");

    // Update switch details in the list
    for (var element in switchesList) {
      if (element.switchId == idOfSwitch ||
          element.switchSSID == switchDetails.switchSSID) {
        element.switchId = switchDetails.switchId;
        element.switchPassword = switchDetails.switchPassword;
        element.switchSSID = switchDetails.switchSSID;
        element.privatePin = switchDetails.privatePin;
        element.switchPassKey = switchDetails.switchPassKey;
        element.selectedFan = switchDetails.selectedFan;
        element.switchTypes = switchDetails.switchTypes;
        break;
      }
    }

    print(
        "Switches after update: ${switchesList.map((e) => e.toJson()).toList()}");

    await deleteSwitches();
    await storage.write(
        key: "switches",
        value: json.encode(switchesList.map((e) => e.toJson()).toList()));

    // Update router details if the router is associated with the switch
    for (var element in routersList) {
      if (element.switchID == idOfSwitch ||
          element.switchName == switchDetails.switchSSID) {
        element.switchID = switchDetails.switchId;
        element.switchName = switchDetails.switchSSID;
        element.switchPasskey = switchDetails.switchPassKey!;
        // Keep the name, password, and ipAddress the same
        element.routerName = element.routerName;
        element.routerPassword = element.routerName;
        element.iPAddress = element.iPAddress;
        break;
      }
    }

    print(
        "Routers after update: ${routersList.map((e) => e.toJson()).toList()}");

    // Update the storage for routers
    await deleteRouters();
    await storage.write(
        key: "routers",
        value: json.encode(routersList.map((e) => e.toJson()).toList()));
  }

  deleteSwitches() async {
    await storage.delete(key: "switches");
  }

  Future<List<SwitchDetails>> readSwitches() async {
    String? switches = await storage.read(key: "switches");
    List<SwitchDetails> model = [];

    if (switches == null) {
      // Write an empty list to storage if no switches exist
      await storage.write(key: "switches", value: json.encode([]));
    } else {
      try {
        // Decode the JSON string into a List of Maps (i.e., List<Map<String, dynamic>>)
        List<dynamic> jsonContacts = json.decode(switches);
        print(jsonContacts);

        // Iterate over the decoded list and convert each map to SwitchDetails
        for (var element in jsonContacts) {
          if (element is Map<String, dynamic>) {
            model.add(SwitchDetails.fromJson(element));
          }
        }
      } catch (e) {
        // Handle potential decoding errors
        print('Error decoding switches: $e');
      }
    }

    return model;
  }

  getSwitchBySSID(switchName) async {
    List<SwitchDetails> switchesList = await readSwitches();
    for (var element in switchesList) {
      if (element.switchSSID == switchName) return element;
    }
    return null;
  }

  deleteOneSwitch(SwitchDetails switchDetails) async {
    List<SwitchDetails> switchList = await readSwitches();
    switchList.removeWhere(
        (element) => element.switchSSID == switchDetails.switchSSID);
    List listContactsInJson = switchList.map((e) {
      return e.toJson();
    }).toList();
    await deleteSwitches();
    storage.write(key: "switches", value: json.encode(listContactsInJson));
  }

  Future<bool> isswitchNameExists(String switchName, String switchId) async {
    List<SwitchDetails> switchesList = await readSwitches();
    for (var switchDetails in switchesList) {
      if (switchDetails.switchSSID == switchName ||
          switchDetails.switchId == switchId) {
        return true;
      }
    }
    return false;
  }

  void addSwitches(SwitchDetails switchDetails) async {
    List<SwitchDetails> switchesList = await readSwitches();
    switchesList.add(switchDetails);
    List listContectsInJson = switchesList.map((e) {
      return e.toJson();
    }).toList();
    storage.write(key: "switches", value: json.encode(listContectsInJson));
  }

  // ROUTERS
  Future<void> updateRouter(
    RouterDetails routerDetails,
  ) async {
    List<RouterDetails> routersList = await readRouters();
    routersList
        .removeWhere((element) => element.switchID == routerDetails.switchID);
    routersList.add(routerDetails);
    await storage.write(
      key: "routers",
      value: json.encode(routersList.map((e) => e.toJson()).toList()),
    );
  }

  deleteRouters() async {
    await storage.delete(key: "routers");
  }

  getRouterByName(switchName) async {
    List<RouterDetails> routerList = await readRouters();
    for (var element in routerList) {
      if (element.routerName + "_" + element.switchName == switchName)
        return element;
    }
    return null;
  }

  Future<List<RouterDetails>> readRouters() async {
    String? switches = await storage.read(key: "routers");
    List<RouterDetails> _model = [];
    if (switches == null) {
      List listContectsInJson = _model.map((e) {
        return e.toJson();
      }).toList();
      storage.write(key: "routers", value: json.encode(listContectsInJson));
    } else {
      _model = [];
      var jsonContacts = json.decode(switches);
      for (var element in jsonContacts) {
        _model.add(RouterDetails.fromJson(element));
      }
    }
    return _model;
  }

  deleteOneRouter(String switchId) async {
    List<RouterDetails> switchList = await readRouters();

    switchList.removeWhere((element) => element.switchID == switchId);

    List listContectsInJson = switchList.map((e) {
      return e.toJson();
    }).toList();
    storage.write(key: "routers", value: json.encode(listContectsInJson));
  }

  Future<String?> getRouterNameIfSwitchIDExists(String switchID) async {
    List<RouterDetails> routerList = await readRouters();
    for (var switchDetails in routerList) {
      if (switchDetails.switchID == switchID) {
        print("${switchDetails.switchID} SwitchDetails Switch ID");
        print("$switchID SwitchID");
        return switchDetails.routerName;
      }
    }
    return null;
  }

  void addRouters(RouterDetails switchDetails) async {
    List<RouterDetails> switchesList = await readRouters();
    switchesList.add(switchDetails);
    List listContectsInJson = switchesList.map((e) {
      return e.toJson();
    }).toList();
    storage.write(key: "routers", value: json.encode(listContectsInJson));
  }

  //Group
  static const _groupStateKey = 'isGroupSwitchOn';

  Future<bool> loadGroupSwitchState() async {
    String? value = await storage.read(key: _groupStateKey);
    return value != null && value.toLowerCase() == 'true';
  }

  Future<void> saveGroupSwitchState(bool value) async {
    await storage.write(key: _groupStateKey, value: value.toString());
  }

  deleteGroups() async {
    await storage.delete(key: "groups");
  }

  getGroupByName(groupName) async {
    List<GroupDetails> groupList = await readAllGroups();
    for (var element in groupList) {
      if (element.groupName == groupName) return element;
    }
    return null;
  }

  Future<void> saveGroupDetails(GroupDetails groupDetails) async {
    List<GroupDetails> groups = await readAllGroups();
    groups.add(groupDetails);
    List listContectsInJson = groups.map((e) {
      return e.toJson();
    }).toList();
    await storage.write(key: "groups", value: json.encode(listContectsInJson));
  }

  Future<List<GroupDetails>> readAllGroups() async {
    String? groupsJson = await storage.read(key: 'groups');
    if (groupsJson == null) return [];
    List<dynamic> groupsList = jsonDecode(groupsJson);
    return groupsList.map((json) => GroupDetails.fromJson(json)).toList();
  }

  Future<bool> groupExists(String groupName) async {
    // Assuming you have a method to fetch all group details from storage
    List<GroupDetails> allGroups = await readAllGroups();

    // Check if any group has the same name as the provided groupName
    return allGroups.any((group) => group.groupName == groupName);
  }

  Future<void> updateGroupDetails(
      GroupName, RouterName, List<RouterDetails> selectedSwitches) async {
    // Assuming you have a method to fetch all group details from storage
    List<GroupDetails> allGroups = await readAllGroups();
    print("-------------");
    List listContectsInJson = allGroups.map((e) {
      return e.toJson();
    }).toList();
    print(listContectsInJson);
    print(allGroups.length);
    for (var element in allGroups) {
      if (element.groupName == GroupName) {
        element.groupName = GroupName;
        element.selectedRouter = RouterName;
        element.selectedSwitches = selectedSwitches;
        break;
      }
    }
    listContectsInJson = allGroups.map((e) {
      return e.toJson();
    }).toList();
    print(listContectsInJson);
    await deleteGroups();
    storage.write(key: "groups", value: json.encode(listContectsInJson));
  }

  Future<void> deleteOneGroup(GroupDetails groupDetails) async {
    List<GroupDetails> groups = await readAllGroups();
    groups.removeWhere((group) => group.groupName == groupDetails.groupName);
    await storage.write(
      key: 'groups',
      value: jsonEncode(groups.map((group) => group.toJson()).toList()),
    );
  }

  deleteMacs() async {
    await storage.delete(key: "macs");
  }

  Future<List<MacsDetails>> readMacs() async {
    String? switches = await storage.read(key: "macs");
    List<MacsDetails> model = [];
    if (switches == null) {
      List listContectsInJson = model.map((e) {
        return e.toJson();
      }).toList();
      storage.write(key: "macs", value: json.encode(listContectsInJson));
    } else {
      model = [];
      var jsonContacts = json.decode(switches);
      for (var element in jsonContacts) {
        model.add(MacsDetails.fromJson(element));
      }
    }
    return model;
  }

  deleteOneMacs(MacsDetails switchDetails) async {
    List<MacsDetails> switchList = await readMacs();
    switchList.removeWhere((element) =>
        element.id == switchDetails.id &&
        element.switchDetails.switchSSID ==
            switchDetails.switchDetails.switchSSID);
    List listContentsInJson = switchList.map((e) {
      return e.toJson();
    }).toList();
    storage.write(key: "macs", value: json.encode(listContentsInJson));
  }

  updateMacStatus(MacsDetails switchDetails, BuildContext context) async {
    await deleteOneMacs(switchDetails);
    addMacs(switchDetails, context);
  }

  Future<bool> isMacIDExists(
    String macId,
    switchID,
  ) async {
    List<MacsDetails> MacsList = await readMacs();
    for (var details in MacsList) {
      if (details.id == macId && details.switchDetails.switchId == switchID) {
        return true;
      }
    }
    return false;
  }

  void addMacs(MacsDetails macDetails, BuildContext context) async {
    bool exists =
        await isMacIDExists(macDetails.id, macDetails.switchDetails.switchId);
    if (exists) {
      final scaffold = ScaffoldMessenger.of(context);
      scaffold.showSnackBar(
        const SnackBar(
          content: Text("MAC ID already Exist for this switch"),
        ),
      );
      return;
    }
    List<MacsDetails> switchesList = await readMacs();
    switchesList.add(macDetails);

    List listContectsInJson = switchesList.map((e) {
      return e.toJson();
    }).toList();
    storage.write(key: "macs", value: json.encode(listContectsInJson));
  }

  Future<void> saveMacState(MacsDetails mac) async {
    await storage.write(
      key: 'mac_${mac.id}_${mac.switchDetails.switchSSID}',
      value: mac.isPresentInESP.toString(),
    );
  }

  // Retrieve the state of a MAC card
  Future<bool> getMacState(MacsDetails mac) async {
    final state = await storage.read(
        key: 'mac_${mac.id}_${mac.switchDetails.switchSSID}');
    return state == 'true';
  }

  // Delete a MAC card's state
  Future<void> deleteMacState(MacsDetails mac) async {
    await storage.delete(key: 'mac_${mac.id}_${mac.switchDetails.switchSSID}');
  }

  // QR PIN

  Future<String?> getQrPin() async {
    return await storage.read(key: 'qrPinKey');
  }

  Future<void> setQrPin(String pin) async {
    await storage.write(key: 'qrPinKey', value: pin);
  }

  // factory Reset
  deleteEverythingWithRespectToSwitchID(SwitchDetails switchDetails) async {
    print("Deleting all routers");
    List<RouterDetails> routerList = await readRouters();
    routerList
        .removeWhere((element) => element.switchID == switchDetails.switchId);
    List routerlistContectsInJson = routerList.map((e) {
      return e.toJson();
    }).toList();
    storage.write(key: "routers", value: json.encode(routerlistContectsInJson));
    print("Deleted all routers");
    print("Deleting all switches");
    deleteOneSwitch(switchDetails);
    print("Deleted all switches");
  }
}

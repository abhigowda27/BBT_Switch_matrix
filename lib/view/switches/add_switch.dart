import 'package:bbt_new/view/home_page.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../controllers/apis.dart';
import '../../controllers/storage.dart';
import '../../models/switch_model.dart';
import '../../widgets/custom/custom_appbar.dart';
import '../../widgets/custom/custom_button.dart';
import '../../widgets/custom/toast.dart';

class AddNewSwitchesPage extends StatefulWidget {
  const AddNewSwitchesPage({super.key});

  @override
  State<AddNewSwitchesPage> createState() => _AddNewSwitchesPageState();
}

class _AddNewSwitchesPageState extends State<AddNewSwitchesPage> {
  final StorageController _storageController = StorageController();
  final TextEditingController _switchId = TextEditingController();
  final TextEditingController _passKey = TextEditingController();
  final TextEditingController _ssid = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _privatePin = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String? _addFan = "No";
  final TextEditingController _fanNameController = TextEditingController();
  String? _selectedSwitchType;
  String? selectedAppliance;
  String? selectedFan;
  final List<String> _allSwitches = [
    'Switch 1',
    'Switch 2',
    'Switch 3',
    'Switch 4',
  ];

  // final List<String> appliances = [
  //   'Ceiling Fan',
  //   'Table Fan',
  //   'Light Bulb',
  //   'Air Conditioner',
  //   'Refrigerator',
  //   'Washing Machine',
  //   'Microwave Oven',
  //   'Television',
  //   'Water Heater',
  //   'Coffee Maker',
  // ];

  List<String> _availableSwitchTypes = [];
  bool loading = false;
  List<Map<String, TextEditingController>> selectedSwitches = [];

  @override
  void initState() {
    super.initState();
    _availableSwitchTypes = List.from(_allSwitches);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final height = screenSize.height;
    final width = screenSize.width;

    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: CustomAppBar(heading: "Add Switch"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: _switchId,
                    validator: (value) {
                      if (value!.isEmpty) return "Switch ID cannot be empty";
                      return null;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      labelText: "SwitchID",
                      labelStyle: TextStyle(fontSize: width * 0.035),
                    ),
                  ),
                  SizedBox(height: height * 0.03),
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: _ssid,
                    validator: (value) {
                      if (value!.isEmpty) return "SSID cannot be empty";
                      return null;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      labelText: "New Switch Name",
                      labelStyle: TextStyle(fontSize: width * 0.035),
                    ),
                  ),
                  SizedBox(height: height * 0.03),
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: _password,
                    validator: (value) {
                      if (value!.length <= 7) {
                        return "Switch Password cannot be less than 8 letters";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      labelText: "New Password",
                      labelStyle: TextStyle(fontSize: width * 0.035),
                    ),
                  ),
                  SizedBox(height: height * 0.03),
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    maxLength: 4,
                    controller: _privatePin,
                    validator: (value) {
                      if (value!.length <= 3) {
                        return "Switch Pin cannot be less than 4 letters";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      labelText: "New Pin",
                      labelStyle: TextStyle(fontSize: width * 0.035),
                    ),
                  ),
                  SizedBox(height: height * 0.03),
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "PassKey Cannot be empty";
                      }
                      if (value.length <= 7) {
                        return "PassKey Cannot be less than 8 letters";
                      }
                      return null;
                    },
                    controller: _passKey,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      labelText: "New Passkey",
                      labelStyle: TextStyle(fontSize: width * 0.035),
                    ),
                  ),
                  SizedBox(height: height * 0.03),
                  // DropdownButtonFormField<String>(
                  //   autovalidateMode: AutovalidateMode.onUserInteraction,
                  //   isExpanded: false,
                  //   value: selectedAppliance,
                  //   validator: (value) {
                  //     if (selectedAppliance == "" ||
                  //         selectedAppliance == null) {
                  //       return "Please select an appliance type";
                  //     }
                  //     return null;
                  //   },
                  //   hint: const Text("Select an appliance"),
                  //   items: appliances
                  //       .map<DropdownMenuItem<String>>((String value) {
                  //     return DropdownMenuItem<String>(
                  //       value: value,
                  //       child: Text(value),
                  //     );
                  //   }).toList(),
                  //   decoration: InputDecoration(
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(8),
                  //     ),
                  //     labelText: "Select an appliance",
                  //     labelStyle: TextStyle(fontSize: width * 0.035),
                  //   ),
                  //   onChanged: (String? newValue) {
                  //     setState(() {
                  //       selectedAppliance = newValue;
                  //
                  //       _availableSwitchTypes = List.from(_allSwitches);
                  //
                  //       selectedSwitches.removeWhere(
                  //         (switchMap) => !_availableSwitchTypes
                  //             .contains(switchMap['type']!.text),
                  //       );
                  //     });
                  //   },
                  // ),
                  // SizedBox(height: height * 0.03),
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: DropdownButtonFormField<String>(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          value: _selectedSwitchType,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedSwitchType = newValue;
                            });
                          },
                          validator: (value) {
                            if ((_addFan == "No") && selectedSwitches.isEmpty) {
                              return "Please select a switch type";
                            }
                            return null;
                          },
                          items: _availableSwitchTypes.map((switchType) {
                            return DropdownMenuItem<String>(
                              value: switchType,
                              child: Text(switchType),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            labelText:
                                "Select Switches and Rename Them if Needed",
                            labelStyle: TextStyle(fontSize: width * 0.035),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.add_circle),
                        onPressed: () {
                          if (_selectedSwitchType != null) {
                            setState(() {
                              selectedSwitches.add({
                                'type': TextEditingController(
                                    text: _selectedSwitchType),
                              });
                              _availableSwitchTypes.remove(_selectedSwitchType);
                              _selectedSwitchType = null;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  if (selectedSwitches.isNotEmpty) ...[
                    Column(
                      children: selectedSwitches.map((switchMap) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: switchMap['type'],
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    labelText: "Rename Switch",
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                icon: const Icon(Icons.remove_circle),
                                onPressed: () {
                                  setState(() {
                                    _availableSwitchTypes
                                        .add(switchMap['type']!.text);
                                    selectedSwitches.remove(switchMap);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  SizedBox(height: height * 0.03),
                  const Text(
                    "Do you want to add a fan?",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: const Text("Yes"),
                          leading: Radio<String>(
                            value: "Yes",
                            groupValue: _addFan,
                            onChanged: (value) {
                              setState(() {
                                _addFan = value;
                                if (_addFan == "No") {
                                  _fanNameController.clear();
                                }
                              });
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: const Text("No"),
                          leading: Radio<String>(
                            value: "No",
                            groupValue: _addFan,
                            onChanged: (value) {
                              setState(() {
                                _addFan = value;
                                if (_addFan == "No") {
                                  _fanNameController.clear();
                                }
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_addFan == "Yes") ...[
                    SizedBox(height: height * 0.02),
                    TextFormField(
                      controller: _fanNameController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (_addFan == "Yes" &&
                            (value == null || value.isEmpty)) {
                          return "Fan name cannot be empty";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        labelText: "Fan Name",
                        labelStyle: TextStyle(fontSize: width * 0.035),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Center(
          child: loading
              ? Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
                  child: InkWell(
                    splashColor: backGroundColour,
                    // onTap: onPressed,
                    child: Container(
                      width: 300,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.teal.shade600,
                            Colors.purple.shade300,
                            // Colors.yellow.shade400
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 1,
                            color: backGroundColour,
                            offset: const Offset(0, 2),
                          )
                        ],
                        borderRadius: BorderRadius.circular(12),
                        // border: Border.all(
                        //   color: bgmColor ?? backGroundColourDark,
                        //   width: 1,
                        // ),
                      ),
                      alignment: const AlignmentDirectional(0, 0),
                      child: CircularProgressIndicator(
                        color: appBarColour,
                      ),
                    ),
                  ),
                )
              : CustomButton(
                  text: "Submit",
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      setState(() {
                        loading = true;
                      });
                      bool exists = await _storageController.isswitchNameExists(
                          _ssid.text, _switchId.text);
                      if (exists) {
                        showDialog(
                          context: context,
                          builder: (cont) {
                            return AlertDialog(
                              title: const Text('Update Router'),
                              content: const Text(
                                  'SwitchId is already Exist, Do you want to update the existing switch'),
                              actions: [
                                OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      loading = false;
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'CANCEL',
                                    style: TextStyle(color: appBarColour),
                                  ),
                                ),
                                OutlinedButton(
                                  onPressed: () async {
                                    List<String> renamedSwitches =
                                        selectedSwitches.map((switchMap) {
                                      return switchMap['type']!.text;
                                    }).toList();
                                    String? fanName = _addFan == "Yes"
                                        ? _fanNameController.text
                                        : null;
                                    SwitchDetails switchDetails = SwitchDetails(
                                      privatePin: _privatePin.text,
                                      switchId: _switchId.text,
                                      switchSSID: _ssid.text,
                                      switchPassKey: _passKey.text,
                                      switchPassword: _password.text,
                                      iPAddress: routerIP,
                                      switchTypes: renamedSwitches,
                                      selectedFan: fanName ?? "",
                                    );
                                    Navigator.pop(context);
                                    try {
                                      await ApiConnect.hitApiGet(
                                        "$routerIP/",
                                      );
                                      await ApiConnect.hitApiPost(
                                          "$routerIP/settings", {
                                        "Lock_id": _switchId.text,
                                        "lock_name": _ssid.text,
                                        "lock_pass": _password.text
                                      });
                                      await ApiConnect.hitApiGet(
                                        "$routerIP/",
                                      );
                                      await ApiConnect.hitApiPost(
                                          "$routerIP/getSecretKey", {
                                        "Lock_id": _switchId.text,
                                        "lock_passkey": _passKey.text
                                      });
                                      _storageController.updateSwitchIfIdExist(
                                          _switchId.text,
                                          _ssid.text,
                                          switchDetails);

                                      Navigator.pushAndRemoveUntil<dynamic>(
                                        context,
                                        MaterialPageRoute<dynamic>(
                                          builder: (BuildContext context) =>
                                              const HomePage(),
                                        ),
                                        (route) => false,
                                      );
                                    } catch (e) {
                                      print("Error inside updating");
                                      print(e);
                                      showToast(
                                          context, "Error: ${e.toString()}");
                                    }
                                  },
                                  child: Text(
                                    'OK',
                                    style: TextStyle(color: appBarColour),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                        return;
                      } else {
                        List<String> renamedSwitches =
                            selectedSwitches.map((switchMap) {
                          return switchMap['type']!.text;
                        }).toList();
                        String? fanName =
                            _addFan == "Yes" ? _fanNameController.text : null;
                        SwitchDetails switchDetails = SwitchDetails(
                          privatePin: _privatePin.text,
                          switchId: _switchId.text,
                          switchSSID: _ssid.text,
                          switchPassKey: _passKey.text,
                          switchPassword: _password.text,
                          iPAddress: routerIP,
                          switchTypes: renamedSwitches,
                          selectedFan: fanName ?? "",
                        );
                        try {
                          await ApiConnect.hitApiGet(
                            "$routerIP/",
                          );
                          await ApiConnect.hitApiPost("$routerIP/settings", {
                            "Lock_id": _switchId.text,
                            "lock_name": _ssid.text,
                            "lock_pass": _password.text
                          });
                          await ApiConnect.hitApiGet(
                            "$routerIP/",
                          );
                          await ApiConnect.hitApiPost(
                              "$routerIP/getSecretKey", {
                            "Lock_id": _switchId.text,
                            "lock_passkey": _passKey.text
                          });
                          _storageController.addSwitches(switchDetails);
                          Navigator.pushAndRemoveUntil<dynamic>(
                            context,
                            MaterialPageRoute<dynamic>(
                              builder: (BuildContext context) =>
                                  const HomePage(),
                            ),
                            (route) => false,
                          );
                        } catch (e) {
                          await ApiConnect.hitApiGet(
                            "$routerIP/",
                          );
                          await ApiConnect.hitApiPost(
                              "$routerIP/getSecretKey", {
                            "Lock_id": switchDetails.switchId,
                            "lock_passkey": _passKey.text
                          });
                          _storageController.addSwitches(switchDetails);
                          setState(() {
                            loading = false;
                          });
                          Navigator.pushAndRemoveUntil<dynamic>(
                            context,
                            MaterialPageRoute<dynamic>(
                              builder: (BuildContext context) =>
                                  const HomePage(),
                            ),
                            (route) => false,
                          );
                        }
                      }
                    }
                  }),
        ),
      ),
    );
  }
}

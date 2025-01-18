import 'package:bbt_new/view/home_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../controllers/apis.dart';
import '../../controllers/storage.dart';
import '../../models/switch_model.dart';
import '../../widgets/custom/custom_appbar.dart';
import '../../widgets/custom/custom_button.dart';
import '../../widgets/custom/toast.dart';

class UpdatePage extends StatefulWidget {
  const UpdatePage({required this.switchDetails, super.key});

  final SwitchDetails switchDetails;

  @override
  State<UpdatePage> createState() => _UpdateSwitchPageState();
}

class _UpdateSwitchPageState extends State<UpdatePage> {
  @override
  void initState() {
    _password.text = widget.switchDetails.switchPassword;
    _password1.text = widget.switchDetails.switchPassword;
    _ssid.text = widget.switchDetails.switchSSID;
    _passKey.text = widget.switchDetails.switchPassKey!;
    _privatePin.text = widget.switchDetails.privatePin;
    super.initState();
  }

  // final TextEditingController _switchId = TextEditingController();

  final TextEditingController _ssid = TextEditingController();
  final TextEditingController _passKey = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _password1 = TextEditingController();
  final TextEditingController _privatePin = TextEditingController();
  final StorageController _storageController = StorageController();
  final formKey = GlobalKey<FormState>();
  bool loading = false;
  late String selectedAppliance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: CustomAppBar(heading: "AP Update")),
        body: Center(
          child: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _ssid,
                    validator: (value) {
                      if (value!.isEmpty) return "SSID cannot be empty";
                      return null;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        // borderSide: BorderSide(width: 40),
                      ),
                      labelText: "New Switch Name",
                      labelStyle: const TextStyle(fontSize: 15),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
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
                        // borderSide: BorderSide(width: 40),
                      ),
                      labelText: "New Password",
                      labelStyle: const TextStyle(fontSize: 15),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: _password1,
                    validator: (value) {
                      if (value!.length <= 7) {
                        return "Switch Password cannot be less than 8 letters";
                      }
                      if (_password.text != _password1.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        // borderSide: BorderSide(width: 40),
                      ),
                      labelText: "New Password",
                      labelStyle: const TextStyle(fontSize: 15),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
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
                        // borderSide: BorderSide(width: 40),
                      ),
                      labelText: "New Pin",
                      labelStyle: const TextStyle(fontSize: 15),
                    ),
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "PassKey Cannot be empty";
                      }
                      if (value.length <= 7) {
                        return "PassKey Cannot be less than 8 letters";
                      }
                      final validCharacters = RegExp(r'^[a-zA-Z0-9]+$');
                      if (validCharacters.hasMatch(value)) {
                        return "Passkey should be alphanumeric";
                      }
                      return null;
                    },
                    controller: _passKey,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        // borderSide: BorderSide(width: 40),
                      ),
                      labelText: "New Passkey",
                      labelStyle: const TextStyle(fontSize: 15),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  loading
                      ? Align(
                          // alignment: AlignmentDirectional(1, 0),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                16, 0, 16, 16),
                            child: InkWell(
                              splashColor: backGroundColour,
                              // onTap: onPressed,
                              child: Container(
                                width: 300,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: backGroundColour,
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 1,
                                      color: backGroundColour,
                                      offset: const Offset(0, 2),
                                    )
                                  ],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: backGroundColour,
                                    width: 1,
                                  ),
                                ),
                                alignment: const AlignmentDirectional(0, 0),
                                child: CircularProgressIndicator(
                                    color: backGroundColourDark),
                              ),
                            ),
                          ),
                        )
                      : CustomButton(
                          width: 200,
                          text: "Submit",
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              SwitchDetails switchDetails1 = SwitchDetails(
                                privatePin: _privatePin.text,
                                switchId: widget.switchDetails.switchId,
                                switchSSID: _ssid.text,
                                switchPassKey: _passKey.text,
                                switchPassword: _password.text,
                                iPAddress: widget.switchDetails.iPAddress,
                                switchTypes: [],
                                selectedFan: '',
                                // selectedAppliance: '',
                              );
                              try {
                                setState(() {
                                  loading = true;
                                });
                                await ApiConnect.hitApiGet(
                                  routerIP + "/",
                                );
                                var data = {
                                  "Lock_id": widget.switchDetails.switchId,
                                  "lock_name": _ssid.text,
                                  "lock_pass": _password.text
                                };
                                print(data);
                                await ApiConnect.hitApiPost(
                                    "$routerIP/settings", data);

                                await ApiConnect.hitApiPost(
                                    "$routerIP/getSecretKey", {
                                  "Lock_id": switchDetails1.switchId,
                                  "lock_passkey": _passKey.text
                                });
                                _storageController.updateSwitch(
                                    switchDetails1.switchId, switchDetails1);
                                Navigator.pushAndRemoveUntil<dynamic>(
                                  context,
                                  MaterialPageRoute<dynamic>(
                                    builder: (BuildContext context) =>
                                        const HomePage(),
                                  ),
                                  (route) => false,
                                );
                              } on DioException {
                                await ApiConnect.hitApiGet(
                                  "$routerIP/",
                                );
                                await ApiConnect.hitApiPost(
                                    "$routerIP/getSecretKey", {
                                  "Lock_id": switchDetails1.switchId,
                                  "lock_passkey": _passKey.text
                                });
                                _storageController.updateSwitch(
                                    switchDetails1.switchId, switchDetails1);
                                Navigator.pushAndRemoveUntil<dynamic>(
                                  context,
                                  MaterialPageRoute<dynamic>(
                                    builder: (BuildContext context) =>
                                        const HomePage(),
                                  ),
                                  (route) => false,
                                );
                              } catch (e) {
                                print(e.toString());
                                showToast(
                                    context, "Failed to Update. Try again");
                                setState(() {
                                  loading = false;
                                });
                              }
                            }
                          },
                        )
                ],
              ),
            ),
          ),
        ));
  }
}

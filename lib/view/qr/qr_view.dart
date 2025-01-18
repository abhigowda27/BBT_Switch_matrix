import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import '../../constants.dart';
import '../../models/switch_model.dart';
import '../../widgets/custom/custom_appbar.dart';
import '../../widgets/custom/custom_button.dart';
import '../switches/add_switch.dart';

class QRView extends StatefulWidget {
  const QRView({super.key});

  @override
  State<QRView> createState() => _QRViewState();
}

class _QRViewState extends State<QRView> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    scanQR();
  }

  String _scanBarcode = 'Unknown';
  SwitchDetails details = SwitchDetails(
      switchId: "Unknown",
      switchSSID: "Unknown",
      switchPassword: "Unknown",
      privatePin: "1234",
      iPAddress: "Unknown",
      switchTypes: [],
      // selectedAppliance: '',
      selectedFan: "");

  Future<void> scanQR() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
      var jsonR = json.decode(barcodeScanRes);
      details = SwitchDetails(
          switchId: jsonR['LockId'],
          privatePin: "1234",
          switchSSID: jsonR['LockSSID'],
          switchPassword: jsonR['LockPassword'].toString(),
          iPAddress: jsonR['IPAddress'],
          switchTypes: [],
          // selectedAppliance: '',
          selectedFan: "");
      // details = LockDetails(lockld: barcodeScanRes[''], lockSSID: lockSSID, lockPassword: lockPassword, iPAddress: iPAddress)
    });
  }

  @override
  Widget build(BuildContext context) {
    if (details.switchId == "Unknown") {
      return Center(
          child: CircularProgressIndicator(color: backGroundColourDark));
    }
    return GestureDetector(
      // onTap: () => FocusScope.of(context).requestFocus(_model.unfocusNode),
      child: Scaffold(
        // key: scaffoldKey,
        backgroundColor: Colors.white,
        appBar: const PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: CustomAppBar(heading: "QR Details")),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * .8,
                    height: 180,
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade400,
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(
                                5, 5), // changes position of shadow
                          ),
                        ],
                        color: whiteColour,
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Switch ID : ",
                                style: TextStyle(
                                    fontSize: 20,
                                    color: blackColour,
                                    fontWeight: FontWeight.bold),
                              ),
                              Wrap(
                                children: [
                                  Text(
                                    details.switchId,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: blackColour,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                "Switch Name : ",
                                style: TextStyle(
                                    fontSize: 20,
                                    color: blackColour,
                                    fontWeight: FontWeight.bold),
                              ),
                              Wrap(
                                children: [
                                  Text(
                                    details.switchSSID,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: blackColour,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                "Switch Password : ",
                                style: TextStyle(
                                    fontSize: 20,
                                    color: blackColour,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                details.switchPassword,
                                style: TextStyle(
                                    fontSize: 20,
                                    color: blackColour,
                                    fontWeight: FontWeight.w400),
                              )
                            ],
                          ),

                          const Expanded(
                            child: Text(
                              "Please NOTE down the password you will need to configure and change the Switch",
                              style: TextStyle(
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.justify,
                            ),
                          ),
                          // Text("Start and End Date : 00-00"),
                          // Text("Start and End Time : 00:00-00:00"),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Center(
                child: CustomButton(
                    width: 200,
                    text: "Next",
                    onPressed: () {
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Instructions'),
                          content: const Text(
                              'Below to personalize your configuration you are required to change the switch name and password for security purpose.'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context, 'Cancel'),
                              child: Text(
                                'Cancel',
                                style: TextStyle(color: appBarColour),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const AddNewSwitchesPage()));
                              },
                              child: Text(
                                'Continue',
                                style: TextStyle(color: appBarColour),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}

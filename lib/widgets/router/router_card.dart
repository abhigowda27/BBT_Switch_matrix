import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:bbt_new/view/home_page.dart';
import 'package:bbt_new/widgets/custom/toast.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../constants.dart';
import '../../controllers/permission.dart';
import '../../controllers/storage.dart';
import '../../models/router_model.dart';

class RouterCard extends StatefulWidget {
  final RouterDetails routerDetails;
  const RouterCard({
    required this.routerDetails,
    super.key,
  });

  @override
  State<RouterCard> createState() => _RouterCardState();
}

class _RouterCardState extends State<RouterCard> {
  bool hide = true;
  StorageController _storageController = StorageController();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final height = screenSize.height;
    final width = screenSize.width;
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: MediaQuery.of(context).size.width * .8,
          // height: 150,
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: Colors.grey.shade400,
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(5, 5),
            ),
          ], color: whiteColour, borderRadius: BorderRadius.circular(12)),
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
                          fontSize: width * 0.04,
                          color: blackColour,
                          fontWeight: FontWeight.bold),
                    ),
                    Flexible(
                      child: Text(
                        widget.routerDetails.switchID,
                        style: TextStyle(
                            fontSize: width * 0.04,
                            color: blackColour,
                            fontWeight: FontWeight.w400),
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "Switch Name : ",
                      style: TextStyle(
                          fontSize: width * 0.04,
                          color: blackColour,
                          fontWeight: FontWeight.bold),
                    ),
                    Flexible(
                      child: Text(
                        widget.routerDetails.switchName,
                        style: TextStyle(
                            fontSize: width * 0.04,
                            color: blackColour,
                            fontWeight: FontWeight.w400),
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "Router Name : ",
                      style: TextStyle(
                          fontSize: width * 0.04,
                          color: blackColour,
                          fontWeight: FontWeight.bold),
                    ),
                    Flexible(
                      child: Text(
                        widget.routerDetails.routerName,
                        style: TextStyle(
                            fontSize: width * 0.04,
                            color: blackColour,
                            fontWeight: FontWeight.w400),
                      ),
                    )
                  ],
                ),
                if (widget.routerDetails.switchTypes.isNotEmpty) ...[
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
                        children: widget.routerDetails.switchTypes
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
                if (widget.routerDetails.selectedFan!.isNotEmpty) ...[
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
                          widget.routerDetails.selectedFan!,
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
                          fontWeight: FontWeight.bold),
                    ),
                    Flexible(
                      child: Text(
                        hide
                            ? List.generate(
                                widget.routerDetails.switchPasskey.length,
                                (index) => "*").join()
                            : widget.routerDetails.switchPasskey,
                        style: TextStyle(
                            fontSize: width * 0.04,
                            color: blackColour,
                            fontWeight: FontWeight.w400),
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "Router Password: ",
                      style: TextStyle(
                          fontSize: width * 0.04,
                          color: blackColour,
                          fontWeight: FontWeight.bold),
                    ),
                    Flexible(
                      child: Text(
                        hide
                            ? List.generate(
                                widget.routerDetails.routerPassword.length,
                                (index) => "*").join()
                            : widget.routerDetails.routerPassword,
                        style: TextStyle(
                            fontSize: width * 0.04,
                            color: blackColour,
                            fontWeight: FontWeight.w400),
                      ),
                    )
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                      color: appBarColour,
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                          tooltip: "Delete Router",
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (cont) {
                                return AlertDialog(
                                  title: const Text('Delete Router'),
                                  content:
                                      const Text('This will delete the Router'),
                                  actions: [
                                    OutlinedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        'CANCEL',
                                        style: TextStyle(color: appBarColour),
                                      ),
                                    ),
                                    OutlinedButton(
                                      onPressed: () async {
                                        _storageController.deleteOneRouter(
                                            widget.routerDetails.switchID);
                                        Navigator.pushAndRemoveUntil<dynamic>(
                                          context,
                                          MaterialPageRoute<dynamic>(
                                            builder: (BuildContext context) =>
                                                HomePage(),
                                          ),
                                          (route) =>
                                              false, //if you want to disable back feature set to false
                                        );
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
                          },
                          icon: Icon(Icons.delete_outline, color: blackColour)),
                      const SizedBox(
                        width: 10,
                      ),
                      IconButton(
                          tooltip: "Show Details",
                          onPressed: () {
                            setState(() {
                              hide = !hide;
                            });
                          },
                          icon: hide
                              ? Icon(Icons.visibility_rounded,
                                  color: blackColour)
                              : Icon(Icons.visibility_off_rounded,
                                  color: blackColour)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

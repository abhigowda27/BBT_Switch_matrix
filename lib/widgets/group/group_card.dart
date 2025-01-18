import 'package:bbt_new/view/home_page.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../controllers/storage.dart';
import '../../models/group_model.dart';
import '../../models/router_model.dart';

class GroupCard extends StatefulWidget {
  final GroupDetails groupDetails;

  GroupCard({required this.groupDetails, Key? key}) : super(key: key);

  @override
  State<GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard> {
  bool hide = true;
  StorageController _storageController = StorageController();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: MediaQuery.of(context).size.width * .8,
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
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Group Name: ",
                      style: TextStyle(
                        fontSize: width * 0.04,
                        color: blackColour,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        widget.groupDetails.groupName,
                        style: TextStyle(
                          fontSize: width * 0.04,
                          color: blackColour,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
                //SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      "Selected Router: ",
                      style: TextStyle(
                        fontSize: width * 0.04,
                        color: blackColour,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        widget.groupDetails.selectedRouter,
                        style: TextStyle(
                          fontSize: width * 0.04,
                          color: blackColour,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
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
                                widget.groupDetails.routerPassword.length,
                                (index) => "*").join()
                            : widget.groupDetails.routerPassword,
                        style: TextStyle(
                            fontSize: width * 0.04,
                            color: blackColour,
                            fontWeight: FontWeight.w400),
                      ),
                    )
                  ],
                ),
                //SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Selected Switches:",
                      style: TextStyle(
                        fontSize: width * 0.04,
                        color: blackColour,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.groupDetails.selectedSwitches
                          .asMap()
                          .entries
                          .map((entry) {
                        int index = entry.key;
                        RouterDetails switchDetail = entry.value;
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${index + 1} :',
                              style: TextStyle(
                                fontSize: width * 0.04,
                                color: blackColour,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              switchDetail.switchName,
                              style: TextStyle(
                                fontSize: width * 0.04,
                                color: blackColour,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(
                                height:
                                    10), // Add some spacing between switches
                          ],
                        );
                      }).toList(),
                    )
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: appBarColour,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        tooltip: "Delete Group",
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (cont) {
                              return AlertDialog(
                                title: const Text('Delete Group'),
                                content:
                                    const Text('This will delete the Group'),
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
                                      _storageController
                                          .deleteOneGroup(widget.groupDetails);
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
                        icon: Icon(Icons.delete_outline_outlined,
                            color: blackColour),
                      ),
                      IconButton(
                          tooltip: "password",
                          onPressed: () {
                            setState(() {
                              hide = !hide;
                            });
                          },
                          icon: hide
                              ? Icon(
                                  Icons.visibility_rounded,
                                  color: blackColour,
                                )
                              : Icon(
                                  Icons.visibility_off_rounded,
                                  color: blackColour,
                                )),
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

import 'package:bbt_new/view/home_page.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../controllers/storage.dart';
import '../../models/contacts.dart';

class ContactsCard extends StatelessWidget {
  final ContactsModel contactsDetails;
  ContactsCard({
    required this.contactsDetails,
    super.key,
  });
  final StorageController _storageController = StorageController();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
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
              offset: const Offset(5, 5), // changes position of shadow
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
                      "Contact Name : ",
                      style: TextStyle(
                          fontSize: width * 0.04,
                          color: blackColour,
                          fontWeight: FontWeight.w600),
                    ),
                    Flexible(
                      child: Text(
                        contactsDetails.name,
                        // maxLines: 2,
                        // overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: width * 0.04,
                            color: blackColour,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "Access Permission : ",
                      style: TextStyle(
                          fontSize: width * 0.04,
                          color: blackColour,
                          fontWeight: FontWeight.bold),
                    ),
                    Flexible(
                      child: Text(
                        contactsDetails.accessType,
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
                      "Start and End Date : ",
                      style: TextStyle(
                          fontSize: width * 0.04,
                          color: blackColour,
                          fontWeight: FontWeight.bold),
                    ),
                    Flexible(
                      child: Text(
                        contactsDetails.accessType.contains("Timed")
                            ? "${contactsDetails.startDateTime.day}/${contactsDetails.startDateTime.month}/${contactsDetails.startDateTime.year}-${contactsDetails.endDateTime.day}/${contactsDetails.endDateTime.month}/${contactsDetails.endDateTime.year}"
                            : "00-00",
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
                      "Start and End Time : ",
                      style: TextStyle(
                          fontSize: width * 0.04,
                          color: blackColour,
                          fontWeight: FontWeight.bold),
                    ),
                    Flexible(
                      child: Text(
                        contactsDetails.accessType.contains("Timed")
                            ? "${contactsDetails.startDateTime.hour}:${contactsDetails.startDateTime.minute}-${contactsDetails.endDateTime.hour}:${contactsDetails.endDateTime.minute}"
                            : "00:00-00:00",
                        style: TextStyle(
                            fontSize: width * 0.04,
                            color: blackColour,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
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
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (cont) {
                                  return AlertDialog(
                                    title: const Text('BBT Switch'),
                                    content: const Text(
                                        'This will delete the Switch'),
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
                                          _storageController.deleteOneContact(
                                              contactsDetails);
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
                                });
                          },
                          icon: Icon(
                            Icons.delete_outline_rounded,
                            color: blackColour,
                          ))
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

import 'package:bbt_new/view/home_page.dart';

import '../../bottom_nav_bar.dart';
import '../../constants.dart';
import '../../controllers/storage.dart';
import '../../models/contacts.dart';
import '../../widgets/custom/toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Utils {
  static String getFormattedDateSimple(int time) {
    DateFormat newFormat = DateFormat("MMMM dd, yyyy");
    return newFormat.format(DateTime.fromMillisecondsSinceEpoch(time));
  }
}

class AccessRequestPage extends StatefulWidget {
  AccessRequestPage({required this.name, super.key});
  final String name;
  static List<String> items = [
    'Full Time Access',
    'Timed Access',
  ];

  @override
  State<AccessRequestPage> createState() => _AccessRequestPageState();
}

class _AccessRequestPageState extends State<AccessRequestPage> {
  late Future<DateTime?> selectedStartDate;
  late Future<DateTime?> selectedEndDate;
  String startdate = "-";
  String enddate = "-";
  bool hasSelectedStartTime = false;
  bool hasSelectedEndTime = false;
  bool hasSelectedStartDate = false;
  bool hasSelectedEndDate = false;

  DateTime finalStartDate = DateTime.now();
  DateTime finalEndDate = DateTime.now();

  late Future<TimeOfDay?> selectedStartTime;
  late Future<TimeOfDay?> selectedEndTime;
  String starttime = "-";
  String endtime = "-";
  String dropdownvalue = "Full Time Access";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ARP"),
      ),
      body: Center(
        child: Column(
          children: [
            Text(widget.name),
            DropdownButton<String>(
              // Initial Value
              value: dropdownvalue,

              // Down Arrow Icon
              icon: const Icon(Icons.keyboard_arrow_down),

              // Array list of items
              items: AccessRequestPage.items.map((String items) {
                return DropdownMenuItem(
                  value: items,
                  child: Text(items),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  dropdownvalue = newValue!;
                });
                // if (dropdownvalue == "Timed Access") {
                //   _selectDateTime(context);
                //   print(getDateTime());
                // }
              },
            ),
            dropdownvalue == "Timed Access" ? selectDateTime() : Container(),
            ElevatedButton(
                onPressed: () {
                  StorageController storage = StorageController();
                  if (dropdownvalue == "Timed Access") {
                    if (!hasSelectedStartDate) {
                      showToast(context, "Start Date is not selected");
                      return;
                    }
                    if (!hasSelectedEndDate) {
                      showToast(context, "End Date is not selected");
                      return;
                    }
                    if (!hasSelectedStartTime) {
                      showToast(context, "Start Time is not selected");
                      return;
                    }
                    if (!hasSelectedEndTime) {
                      showToast(context, "End Time is not selected");
                      return;
                    }
                    print(finalStartDate);
                    print(finalEndDate);
                    if (finalEndDate.isBefore(finalStartDate)) {
                      showToast(
                          context, "End Date cannot be before Start Date");
                      return;
                    }
                    storage.addContacts(ContactsModel(
                        accessType: dropdownvalue,
                        startDateTime: finalStartDate,
                        endDateTime: finalEndDate,
                        name: widget.name));
                  } else {
                    storage.addContacts(ContactsModel(
                        accessType: dropdownvalue,
                        startDateTime: DateTime.now(),
                        endDateTime: DateTime.now(),
                        name: widget.name));
                  }
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HomePage()));
                },
                child: Text("Submit",style: TextStyle(color: appBarColour),))
          ],
        ),
      ),
    );
  }

  void showDialogPicker(BuildContext context, String dateType) {
    if (dateType == "Start") {
      selectedStartDate = showDatePicker(
        context: context,
        // helpText: 'Your Date of Birth',
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2050),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(
                // primary: MyColors.primary,
                primary: Theme.of(context).colorScheme.primary,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
              //.dialogBackgroundColor:Colors.blue[900],
            ),
            child: child!,
          );
        },
      );
      selectedStartDate.then(
            (value) {
          setState(() {
            if (value == null) return;
            finalStartDate = value;
            startdate =
                Utils.getFormattedDateSimple(value.millisecondsSinceEpoch);
            hasSelectedStartDate = true;
          });
        },
        onError: (error) {
          if (kDebugMode) {
            print(error);
          }
        },
      );
    } else {
      selectedEndDate = showDatePicker(
        context: context,
        // helpText: 'Your Date of Birth',
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2050),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(
                // primary: MyColors.primary,
                primary: Theme.of(context).colorScheme.primary,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
              //.dialogBackgroundColor:Colors.blue[900],
            ),
            child: child!,
          );
        },
      );
      selectedEndDate.then((value) {
        setState(() {
          if (value == null) return;
          print(value);
          finalEndDate = value;
          enddate = Utils.getFormattedDateSimple(value.millisecondsSinceEpoch);
          hasSelectedEndDate = true;
        });
      }, onError: (error) {
        if (kDebugMode) {
          print(error);
        }
      });
    }
    setState(() {
      hasSelectedStartTime = false;
      hasSelectedEndTime = false;
      starttime = "-";
      endtime = "-";
    });
  }

  void showDialogTimePicker(BuildContext context, String timeType) {
    if (timeType == "Start") {
      selectedStartTime = showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(
                // primary: MyColors.primary,
                primary: Theme.of(context).colorScheme.primary,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
              //.dialogBackgroundColor:Colors.blue[900],
            ),
            child: child!,
          );
        },
      );
      selectedStartTime.then((value) {
        setState(() {
          if (value == null) return;
          finalStartDate = DateTime(finalStartDate.year, finalStartDate.month,
              finalStartDate.day, value.hour, value.minute);
          starttime = "${value.hour} : ${value.minute}";
          hasSelectedStartTime = true;
        });
      }, onError: (error) {
        if (kDebugMode) {
          print(error);
        }
      });
    } else {
      selectedEndTime = showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(
                // primary: MyColors.primary,
                primary: Theme.of(context).colorScheme.primary,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
              //.dialogBackgroundColor:Colors.blue[900],
            ),
            child: child!,
          );
        },
      );
      selectedEndTime.then((value) {
        setState(() {
          if (value == null) return;
          finalEndDate = DateTime(finalEndDate.year, finalEndDate.month,
              finalEndDate.day, value.hour, value.minute);
          endtime = "${value.hour} : ${value.minute}";
          hasSelectedEndTime = true;
        });
      }, onError: (error) {
        if (kDebugMode) {
          print(error);
        }
      });
    }
  }

  Widget selectDateTime() {
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          width: double.infinity,
          height: 45,
          // color: Colors.grey[300],
          child: Text("$startdate : $enddate"),
        ),
        Container(
          alignment: Alignment.center,
          width: double.infinity,
          height: 45,
          // color: Colors.grey[300],
          child: Text("$starttime - $endtime"),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 30)),
                child: const Text("Pick Start Date",
                    style: TextStyle(color: Colors.white)),
                onPressed: () {
                  showDialogPicker(context, "Start");
                },
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 30)),
                child: const Text("Pick End Date",
                    style: TextStyle(color: Colors.white)),
                onPressed: () {
                  showDialogPicker(context, "End");
                },
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 30)),
                child: const Text("PICK Start TIME",
                    style: TextStyle(color: Colors.white)),
                onPressed: () {
                  showDialogTimePicker(context, "Start");
                },
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 30)),
                child: const Text("PICK End TIME",
                    style: TextStyle(color: Colors.white)),
                onPressed: () {
                  showDialogTimePicker(context, "End");
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}


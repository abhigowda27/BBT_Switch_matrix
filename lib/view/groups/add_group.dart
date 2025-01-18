import 'package:bbt_new/view/home_page.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../controllers/storage.dart';
import '../../models/group_model.dart';
import '../../models/router_model.dart';
import '../../widgets/custom/custom_appbar.dart';
import '../../widgets/custom/custom_button.dart';
import '../../widgets/custom/toast.dart';

class NewGroupInstallationPage extends StatefulWidget {
  const NewGroupInstallationPage({super.key});

  @override
  State<NewGroupInstallationPage> createState() =>
      _NewGroupInstallationPageState();
}

class _NewGroupInstallationPageState extends State<NewGroupInstallationPage> {
  final StorageController _storage = StorageController();
  final TextEditingController _groupName = TextEditingController();
  bool loading = false;
  List<RouterDetails> selectedSwitches = [];
  List<RouterDetails> availableSwitches = [];
  String? selectedRouter;
  List<RouterDetails> availableRouters = [];

  @override
  void initState() {
    super.initState();
    fetchAvailableRouters();
  }

  void fetchAvailableSwitches(String routerName) async {
    try {
      List<RouterDetails> allSwitches = await _storage.readRouters();
      List<RouterDetails> filteredSwitches = allSwitches
          .where((switchItem) => switchItem.routerName == routerName)
          .toList();

      setState(() {
        availableSwitches = filteredSwitches;
      });
    } catch (e) {
      showToast(context, "Error fetching switches");
    }
  }

  void fetchAvailableRouters() async {
    try {
      List<RouterDetails> routers = await _storage.readRouters();
      Set<String> seenNames = Set();
      List<RouterDetails> uniqueRouters = [];

      for (var router in routers) {
        if (!seenNames.contains(router.routerName)) {
          seenNames.add(router.routerName);
          uniqueRouters.add(router);
        }
      }
      setState(() {
        availableRouters = uniqueRouters;
      });
    } catch (e) {
      showToast(context, "Error fetching routers");
    }
  }

  void handleRouterChange(String? selectedRouter) {
    setState(() {
      this.selectedRouter = selectedRouter;
      if (selectedRouter != null) {
        fetchAvailableSwitches(selectedRouter);
      } else {
        availableSwitches = [];
        selectedSwitches = [];
      }
    });
  }

  // Future<void> handleSubmit() async {
  //   if (_groupName.text.isEmpty) {
  //     showToast(context, "Group name cannot be empty.");
  //     return;
  //   }
  //   String groupName = _groupName.text;
  //   bool groupExists = await _storage.groupExists(groupName);
  //   if (groupExists) {
  //     showToast(context, "Group name already Exist.");
  //     return;
  //   }
  //   try {
  //     setState(() {
  //       loading = true;
  //     });
  //
  //     GroupDetails groupDetails = GroupDetails(
  //       groupName: groupName,
  //       selectedRouter: selectedRouter!,
  //       selectedSwitches: selectedSwitches,
  //       routerPassword: '',
  //     );
  //     await _storage.saveGroupDetails(groupDetails);
  //     setState(() {
  //       loading = false;
  //     });
  //
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => const HomePage(),
  //       ),
  //     );
  //   } catch (e) {
  //     showToast(context, "Unable to connect. Try Again.");
  //     setState(() {
  //       loading = false;
  //     });
  //   }
  // }
  Future<void> handleSubmit() async {
    if (_groupName.text.isEmpty) {
      showToast(context, "Group name cannot be empty.");
      return;
    }
    String groupName = _groupName.text;
    bool groupExists = await _storage.groupExists(groupName);
    if (groupExists) {
      showToast(context, "Group name already exists.");
      return;
    }
    try {
      setState(() {
        loading = true;
      });

      // Fetch the selected router's details
      RouterDetails? selectedRouterDetails = availableRouters
          .firstWhere((router) => router.routerName == selectedRouter);

      if (selectedRouterDetails == null) {
        showToast(context, "Please select a valid router.");
        setState(() {
          loading = false;
        });
        return;
      }

      GroupDetails groupDetails = GroupDetails(
        groupName: groupName,
        selectedRouter: selectedRouterDetails.routerName,
        routerPassword: selectedRouterDetails.routerPassword,
        selectedSwitches: selectedSwitches,
      );

      await _storage.saveGroupDetails(groupDetails);

      setState(() {
        loading = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
    } catch (e) {
      showToast(context, "Unable to connect. Try Again.");
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;
    final height = screenSize.height;
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: CustomAppBar(heading: "Add Group"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              TextFormField(
                controller: _groupName,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelText: "New Group Name",
                  labelStyle: TextStyle(fontSize: width * 0.035),
                ),
              ),
              SizedBox(height: height * 0.03),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelText: "Select Router",
                  labelStyle: TextStyle(fontSize: width * 0.035),
                ),
                value: selectedRouter,
                onChanged: handleRouterChange,
                items: availableRouters
                    .map((routerItem) => DropdownMenuItem(
                          value: routerItem.routerName,
                          child: Text(routerItem.routerName),
                        ))
                    .toList(),
              ),
              SizedBox(height: height * 0.01),
              Text("Selected Router:",
                  style: TextStyle(
                      fontSize: width * 0.04, fontWeight: FontWeight.bold)),
              if (selectedRouter != null)
                ListTile(
                  title: Text(selectedRouter!),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline_outlined,
                        color: backGroundColour),
                    onPressed: () {
                      setState(() {
                        selectedRouter = null;
                        availableSwitches = [];
                        selectedSwitches = [];
                      });
                    },
                  ),
                ),
              SizedBox(height: height * 0.03),
              DropdownButtonFormField<RouterDetails>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelText: "Select Switches",
                  labelStyle: TextStyle(fontSize: width * 0.035),
                ),
                value: null,
                onChanged: (selectedSwitch) {
                  setState(() {
                    if (selectedSwitch != null &&
                        !selectedSwitches.contains(selectedSwitch)) {
                      selectedSwitches.add(selectedSwitch);
                    }
                  });
                },
                items: availableSwitches
                    .map((switchItem) => DropdownMenuItem(
                          value: switchItem,
                          child: Text(
                              "${switchItem.routerName}_${switchItem.switchName}"),
                        ))
                    .toList(),
              ),
              SizedBox(height: height * 0.01),
              Text("Selected Switches:",
                  style: TextStyle(
                      fontSize: width * 0.04, fontWeight: FontWeight.bold)),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: selectedSwitches.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(selectedSwitches[index].switchName),
                      trailing: IconButton(
                        icon:
                            Icon(Icons.delete_outline, color: backGroundColour),
                        onPressed: () {
                          setState(() {
                            selectedSwitches.removeAt(index);
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                height: 20,
              ),
              loading
                  ? CircularProgressIndicator(color: backGroundColourDark)
                  : CustomButton(
                      width: 200,
                      text: "Submit",
                      onPressed: handleSubmit,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

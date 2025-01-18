import 'dart:async';

import 'package:bbt_new/view/home_page.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../controllers/apis.dart';
import '../../controllers/storage.dart';
import '../../models/router_model.dart';
import '../../widgets/custom/custom_appbar.dart';
import '../../widgets/group/group_matrix_card.dart';

class GroupSwitchOnOff extends StatefulWidget {
  final String groupName;
  final String selectedRouter;
  final List<RouterDetails> selectedSwitches;

  GroupSwitchOnOff({
    required this.groupName,
    required this.selectedRouter,
    required this.selectedSwitches,
    super.key,
  });

  @override
  State<GroupSwitchOnOff> createState() => _GroupSwitchOnOffState();
}

class _GroupSwitchOnOffState extends State<GroupSwitchOnOff> {
  final StorageController _storageController = StorageController();
  late bool isSwitchOn = false;
  late Timer _timer;
  final Duration _timerDuration = const Duration(seconds: 30);
  Future<List<RouterDetails>> fetchRouters() async {
    return widget.selectedSwitches;
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
    _loadSwitchState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer(_timerDuration, _navigateToNextPage);
  }

  void _resetTimer() {
    _timer.cancel();
    print("starts reloading");
    _startTimer();
  }

  Future<void> _loadSwitchState() async {
    bool state = await _storageController.loadGroupSwitchState();
    setState(() {
      isSwitchOn = state;
    });
  }

  Future<void> _saveGroupSwitchState(bool value) async {
    setState(() {
      isSwitchOn = value;
    });
    await _storageController.saveGroupSwitchState(value);
  }

  void _navigateToNextPage() {
    if (mounted) {
      Navigator.pushAndRemoveUntil<dynamic>(
        context,
        MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => const HomePage(),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final height = screenSize.height;
    final width = screenSize.width;
    return GestureDetector(
      onTap: _resetTimer,
      child: Scaffold(
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: CustomAppBar(heading: "GROUP SWITCH"),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade400,
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(5, 5),
                      ),
                    ],
                    color: appBarColour,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.groupName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: width * 0.045,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      FutureBuilder<List<RouterDetails>>(
                        future: fetchRouters(),
                        builder: (context, routerSnapshot) {
                          if (routerSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator(
                                color: backGroundColourDark);
                          }
                          if (routerSnapshot.hasError) {
                            return const Text("ERROR");
                          }
                          final List<RouterDetails> routers =
                              routerSnapshot.data ?? [];
                          return Switch(
                            onChanged: (value) async {
                              await _saveGroupSwitchState(value);
                              for (var switchDetails in routers) {
                                var totalSwitches =
                                    switchDetails.switchTypes.length;
                                try {
                                  for (int i = 1; i <= totalSwitches; i++) {
                                    await ApiConnect.hitApiPost(
                                        "${switchDetails.iPAddress}/getSwitchcmd",
                                        {
                                          "Lock_id": switchDetails.switchID,
                                          "lock_passkey":
                                              switchDetails.switchPasskey,
                                          "lock_cmd": value ? "ON$i" : "OFF$i",
                                        }).timeout(const Duration(seconds: 2));
                                    print(value ? "ON$i" : "OFF$i");
                                  }
                                } catch (e) {
                                  // Handle the timeout error if needed
                                  print(
                                      'API call to ${switchDetails.iPAddress} timed out.');
                                }
                              }
                              setState(() {
                                isSwitchOn = value;
                              });
                            },
                            value: isSwitchOn,
                            activeColor: greenButtonColour,
                            activeTrackColor: greenColour,
                            inactiveThumbColor: redButtonColour,
                            inactiveTrackColor: redColour,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              FutureBuilder<List<RouterDetails>>(
                future: fetchRouters(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(
                        color: backGroundColourDark);
                  }
                  if (snapshot.hasError) {
                    return const Text("ERROR");
                  }
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data?.length ?? 0,
                    itemBuilder: (context, index) {
                      return Padding(
                          padding: const EdgeInsets.all(8.0),
                          // child: Container(
                          //   padding: const EdgeInsets.symmetric(
                          //       vertical: 8.0, horizontal: 12.0),
                          //   decoration: BoxDecoration(
                          //     boxShadow: [
                          //       BoxShadow(
                          //         color: Colors.grey.shade400,
                          //         spreadRadius: 5,
                          //         blurRadius: 7,
                          //         offset: const Offset(5, 5),
                          //       ),
                          //     ],
                          //     color: backGroundColour,
                          //     borderRadius: BorderRadius.circular(10),
                          //   ),
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     children: [
                          //       Flexible(
                          //         child: Text(
                          //           "${index + 1} : ${snapshot.data![index].switchName}",
                          //           style: TextStyle(
                          //             fontSize: 20,
                          //             color: whiteColour,
                          //             fontWeight: FontWeight.bold,
                          //           ),
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          child: GroupMatrixCard(
                            switchDetails: snapshot.data![index],
                          ));
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import '../constants.dart';
// import '../controllers/storage.dart';
// import '../models/group_model.dart';
// import 'add_group.dart';
//
// class GroupingPage extends StatelessWidget {
//   GroupingPage({super.key});
//
//   final StorageController _storageController = StorageController();
//
//   Future<List<GroupDetails>> fetchGroups() async {
//     return _storageController.readAllGroups();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     final height = screenSize.height;
//     final width = screenSize.width;
//     return Scaffold(
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//       floatingActionButton: SizedBox(
//         height: 100,
//         width: 120,
//         child: FloatingActionButton.large(
//           backgroundColor: appBarColour,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.add, size: 30, color: backGroundColour),
//               Text(
//                 "Add Group",
//                 style: TextStyle(
//                     fontSize: width * 0.045,
//                     fontWeight: FontWeight.bold,
//                     color: backGroundColour),
//               ),
//             ],
//           ),
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => const NewGroupInstallationPage(),
//               ),
//             );
//           },
//         ),
//       ),
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(60),
//         child: AppBar(
//           iconTheme: IconThemeData(color: appBarColour),
//           backgroundColor: backGroundColour,
//           automaticallyImplyLeading: false,
//           title: Text(
//             "GROUPS",
//             style: TextStyle(
//               color: appBarColour,
//               fontSize: width * 0.07,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           actions: const [],
//           centerTitle: true,
//           elevation: 0,
//         ),
//       ),
//       body: SingleChildScrollView(
//         physics: const BouncingScrollPhysics(),
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               FutureBuilder<List<GroupDetails>>(
//                 future: fetchGroups(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return Center(child: CircularProgressIndicator(color: backGroundColourDark));
//                   }
//                   if (snapshot.hasError)
//                     return const Center(child: Text("ERROR"));
//                   return ListView.builder(
//                     padding: const EdgeInsets.only(top: 10),
//                     physics: const NeverScrollableScrollPhysics(),
//                     shrinkWrap: true,
//                     itemCount: snapshot.data!.length,
//                     itemBuilder: (context, index) {
//                       return GestureDetector(
//                         onTap: () {
//                           // Navigator.push(
//                           //   context,
//                           //   MaterialPageRoute(
//                           //     builder: (context) => ConnectToGroupWidget(
//                           //       groupName: snapshot.data![index].groupName,
//                           //       selectedRouter:
//                           //       snapshot.data![index].selectedRouter,
//                           //       selectedSwitches:
//                           //       snapshot.data![index].selectedSwitches,
//                           //     ),
//                           //   ),
//                           // );
//                         },
//                         //child: GroupCard(groupDetails: snapshot.data![index]),
//                         child: Container(),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:bbt_new/view/groups/connect_to_group.dart';
import 'package:bbt_new/widgets/custom/custom_appbar.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../controllers/storage.dart';
import '../../models/group_model.dart';
import '../../widgets/group/group_card.dart';
import 'add_group.dart';

class GroupingPage extends StatefulWidget {
  const GroupingPage({super.key});

  @override
  _GroupingPageState createState() => _GroupingPageState();
}

class _GroupingPageState extends State<GroupingPage> {
  final StorageController _storageController = StorageController();
  final TextEditingController _searchController = TextEditingController();
  List<GroupDetails> _allGroups = [];
  List<GroupDetails> _filteredGroups = [];

  @override
  void initState() {
    super.initState();
    fetchGroups();
  }

  Future<void> fetchGroups() async {
    final groups = await _storageController.readAllGroups();
    setState(() {
      _allGroups = groups;
      _filteredGroups = groups;
    });
  }

  void _filterGroups(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredGroups = _allGroups;
      });
    } else {
      setState(() {
        _filteredGroups = _allGroups
            .where((groupDetails) => groupDetails.groupName
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        height: 100,
        width: 120,
        child: FloatingActionButton.large(
          backgroundColor: appBarColour,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 30, color: backGroundColour),
              Text(
                "Add Group",
                style: TextStyle(
                    fontSize: width * 0.045,
                    fontWeight: FontWeight.bold,
                    color: backGroundColour),
              ),
            ],
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NewGroupInstallationPage(),
              ),
            );
          },
        ),
      ),
      appBar: const PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: CustomAppBar(
            heading: "GROUPS",
          )),
      body: Column(
        children: [
          const SizedBox(height: 15),
          SizedBox(
            height: 45,
            width: width * .8,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Group Name',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: _filterGroups, // Call the filter function
            ),
          ),
          Expanded(
            child: _filteredGroups.isEmpty
                ? const Center(
                    child: Text(
                      'No groups found',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(top: 10),
                    itemCount: _filteredGroups.length,
                    itemBuilder: (context, index) {
                      final groupDetails = _filteredGroups[index];
                      return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ConnectToGroupWidget(
                                          groupName: groupDetails.groupName,
                                          selectedRouter:
                                              groupDetails.selectedRouter,
                                          selectedSwitches:
                                              groupDetails.selectedSwitches,
                                        )));
                          },
                          child: GroupCard(
                            groupDetails: groupDetails,
                          ));
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

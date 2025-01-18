// import 'package:bbt_new/view/connect_to_switch.dart';
// import 'package:bbt_new/view/qr_view.dart';
// import '../constants.dart';
// import '../models/switch_model.dart';
// import 'package:flutter/material.dart';
// import '../controllers/storage.dart';
// import '../widgets/switches_card.dart';
// import 'add_switch.dart';
// import 'gallery_qr.dart';
//
// class SwitchPage extends StatelessWidget {
//   SwitchPage({super.key});
//   final StorageController _storageController = StorageController();
//
//   Future<List<SwitchDetails>> fetchSwitches() async {
//     return _storageController.readSwitches();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     final width = screenSize.width;
//
//     return Scaffold(
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//       floatingActionButton: SizedBox(
//         height: 70,
//         width: 150,
//         child: FloatingActionButton.large(
//           backgroundColor: appBarColour,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               IconButton(
//                 onPressed: () {
//                   Navigator.of(context).push(MaterialPageRoute(
//                     builder: (context) => const QRView(),
//                   ));
//                   // Navigator.push(
//                   //   context,
//                   //   MaterialPageRoute(
//                   //       builder: (context) => const AddNewSwitchesPage()),
//                   // );
//                 },
//                 icon: Icon(Icons.camera_alt_outlined, color: blackColour),
//               ),
//               VerticalDivider(
//                 color: blackColour,
//                 thickness: 2,
//                 endIndent: 20,
//                 indent: 20,
//               ),
//               IconButton(
//                 onPressed: () {
//                   Navigator.of(context).push(MaterialPageRoute(
//                     builder: (context) => const GalleryQRPage(),
//                   ));
//                 },
//                 icon: Icon(Icons.image_outlined, color: blackColour),
//               ),
//             ],
//           ),
//           onPressed: () {},
//         ),
//       ),
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(60),
//         child: AppBar(
//           iconTheme: IconThemeData(color: appBarColour),
//           backgroundColor: backGroundColour,
//           automaticallyImplyLeading: false,
//           title: Text(
//             "SWITCHES",
//             style: TextStyle(
//               color: appBarColour,
//               fontSize: width * 0.07,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           centerTitle: true,
//           elevation: 0,
//         ),
//       ),
//       body: SingleChildScrollView(
//         physics: const BouncingScrollPhysics(),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             FutureBuilder<List<SwitchDetails>>(
//               future: fetchSwitches(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Center(
//                     child: CircularProgressIndicator(
//                       color: backGroundColourDark,
//                     ),
//                   );
//                 }
//                 if (snapshot.hasError) {
//                   return Text(
//                     'Error: ${snapshot.error}',
//                   );
//                 }
//                 return ListView.builder(
//                   padding: const EdgeInsets.only(top: 10),
//                   physics: const NeverScrollableScrollPhysics(),
//                   shrinkWrap: true,
//                   itemCount: snapshot.data?.length,
//                   itemBuilder: (context, index) {
//                     return GestureDetector(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => ConnectToSwitchPage(
//                               switchDetails: snapshot.data![index],
//                             ),
//                           ),
//                         );
//                       },
//                       child: SwitchCard(switchDetails: snapshot.data![index]),
//                     );
//                   },
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:bbt_new/view/qr/qr_view.dart';
import 'package:bbt_new/view/switches/connect_to_switch.dart';
import 'package:bbt_new/widgets/custom/custom_appbar.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../controllers/storage.dart';
import '../../models/switch_model.dart';
import '../../widgets/switches/switches_card.dart';
import '../qr/gallery_qr.dart';

class SwitchPage extends StatefulWidget {
  const SwitchPage({super.key});

  @override
  _SwitchPageState createState() => _SwitchPageState();
}

class _SwitchPageState extends State<SwitchPage> {
  final StorageController _storageController = StorageController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<SwitchDetails> _allSwitches = [];
  List<SwitchDetails> _filteredSwitches = [];
  bool _isFabVisible = true;

  @override
  void initState() {
    super.initState();
    fetchSwitches();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent) {
        if (_isFabVisible) {
          setState(() {
            _isFabVisible = false;
          });
        }
      } else {
        if (!_isFabVisible) {
          setState(() {
            _isFabVisible = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchSwitches() async {
    final switches = await _storageController.readSwitches();
    setState(() {
      _allSwitches = switches;
      _filteredSwitches = switches;
    });
  }

  void _filterSwitches(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredSwitches = _allSwitches;
      });
    } else {
      setState(() {
        _filteredSwitches = _allSwitches
            .where((switchDetails) => switchDetails.switchSSID
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
      floatingActionButton: Visibility(
        visible: _isFabVisible,
        child: SizedBox(
          height: 70,
          width: 150,
          child: FloatingActionButton.large(
            backgroundColor: appBarColour,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const QRView(),
                    ));
                  },
                  icon: Icon(Icons.camera_alt_outlined, color: blackColour),
                ),
                VerticalDivider(
                  color: blackColour,
                  thickness: 2,
                  endIndent: 20,
                  indent: 20,
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const GalleryQRPage(),
                    ));
                  },
                  icon: Icon(Icons.image_outlined, color: blackColour),
                ),
              ],
            ),
            onPressed: () {},
          ),
        ),
      ),
      appBar: const PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: CustomAppBar(
            heading: "SWITCHES",
          )),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: SizedBox(
              height: 45,
              width: width * .8,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search Switch',
                  prefixIcon: const Icon(Icons.search_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: _filterSwitches,
              ),
            ),
          ),
          Expanded(
            child: _filteredSwitches.isEmpty
                ? const Center(
                    child: Text(
                      'No switches found',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    controller:
                        _scrollController, // Attach the scroll controller
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(top: 10),
                    itemCount: _filteredSwitches.length,
                    itemBuilder: (context, index) {
                      final switchDetails = _filteredSwitches[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ConnectToSwitchPage(
                                switchDetails: switchDetails,
                              ),
                            ),
                          );
                        },
                        child: SwitchCard(switchDetails: switchDetails),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

import 'package:bbt_new/view/routers/connect_to_router.dart';
import 'package:bbt_new/widgets/custom/custom_appbar.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../controllers/storage.dart';
import '../../models/router_model.dart';
import '../../widgets/router/router_card.dart';
import 'add_router.dart';

class RouterPage extends StatefulWidget {
  const RouterPage({super.key});

  @override
  _RouterPageState createState() => _RouterPageState();
}

class _RouterPageState extends State<RouterPage> {
  final StorageController _storageController = StorageController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<RouterDetails> _allRouters = [];
  List<RouterDetails> _filteredRouters = [];
  bool _isFabVisible = true;

  @override
  void initState() {
    super.initState();
    fetchRouters();
    _scrollController.addListener(_handleScroll);
  }

  Future<void> fetchRouters() async {
    final routers = await _storageController.readRouters();
    setState(() {
      _allRouters = routers;
      _filteredRouters = routers;
    });
  }

  void _filterRouters(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredRouters = _allRouters;
      });
    } else {
      setState(() {
        _filteredRouters = _allRouters
            .where((routerDetails) => routerDetails.routerName
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  void _handleScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 20) {
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
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _isFabVisible
          ? SizedBox(
              height: 100,
              width: 120,
              child: FloatingActionButton.large(
                backgroundColor: appBarColour,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 30, color: blackColour),
                    Text(
                      "Add Router",
                      style: TextStyle(
                          fontSize: width * 0.045,
                          fontWeight: FontWeight.w600,
                          color: blackColour),
                    )
                  ],
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddNewRouterPage(
                        isFromSwitch: false,
                      ),
                    ),
                  );
                },
              ),
            )
          : null,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: CustomAppBar(
          heading: 'ROUTERS',
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: SizedBox(
              height: 45,
              width: width * .8,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search Switch',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: _filterRouters,
              ),
            ),
          ),
          Expanded(
            child: _filteredRouters.isEmpty
                ? const Center(
                    child: Text(
                      'No routers found',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(top: 10),
                    itemCount: _filteredRouters.length,
                    itemBuilder: (context, index) {
                      final routerDetails = _filteredRouters[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ConnectToRouterPage(
                                routerDetails: routerDetails,
                              ),
                            ),
                          );
                        },
                        child: RouterCard(routerDetails: routerDetails),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

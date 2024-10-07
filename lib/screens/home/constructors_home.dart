import 'dart:async';
import 'package:flutter/material.dart';
import 'package:food_bricks/services/odoo_service.dart';
import 'package:food_bricks/screens/home/home.dart';

class constructorsHome extends StatefulWidget {
  final String? selectedRestaurant;
  final String? selectedRestaurantId;
  final Function(String, String) setSelectedRestaurant;
  final Map<dynamic, dynamic>? clientData;

  const constructorsHome({
    Key? key,
    required this.selectedRestaurant,
    required this.selectedRestaurantId,
    required this.clientData,
    required this.setSelectedRestaurant,
  }) : super(key: key);

  @override
  _constructorsHomeState createState() => _constructorsHomeState();
}

class _constructorsHomeState extends State<constructorsHome> {
  final OdooService odooService = OdooService('https://evo.migom.cloud');
  // final OdooService odooService = OdooService('http://192.168.100.38:8069');
  // final OdooService odooService = OdooService('http://127.0.0.1:8069');

  dynamic sessionId = '';
  dynamic constructors = [];
  dynamic restaurants = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSessionAndData();
    print('Constructors widget initialized!');
    print('clientData: ${widget.clientData}');
  }

  Future<void> _fetchOdooSession() async {
    try {
      sessionId = await odooService.fetchSessionId();
      print('Fetched session id: $sessionId');
    } catch (e) {
      print('Error fetching: $e');
    }
  }

  Future<void> _fetchSessionAndData() async {
    setState(() {
      isLoading =
          true; // Set loading state to true when fetching data for refreshing
    });
    try {
      await _fetchOdooSession();
      final fetchedConstructors = await odooService.fetchConstructors(
          sessionId, widget.selectedRestaurantId);
      final fetchedRestaurants = await odooService.fetchRestaurants(sessionId);
      setState(() {
        constructors = fetchedConstructors;
        restaurants = fetchedRestaurants;
        isLoading = false;

        // Set the first restaurant as default if none is selected
        if (widget.selectedRestaurant == null ||
            widget.selectedRestaurant!.isEmpty) {
          final firstRestaurant =
              fetchedRestaurants.isNotEmpty ? fetchedRestaurants.first : null;
          if (firstRestaurant != null) {
            final selectedRestaurant = firstRestaurant['name'];
            final selectedRestaurantId = firstRestaurant['identifier'];

            widget.setSelectedRestaurant(
                selectedRestaurant, selectedRestaurantId);
          }
        }
      });
      print('Fetched constructors: $constructors');
      print('-----------------------------------');
      print('Fetched restaurants: $restaurants');
    } catch (e) {
      setState(() {});
      print('Error fetching constructors: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBar(
          title: isLoading
              ? const Text("Loading...",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18))
              : const Padding(
                  padding: EdgeInsets.only(
                      top: 14), // Add padding to shift title down
                  child: Text(
                    'Dish planner',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
          // : DropdownButton<String>(
          //     value: widget.selectedRestaurant,
          //     hint: const Text(
          //       "Select Restaurant",
          //       style: TextStyle(
          //           color: Colors.white,
          //           fontWeight: FontWeight.bold,
          //           fontSize: 18),
          //     ),
          //     items: restaurants.map<DropdownMenuItem<String>>((restaurant) {
          //       return DropdownMenuItem<String>(
          //         value: restaurant['name'],
          //         child: Text(
          //           restaurant['name'],
          //           style: const TextStyle(color: Colors.white), // White text
          //         ),
          //       );
          //     }).toList(),
          //     onChanged: (String? newValue) {
          //       final selectedRestaurantId = restaurants.firstWhere(
          //           (restaurant) =>
          //               restaurant['name'] == newValue)['identifier'];
          //       widget.setSelectedRestaurant(newValue!, selectedRestaurantId);
          //       _fetchSessionAndData();
          //     },
          //     dropdownColor: Colors.blue[500],
          //   ),
          backgroundColor: Colors.blue[500],
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              color: Colors.white,
              onPressed:
                  _fetchSessionAndData, // Refresh the orders when pressed
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : constructors.isEmpty
              ? const Center(child: Text('No constructors found'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: constructors.length,
                    itemBuilder: (context, index) {
                      final constructor = constructors[index];
                      return GestureDetector(
                        onTap: () {
                          if (widget.selectedRestaurantId != null) {
                            // If restaurant is selected, proceed to constructor widget
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Home(
                                    constructorId: constructor['identifier'],
                                    constructorName: constructor['name'],
                                    clientData: widget.clientData,
                                    restaurantId: widget.selectedRestaurantId!,
                                    selectedRestaurant:
                                        widget.selectedRestaurant!),
                              ),
                            );
                          } else {
                            // If no restaurant selected, show popup
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  content: const Text(
                                      "You have to select a restaurant first."),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text("OK"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          elevation: 4.0,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              constructor['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

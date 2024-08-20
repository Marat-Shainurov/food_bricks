import 'dart:async';
import 'package:flutter/material.dart';
import 'package:food_bricks/services/odoo_service.dart';
import 'package:food_bricks/screens/home/home.dart';
import 'package:food_bricks/screens/plan/plan_home.dart';

class constructorsHome extends StatefulWidget {
  const constructorsHome({super.key});

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
    print('Constructors widget initialized!');
    _fetchSessionAndData();
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
      final fetchedConstructors =
          await odooService.fetchConstructors(sessionId);
      final fetchedRestaurants = await odooService.fetchRestaurants(sessionId);
      setState(() {
        constructors = fetchedConstructors;
        restaurants = fetchedRestaurants;
        isLoading = false;
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
      appBar: AppBar(
        title: const Text("Power Station",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[500],
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            color: Colors.white,
            onPressed: _fetchSessionAndData, // Refresh the orders when pressed
          ),
        ],
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Home(
                                constructorId:
                                    constructor['identifier'] as String,
                                constructorName: constructor['name'] as String,
                              ),
                            ),
                          );
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

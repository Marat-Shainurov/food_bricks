import 'dart:async';
import 'package:flutter/material.dart';
import 'package:food_bricks/services/odoo_service.dart';
import 'package:food_bricks/screens/home/home.dart';

class constructorsHome extends StatefulWidget {
  const constructorsHome({super.key});

  @override
  _constructorsHomeState createState() => _constructorsHomeState();
}

class _constructorsHomeState extends State<constructorsHome> {
  final OdooService odooService = OdooService('https://evo.migom.cloud');

  dynamic sessionId = '';
  dynamic constructors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    print('Constructors widget initialized!');
    _fetchSessionAndConstructors();
  }

  Future<void> _fetchOdooSession() async {
    try {
      sessionId = await odooService.fetchSessionId();
      print('Fetched session id: $sessionId');
    } catch (e) {
      print('Error fetching: $e');
    }
  }

  Future<void> _fetchSessionAndConstructors() async {
    setState(() {
      isLoading =
          true; // Set loading state to true when fetching data for refreshing
    });
    try {
      await _fetchOdooSession();
      final fetchedConstructors =
          await odooService.fetchConstructors(sessionId);
      setState(() {
        constructors = fetchedConstructors;
        isLoading = false;
      });
      print('Fetched constructors: $constructors');
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
            onPressed:
                _fetchSessionAndConstructors, // Refresh the orders when pressed
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
                    itemCount: constructors.length + 1, // +1 for the extra card
                    itemBuilder: (context, index) {
                      // First card: "Daily Plan" (non-clickable)
                      if (index == 0) {
                        return const Card(
                          margin: EdgeInsets.only(bottom: 16.0),
                          elevation: 4.0,
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'Daily plan',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      // Remaining cards: constructor names (clickable)
                      final constructor =
                          constructors[index - 1]; // Adjust index
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

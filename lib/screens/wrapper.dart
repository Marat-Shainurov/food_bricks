import 'package:flutter/material.dart';
import 'package:food_bricks/screens/plan/plan_home.dart';
import 'package:food_bricks/screens/home/constructors_home.dart';
import 'package:food_bricks/screens/user_profile/profile_login.dart';
import 'package:food_bricks/services/odoo_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_bricks/services/firestore_service.dart';

class Wrapper extends StatefulWidget {
  final String? selectedRestaurant;
  final String? selectedRestaurantId;
  final String? userPhone;
  final Map? clientData;

  const Wrapper(
      {Key? key,
      this.selectedRestaurant,
      this.selectedRestaurantId,
      this.userPhone,
      this.clientData})
      : super(key: key);

  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  int _selectedIndex = 0;

  String? selectedRestaurant;
  String? selectedRestaurantId;
  String? userPhone;
  Map? clientData;
  dynamic sessionId = '';
  DocumentSnapshot? activeOrder; // For tracking the active order
  bool showOrderBar = false; // Flag to show/hide the order notification bar
  bool isOrderDone = false; // Track if the order is marked as "Done"
  int? activeOrdersNumber;

  final OdooService odooService = OdooService('https://evo.migom.cloud');
  // final OdooService odooService = OdooService('http://192.168.100.38:8069');
  // final OdooService odooService = OdooService('http://127.0.0.1:8069');

  @override
  void initState() {
    super.initState();
    _checkUserLogin();

    selectedRestaurant = widget.selectedRestaurant;
    selectedRestaurantId = widget.selectedRestaurantId;
    userPhone = widget.userPhone;
    clientData = widget.clientData ?? {};

    _monitorActiveOrder(); // Start monitoring active orders
  }

  Future<void> _checkUserLogin() async {
    final user = FirebaseAuth.instance.currentUser; // Check current user
    print(
        'FirebaseAuth.instance.currentUser: ${FirebaseAuth.instance.currentUser}');
    if (user != null) {
      sessionId = await odooService.fetchSessionId();
      if (user.phoneNumber != null) {
        // Use setState to update userPhone and clientData
        setState(() {
          userPhone = user.phoneNumber; // Update userPhone
        });
        clientData = await odooService.getOrCreateOdooClient(
            sessionId, userPhone!); // Update clientData
        setState(() {
          clientData = clientData;
        });
        print('user.phoneNumber: ${user.phoneNumber}');
        print('userPhone: $userPhone');
        print('clientData: $clientData');
      } else {
        print('No phone number found for the current user.');
      }
    }
  }

  // Monitor the active order (status != "Done") in real-time
  void _monitorActiveOrder() {
    getActiveOrders().listen((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          activeOrdersNumber = snapshot.docs.length;
          activeOrder = snapshot.docs.first;
          showOrderBar = true;
          isOrderDone = false;
        });
      } else {
        setState(() {
          showOrderBar = false;
        });
      }
    });
  }

  // List of widgets to display for each tab
  List<Widget> _widgetOptions(BuildContext context) => <Widget>[
        Plan(
            clientData: clientData,
            selectedRestaurant: selectedRestaurant,
            selectedRestaurantId: selectedRestaurantId),
        constructorsHome(
          selectedRestaurant: selectedRestaurant,
          selectedRestaurantId: selectedRestaurantId,
          clientData: clientData,
          setSelectedRestaurant: (restaurant, restaurantId) {
            setState(() {
              selectedRestaurant = restaurant;
              selectedRestaurantId = restaurantId;
            });
          },
        ),
        UserProfile(
          selectedRestaurant: selectedRestaurant,
          selectedRestaurantId: selectedRestaurantId,
          userPhone: userPhone,
          clientData: clientData,
          odooService: odooService,
          setClientData: (data) {
            setState(() {
              clientData = data;
            });
          },
          setUserPhone: (phone) {
            setState(() {
              userPhone = phone;
            });
          },
          setSelectedRestaurant: (restaurant, restaurantId) {
            setState(() {
              selectedRestaurant = restaurant;
              selectedRestaurantId = restaurantId;
            });
          },
        ), // Constructors widget
      ];

  // Handle the "Ok" button for closing the order notification bar
  void _dismissOrderBar() {
    setState(() {
      showOrderBar = false;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _widgetOptions(context)[_selectedIndex],
          if (showOrderBar && activeOrder != null)
            SafeArea(
              child: Container(
                color: isOrderDone ? Colors.green : Colors.yellow[800],
                padding: const EdgeInsets.all(0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Active Orders - $activeOrdersNumber',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Planner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Constructors',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile', // New tab for User Profile
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue[500],
        onTap: _onItemTapped,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:food_bricks/screens/plan/plan_home.dart';
import 'package:food_bricks/screens/home/constructors_home.dart';
import 'package:food_bricks/screens/user_profile/profile_login.dart';
import 'package:food_bricks/services/odoo_service.dart';

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

  final OdooService odooService = OdooService('https://evo.migom.cloud');
  // final OdooService odooService = OdooService('http://192.168.100.38:8069');
  // final OdooService odooService = OdooService('http://127.0.0.1:8069');

  @override
  void initState() {
    super.initState();

    // Initialize state from widget if data is passed in
    selectedRestaurant = widget.selectedRestaurant;
    selectedRestaurantId = widget.selectedRestaurantId;
    userPhone = widget.userPhone;
    clientData = widget.clientData ?? {};
  }

  // List of widgets to display for each tab
  List<Widget> _widgetOptions(BuildContext context) => <Widget>[
        Plan(clientData: clientData), // Planner widget
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
        ), // Constructors widget
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions(
          context)[_selectedIndex], // Display the selected widget
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

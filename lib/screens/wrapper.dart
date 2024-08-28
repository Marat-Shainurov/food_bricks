import 'package:flutter/material.dart';
import 'package:food_bricks/screens/plan/plan_home.dart';
import 'package:food_bricks/screens/home/constructors_home.dart';
import 'package:food_bricks/screens/user_profile/profile_login.dart';

class Wrapper extends StatefulWidget {
  final String? selectedRestaurant;
  final String? selectedRestaurantId;
  final String? userPhone;

  const Wrapper(
      {Key? key,
      this.selectedRestaurant,
      this.selectedRestaurantId,
      this.userPhone})
      : super(key: key);

  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  int _selectedIndex = 0;

  String? selectedRestaurant;
  String? selectedRestaurantId;
  String? userPhone;

  @override
  void initState() {
    super.initState();

    // Initialize state from widget if data is passed in
    selectedRestaurant = widget.selectedRestaurant;
    selectedRestaurantId = widget.selectedRestaurantId;
    userPhone = widget.userPhone;
  }

  // List of widgets to display for each tab
  List<Widget> _widgetOptions(BuildContext context) => <Widget>[
        const Plan(), // Planner widget
        constructorsHome(
          selectedRestaurant: selectedRestaurant,
          selectedRestaurantId: selectedRestaurantId,
          setSelectedRestaurant: (restaurant, restaurantId) {
            setState(() {
              selectedRestaurant = restaurant;
              selectedRestaurantId = restaurantId;
            });
          },
        ),
        UserProfile(
          userPhone: userPhone,
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

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:food_bricks/services/odoo_service.dart';
import 'package:food_bricks/services/utils.dart';
import 'package:horizontal_picker/horizontal_picker.dart';
import 'package:food_bricks/screens/solutions/solutions.dart';

class Home extends StatefulWidget {
  final String constructorId;
  final String constructorName;
  final String restaurantId;
  final String selectedRestaurant;

  const Home(
      {super.key,
      required this.constructorId,
      required this.constructorName,
      required this.restaurantId,
      required this.selectedRestaurant});

  @override
  _HomeState createState() => _HomeState();
}

enum MacronutrientProportion { option1, option2 }

class _HomeState extends State<Home> {
  final OdooService odooService = OdooService('https://evo.migom.cloud');
  // final OdooService odooService = OdooService('http://192.168.100.38:8069');
  // final OdooService odooService = OdooService('http://127.0.0.1:8069');
  dynamic sessionId = '';
  dynamic solutions = [];
  double caloriesLimit = 500.0;
  double proteins = 15.0;
  double carbs = 50.0;
  double fats = 35.0;
  MacronutrientProportion? _selectedProportion =
      MacronutrientProportion.option1;
  Utils utils = Utils();

  @override
  void initState() {
    super.initState();
    print('Home widget initialized!');
    _fetchOdooSession();
  }

  Future<void> _fetchOdooSession() async {
    try {
      sessionId = await odooService.fetchSessionId();
      print('Fetched session id: $sessionId');
    } catch (e) {
      print('Error fetching: $e');
    }
  }

  void _handleProportionChange(MacronutrientProportion? value) {
    setState(() {
      _selectedProportion = value;
      if (value == MacronutrientProportion.option1) {
        proteins = 15.0;
        carbs = 50.0;
        fats = 35.0;
      } else if (value == MacronutrientProportion.option2) {
        proteins = 30.0;
        carbs = 40.0;
        fats = 30.0;
      }
    });
  }

  Future<void> _onNextPressed() async {
    // Show loader dialog
    utils.showLoaderDialog(context);

    try {
      Map<String, dynamic> data = {
        "caloriesLimit": caloriesLimit.toString(),
        "proteins": proteins.toString(),
        "carbs": carbs.toString(),
        "fats": fats.toString(),
        "constructor_id": widget.constructorId
      };

      if (sessionId == null) {
        print('Session ID is not available');
        Navigator.pop(context); // Close the loader
        return;
      }

      final fetchedSolutions =
          await odooService.fetchRecipeSolutions(sessionId, data);

      // Close the loader once the request is complete
      Navigator.pop(context);

      if (fetchedSolutions.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SolutionsGrid(
              solutions: fetchedSolutions,
              odooService: odooService,
              constructorId: widget.constructorId,
              restaurantId: widget.restaurantId,
              selectedRestaurant: widget.selectedRestaurant,
            ),
          ),
        );
      } else {
        print('No solutions found');
      }
    } catch (e) {
      // Close the loader in case of error
      Navigator.pop(context);
      print('Error fetching solutions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.constructorName,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[500],
        centerTitle: true,
        // actions: [],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    const Text(
                      'Select Your Calories Limit',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    HorizontalPicker(
                      minValue: 200,
                      maxValue: 800,
                      divisions: (800 - 200) ~/ 50,
                      height: 120,
                      suffix: " kcal",
                      showCursor: true,
                      backgroundColor: Colors.grey.shade200,
                      activeItemTextColor: Colors.blue.shade800,
                      passiveItemsTextColor: Colors.grey.shade500,
                      onChanged: (value) {
                        setState(() {
                          caloriesLimit = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Nutrients Proportion',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Radio<MacronutrientProportion>(
                          value: MacronutrientProportion.option1,
                          groupValue: _selectedProportion,
                          onChanged: _handleProportionChange,
                          activeColor: Colors.blue[500],
                        ),
                        const Text(
                          'Carbs 50%   Fats 35%   Proteins 15%',
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Radio<MacronutrientProportion>(
                          value: MacronutrientProportion.option2,
                          groupValue: _selectedProportion,
                          onChanged: _handleProportionChange,
                          activeColor: Colors.blue[500],
                        ),
                        const Text(
                          'Carbs 40%   Fats 30%   Proteins 30%',
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _onNextPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[500],
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 12.0),
                  ),
                  child: const Text('Next',
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

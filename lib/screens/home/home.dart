import 'dart:async';
import 'package:flutter/material.dart';
import 'package:food_bricks/services/odoo_service.dart';
import 'package:horizontal_picker/horizontal_picker.dart';
import 'package:food_bricks/screens/solutions/solutions.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

enum MacronutrientProportion { option1, option2 }

class _HomeState extends State<Home> {
  final OdooService odooService = OdooService('https://evo.migom.cloud');
  // final OdooService odooService = OdooService('http://192.168.100.38:8069');

  dynamic sessionId = '';
  dynamic solutions = [];
  double caloriesLimit = 500.0;
  double proteins = 15.0;
  double carbs = 50.0;
  double fats = 35.0;
  MacronutrientProportion? _selectedProportion =
      MacronutrientProportion.option1;

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

  void _showLoaderDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent closing the dialog by tapping outside
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Loading..."),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _onNextPressed() async {
    // Show loader dialog
    _showLoaderDialog(context);

    try {
      Map<String, dynamic> data = {
        "caloriesLimit": caloriesLimit.toString(),
        "proteins": proteins.toString(),
        "carbs": carbs.toString(),
        "fats": fats.toString(),
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
        title: const Text(
          "Food Bricks",
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
              ElevatedButton(
                onPressed: _onNextPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[500],
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 12.0),
                ),
                child: const Text('Next',
                    style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

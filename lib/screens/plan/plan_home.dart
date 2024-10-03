import 'dart:async';
import 'package:flutter/material.dart';
import 'package:food_bricks/services/odoo_service.dart';
import 'package:horizontal_picker/horizontal_picker.dart';
import 'package:food_bricks/services/utils.dart';
import 'package:food_bricks/screens/plan/plan_strategies.dart';

class Plan extends StatefulWidget {
  final Map<dynamic, dynamic>? clientData;
  final String? selectedRestaurant;
  final String? selectedRestaurantId;

  const Plan(
      {Key? key,
      required this.clientData,
      required this.selectedRestaurant,
      required this.selectedRestaurantId})
      : super(key: key);

  @override
  _PlanState createState() => _PlanState();
}

enum PlanMacronutrientProportion { option1, option2 }

class _PlanState extends State<Plan> {
  final OdooService odooService = OdooService('https://evo.migom.cloud');
  final Utils utils = Utils();
  // final OdooService odooService = OdooService('http://192.168.100.38:8069');
  // final OdooService odooService = OdooService('http://127.0.0.1:8069');

  dynamic sessionId = '';
  dynamic strategies = [];
  double? caloriesLimit;
  double proteins = 15.0;
  double carbs = 50.0;
  double fats = 35.0;
  PlanMacronutrientProportion? _selectedPlanProportion =
      PlanMacronutrientProportion.option1;

  void _handleCaloriesChange(double value) {
    setState(() {
      caloriesLimit = value;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchOdooSession();

    // Ensure the value is parsed as double if it comes as a String
    if (widget.clientData != null &&
        widget.clientData!["daily_calories"] != null) {
      caloriesLimit =
          double.tryParse(widget.clientData!["daily_calories"].toString()) ??
              2200.0;
    } else {
      caloriesLimit = 2200.0;
    }

    // Set initial value for the HorizontalPicker
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleCaloriesChange(caloriesLimit!);
    });

    print('Plan home widget initialized!');
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

  void _handleProportionChange(PlanMacronutrientProportion? value) {
    setState(() {
      _selectedPlanProportion = value;
      if (value == PlanMacronutrientProportion.option1) {
        proteins = 15.0;
        carbs = 50.0;
        fats = 35.0;
      } else if (value == PlanMacronutrientProportion.option2) {
        proteins = 30.0;
        carbs = 40.0;
        fats = 30.0;
      }
    });
  }

  Future<void> _onNextPressed() async {
    // Show loader dialog
    utils.showLoaderDialog(context);

    final phoneNumber = widget.clientData?['identifier'] ?? '';
    try {
      Map<String, dynamic> data = {
        "caloriesLimit": caloriesLimit.toString(),
        "proteins": proteins.toString(),
        "carbs": carbs.toString(),
        "fats": fats.toString(),
        "client_phone": phoneNumber
      };

      if (sessionId == null) {
        print('Session ID is not available');
        // Navigator.pop(context); // Close the loader
        return;
      }

      final fetchedStrategies =
          await odooService.fetchStrategies(sessionId, data);

      // Close the loader once the request is complete
      Navigator.pop(context);

      if (fetchedStrategies.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StrategiesGrid(
                strategies: fetchedStrategies,
                odooService: odooService,
                selectedRestaurant: widget.selectedRestaurant,
                selectedRestaurantId: widget.selectedRestaurantId,
                clientData: widget.clientData),
          ),
        );
      } else {
        print('No plan versions found');
      }
    } catch (e) {
      // Close the loader in case of error
      Navigator.pop(context);
      print('Error fetching plan versions: $e');
    }
  }

  Widget _buildInfoCard(String title, dynamic value) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style:
                  const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(
              value.toString(),
              style: const TextStyle(fontSize: 16.0),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final diets = widget.clientData?['diets'] ?? [];
    final stoppers = widget.clientData?['do_not_eat'] ?? [];
    final dailyCalories = caloriesLimit;
    final mealsPerDay =
        widget.clientData?['meals_per_day']?.toString() ?? 'Not set yet';
    final eatsSnacks = widget.clientData?['eats_snacks'] != null
        ? (widget.clientData!['eats_snacks'] ? 'Yes' : 'No')
        : 'Not set yet';
    final eatsDesserts = widget.clientData?['eats_desserts'] != null
        ? (widget.clientData!['eats_desserts'] ? 'Yes' : 'No')
        : 'Not set yet';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daily Plan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[500],
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      'Select Your Calories Limit',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Horizontal Picker centered
                    Center(
                      child: HorizontalPicker(
                        minValue: 1200,
                        maxValue: 3200,
                        divisions: (3200 - 1200) ~/ 100,
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
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Nutrients Proportion',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Radio<PlanMacronutrientProportion>(
                          value: PlanMacronutrientProportion.option1,
                          groupValue: _selectedPlanProportion,
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
                        Radio<PlanMacronutrientProportion>(
                          value: PlanMacronutrientProportion.option2,
                          groupValue: _selectedPlanProportion,
                          onChanged: _handleProportionChange,
                          activeColor: Colors.blue[500],
                        ),
                        const Text(
                          'Carbs 40%   Fats 30%   Proteins 30%',
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'User preferences',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    // User Info Cards
                    const SizedBox(height: 20),
                    _buildInfoCard(
                      'Diets',
                      diets.isEmpty ? 'Not set yet' : diets.join(', '),
                    ),
                    const SizedBox(height: 20),
                    _buildInfoCard(
                      "Don't eat",
                      stoppers.isEmpty ? 'Not set yet' : stoppers.join(', '),
                    ),
                    const SizedBox(height: 20),
                    _buildInfoCard('Daily Calories Intake', dailyCalories),
                    const SizedBox(height: 20),
                    _buildInfoCard('Meals Per Day', mealsPerDay),
                    const SizedBox(height: 20),
                    _buildInfoCard('Eats Snacks', eatsSnacks),
                    const SizedBox(height: 20),
                    _buildInfoCard('Eats Desserts', eatsDesserts),
                  ],
                ),
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
    );
  }
}

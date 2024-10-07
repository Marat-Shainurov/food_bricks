import 'package:flutter/material.dart';
import 'package:food_bricks/services/auth_service.dart';
import 'package:telephony/telephony.dart';
import 'package:food_bricks/services/odoo_service.dart';
import 'package:food_bricks/screens/wrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile extends StatefulWidget {
  final String? selectedRestaurant;
  final String? selectedRestaurantId;
  final Function(String, String) setSelectedRestaurant;
  final String? userPhone;
  final Function(String) setUserPhone;
  final Function(Map) setClientData;
  final Map<dynamic, dynamic>? clientData;
  final OdooService odooService;

  const UserProfile(
      {Key? key,
      this.userPhone,
      required this.setUserPhone,
      required this.setClientData,
      this.selectedRestaurant,
      this.selectedRestaurantId,
      required this.setSelectedRestaurant,
      this.clientData,
      required this.odooService})
      : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _mealsPerDayController = TextEditingController();

  final Telephony telephony = Telephony.instance;

  final _formKey = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();
  bool isLoading = true;

  dynamic sessionId = '';
  Map clientDataOdoo = {};
  List<dynamic> availableDiets = [];
  List<dynamic> availableIngredients = [];
  dynamic restaurants = [];
  String? _selectedRestaurant;
  String? _selectedRestaurantId;
  bool _isRestaurantSet = false;

  Future<void> _logout() async {
    await AuthService.logout();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Wrapper(
          selectedRestaurant: widget.selectedRestaurant,
          selectedRestaurantId: widget.selectedRestaurantId,
          userPhone: null, // Clear userPhone
          clientData: {}, // Clear client data
        ),
      ),
    );
  }

  void listenToIncomingSMS(BuildContext context) {
    print("Listening to sms.");
    telephony.listenIncomingSms(
        onNewMessage: (SmsMessage message) {
          // Handle message
          print("sms received : ${message.body}");
          // verify if we are reading the correct sms or not

          if (message.body!.contains("phone-auth-15bdb")) {
            String otpCode = message.body!.substring(0, 6);
            setState(() {
              _otpController.text = otpCode;
              // wait for 1 sec and then press handle submit
              Future.delayed(Duration(seconds: 1), () {
                handleSubmit(context);
              });
            });
          }
        },
        listenInBackground: false);
  }

  // handle after otp is submitted
  void handleSubmit(BuildContext context) {
    if (_formKey1.currentState!.validate()) {
      AuthService.loginWithOtp(
              otp: _otpController.text, phone: _phoneController.text)
          .then((value) {
        if (value == "Success") {
          setState(() {
            widget.setUserPhone(_phoneController.text);
          });
          _fetchAndSetOdooClient();
          Navigator.pop(context);
        } else {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              value,
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ));
        }
      });
    }
  }

  Future<void> _fetchOdooSession() async {
    try {
      sessionId = await widget.odooService.fetchSessionId();
      print('Fetched session id: $sessionId');
    } catch (e) {
      print('Error fetching: $e');
    }
  }

  Future<void> _fetchAndSetOdooClient() async {
    try {
      clientDataOdoo = await widget.odooService
          .getOrCreateOdooClient(sessionId, _phoneController.text);
      print('Fetched client: $clientDataOdoo');
      widget.setClientData(clientDataOdoo);
    } catch (e) {
      print('Error fetching client: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.userPhone != null) {
      _phoneController.text = widget.userPhone!;
    }
    _fetchOdooSession();
    _fetchWidgetData();
    _loadSelectedRestaurant();
    if (widget.userPhone != null) {
      _phoneController.text = widget.userPhone!;
    }
    print('User profile widget initialized!');
    print('clientData: ${widget.clientData}');
  }

  Future<void> _loadSelectedRestaurant() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRestaurant = prefs.getString('selectedRestaurant');
    final savedRestaurantId = prefs.getString('selectedRestaurantId');

    if (savedRestaurant != null && savedRestaurantId != null) {
      setState(() {
        _selectedRestaurant = savedRestaurant;
        _selectedRestaurantId = savedRestaurantId;
        _isRestaurantSet = true;
      });

      // Notify wrapper of the selected restaurant
      widget.setSelectedRestaurant(
          _selectedRestaurant!, _selectedRestaurantId!);
    }
  }

  Future<void> _fetchWidgetData() async {
    try {
      setState(() {
        isLoading = true;
      });
      sessionId = await widget.odooService.fetchSessionId();
      await _fetchAvailableDiets();
      await _fetchAvailableIngredients();
      await _fetchAvailableRestaurants();
      isLoading = false;
      print('restaurants: $restaurants');
    } catch (e) {
      print('Error fetching Diets and Stoppers: $e');
      isLoading = false;
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchAvailableRestaurants() async {
    try {
      final fetchedRestaurants =
          await widget.odooService.fetchRestaurants(sessionId);
      setState(() {
        restaurants = fetchedRestaurants;
      });
    } catch (e) {
      print('Error fetching available restaurants: $e');
    }
  }

  Future<void> _fetchAvailableDiets() async {
    try {
      availableDiets =
          await widget.odooService.fetchDiets(sessionId, _phoneController.text);
      setState(() {});
    } catch (e) {
      print('Error fetching available diets: $e');
    }
  }

  Future<void> _fetchAvailableIngredients() async {
    try {
      availableIngredients = await widget.odooService
          .fetchIngredientsStoppers(sessionId, _phoneController.text);
      setState(() {});
    } catch (e) {
      print('Error fetching available ingredients: $e');
    }
  }

  void _showRestaurantPopup() {
    String? tempSelectedRestaurant = _selectedRestaurant;
    String? tempSelectedRestaurantId = _selectedRestaurantId;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Select Restaurant'),
              content: DropdownButton<String>(
                value: tempSelectedRestaurant,
                hint: const Text(
                  "Select Restaurant",
                  style: TextStyle(fontSize: 14),
                ),
                items: restaurants.map<DropdownMenuItem<String>>((restaurant) {
                  return DropdownMenuItem<String>(
                    value: restaurant['name'],
                    child: Text(restaurant['name']),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    tempSelectedRestaurant = newValue;
                    final selectedRestaurant = restaurants.firstWhere(
                      (restaurant) => restaurant['name'] == newValue,
                    );
                    tempSelectedRestaurantId = selectedRestaurant['identifier'];
                  });
                },
              ),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    if (tempSelectedRestaurant != null &&
                        tempSelectedRestaurantId != null) {
                      // Save selected restaurant only after 'OK' is pressed
                      _saveSelectedRestaurant(
                          tempSelectedRestaurant!, tempSelectedRestaurantId!);
                      setState(() {
                        _selectedRestaurant = tempSelectedRestaurant;
                        _selectedRestaurantId = tempSelectedRestaurantId;
                      });
                    }
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _saveSelectedRestaurant(
      String restaurantName, String restaurantId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('selectedRestaurant', restaurantName);
    prefs.setString('selectedRestaurantId', restaurantId);

    setState(() {
      _isRestaurantSet = true;
    });

    // Call the wrapper function with both arguments
    widget.setSelectedRestaurant(restaurantName, restaurantId);
  }

  void _showDietPopup(BuildContext context) async {
    if (availableDiets.isEmpty) {
      await _fetchAvailableDiets();
    }

    final currentDiets = widget.clientData?['diets'] ?? [];
    final selectedDiets = List<String>.from(currentDiets);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Diets'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Current Diets:'),
                    ...currentDiets.map((diet) {
                      return CheckboxListTile(
                        title: Text(diet),
                        value: selectedDiets.contains(diet),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              selectedDiets.add(diet);
                            } else {
                              selectedDiets.remove(diet);
                            }
                          });
                        },
                      );
                    }).toList(),
                    const SizedBox(height: 20),
                    const Text('Available Diets:'),
                    ...availableDiets.map((diet) {
                      return CheckboxListTile(
                        title: Text(diet),
                        value: selectedDiets.contains(diet),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              selectedDiets.add(diet);
                            } else {
                              selectedDiets.remove(diet);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Send the newly selected diets to Odoo
                    try {
                      final updatedData = await widget.odooService.updateDiets(
                          sessionId, selectedDiets, widget.userPhone!, "diets");

                      // Update the local state with the new diets
                      setState(() {
                        widget.clientData?['diets'] = selectedDiets;
                      });

                      // Refetch the available diets
                      await _fetchAvailableDiets();

                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Your Diets list has been updated successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );

                      Navigator.pop(context);
                    } catch (e) {
                      print('Error updating diets: $e');
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                          'Failed to update diets.',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                      ));
                    }
                  },
                  child: Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    ).then((selectedDiets) {
      if (selectedDiets != null) {
        setState(() {
          widget.clientData?['diets'] = selectedDiets.toList();
          // Send the updated diets back to the server here if needed.
          print('currentDiets - ${currentDiets}');
          print('selectedDiets - ${selectedDiets}');
        });
      }
    });
  }

  void _showDontEatPopup(BuildContext context) async {
    if (availableIngredients.isEmpty) {
      await _fetchAvailableIngredients();
    }

    final currentStoppers = widget.clientData?['do_not_eat'] ?? [];
    final selectedStoppers = List<String>.from(currentStoppers);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Ingredients stoppers'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Currently Don't eat:"),
                    ...currentStoppers.map((diet) {
                      return CheckboxListTile(
                        title: Text(diet),
                        value: selectedStoppers.contains(diet),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              selectedStoppers.add(diet);
                            } else {
                              selectedStoppers.remove(diet);
                            }
                          });
                        },
                      );
                    }).toList(),
                    const SizedBox(height: 20),
                    const Text('Available ingredients:'),
                    ...availableIngredients.map((diet) {
                      return CheckboxListTile(
                        title: Text(diet),
                        value: selectedStoppers.contains(diet),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              selectedStoppers.add(diet);
                            } else {
                              selectedStoppers.remove(diet);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Send the newly selected diets to Odoo
                    try {
                      final updatedData = await widget.odooService.updateDiets(
                          sessionId,
                          selectedStoppers,
                          widget.userPhone!,
                          'stoppers');

                      // Update the local state with the new diets
                      setState(() {
                        widget.clientData?['do_not_eat'] = selectedStoppers;
                      });

                      // Refetch the available diets
                      await _fetchAvailableIngredients();

                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Ingredients that you do not eat have been updated successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );

                      Navigator.pop(context);
                    } catch (e) {
                      print('Error updating ingredients: $e');
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                          'Failed to update ingredients.',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                      ));
                    }
                  },
                  child: Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    ).then((selectedStoppers) {
      if (selectedStoppers != null) {
        setState(() {
          widget.clientData?['do_not_eat'] = selectedStoppers.toList();
          // Send the updated diets back to the server here if needed.
          print('currentStoppers - ${currentStoppers}');
          print('selectedStoppers - ${selectedStoppers}');
        });
      }
    });
  }

  void _showCaloriesPopup(BuildContext context) {
    final initialCalories = widget.clientData?['daily_calories'] ?? '';
    _caloriesController.text = '${initialCalories}';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Daily Calories Intake'),
          content: TextFormField(
            controller: _caloriesController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter calories',
            ),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Fetch the new daily calories value from the input
                final newCalories = _caloriesController.text;

                // Check if the value has changed
                if (newCalories.isNotEmpty && newCalories != initialCalories) {
                  try {
                    // Call the updateClientField method to update the value on the backend
                    await widget.odooService.updateClientField(
                      sessionId,
                      widget.userPhone!,
                      'daily_calories',
                      newCalories,
                    );

                    // Update the local clientData with the new value
                    setState(() {
                      widget.clientData?['daily_calories'] = newCalories;
                    });

                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Daily Calories setting has been updated successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    // Handle the error, show error message
                    print('Error updating daily calories: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to update daily calories.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
                Navigator.pop(context);
              },
              child: Text('Apply'),
            ),
          ],
        );
      },
    ).then((_) {
      setState(() {
        widget.clientData?['daily_calories'] = _caloriesController.text;
      });
    });
  }

  void _showMealsPerDayPopup(BuildContext context) {
    final initialMealsPerDay = widget.clientData?['meals_per_day'] ?? '';
    _mealsPerDayController.text = '${initialMealsPerDay}';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Meals Per Day'),
          content: TextFormField(
            controller: _mealsPerDayController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter meals per day',
            ),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Fetch the new mealsPerDay value from the input
                final newMealsPerDay = _mealsPerDayController.text;

                // Check if the value has changed
                if (newMealsPerDay.isNotEmpty &&
                    newMealsPerDay != initialMealsPerDay) {
                  try {
                    // Call the updateClientField method to update the value on the backend
                    await widget.odooService.updateClientField(
                      sessionId,
                      widget.userPhone!,
                      'meals_per_day',
                      newMealsPerDay,
                    );

                    // Update the local clientData with the new value
                    setState(() {
                      widget.clientData?['meals_per_day'] = newMealsPerDay;
                    });

                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Meals Per Day setting has been updated successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    // Handle the error, show error message
                    print('Error updating Meals Per Day: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to update Meals per day.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
                Navigator.pop(context);
              },
              child: Text('Apply'),
            ),
          ],
        );
      },
    ).then((_) {
      setState(() {
        widget.clientData?['meals_per_day'] = _mealsPerDayController.text;
      });
    });
  }

  void _showSnacksDessertsPopup(BuildContext context) {
    final initialSnacks = widget.clientData?['eats_snacks'] ?? false;
    final initialDesserts = widget.clientData?['eats_desserts'] ?? false;
    bool snacksSelected = widget.clientData?['eats_snacks'];
    bool dessertsSelected = widget.clientData?['eats_desserts'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Snacks and Desserts"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CheckboxListTile(
                    title: const Text("Eats snacks"),
                    value: snacksSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        snacksSelected = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text("Eats desserts"),
                    value: dessertsSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        dessertsSelected = value!;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Applpy the selections
                bool newSnacksSelected = snacksSelected;
                bool newDessertsSelected = dessertsSelected;

                try {
                  if (newSnacksSelected != initialSnacks) {
                    await widget.odooService.updateClientField(
                      sessionId,
                      widget.userPhone!,
                      'eats_snacks',
                      newSnacksSelected,
                    );
                    setState(() {
                      widget.clientData!['eats_snacks'] = snacksSelected;
                    });
                  }

                  if (newDessertsSelected != initialDesserts) {
                    await widget.odooService.updateClientField(
                      sessionId,
                      widget.userPhone!,
                      'eats_desserts',
                      newDessertsSelected,
                    );
                    setState(() {
                      widget.clientData!['eats_desserts'] = dessertsSelected;
                    });
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Snacks and Desserts setting has been updated successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  print('Error updating Snacks and Desserts: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Failed to update Snacks and Desserts settings.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                Navigator.of(context).pop();
              },
              child: const Text("Apply"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final clientName = widget.clientData?['name'] ?? 'User';
    final diets = widget.clientData?['diets'] ?? [];
    final stoppers = widget.clientData?['do_not_eat'] ?? [];
    final dailyCalories = widget.clientData?['daily_calories'] ?? 'Not set yet';
    final mealsPerDay = widget.clientData?['meals_per_day'] ?? 'Not set yet';
    final eatsSnacks = widget.clientData?['eats_snacks'] ?? null;
    final eatsDesserts = widget.clientData?['eats_desserts'] ?? null;

    print('userPhone: ----- ${widget.userPhone}');
    print('clientData: ----- ${widget.clientData}');

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBar(
          title: Padding(
            padding:
                EdgeInsets.only(top: 14), // Adjust padding to shift title down
            child: Text(
              widget.userPhone != null
                  ? 'Welcome, ${clientName ?? widget.userPhone}'
                  : 'User Profile',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          backgroundColor: Colors.blue[500],
          centerTitle: true,
          actions: [
            if (widget.userPhone != null)
              Padding(
                padding: EdgeInsets.only(top: 14), // Move icon down and right
                child: IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: _logout, // Call the logout method
                  tooltip: 'Logout',
                ),
              ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: widget.userPhone == null || widget.userPhone == ''
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      'Input your phone number',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Form(
                        key: _formKey,
                        child: TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Your phone number',
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value!.length < 12)
                              return 'Invalid phone number!';
                            return null;
                          },
                        )),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            AuthService.sentOtp(
                                phone: _phoneController.text,
                                errorStep: () => ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content: Text(
                                        "Error in sending OTP",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      backgroundColor: Colors.red,
                                    )),
                                nextStep: () {
                                  // start lisenting for otp
                                  listenToIncomingSMS(context);
                                  showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                            title: Text("OTP Verification"),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text("Enter 6 digit OTP"),
                                                const SizedBox(
                                                  height: 12,
                                                ),
                                                Form(
                                                  key: _formKey1,
                                                  child: TextFormField(
                                                    keyboardType:
                                                        TextInputType.number,
                                                    controller: _otpController,
                                                    decoration: InputDecoration(
                                                        labelText:
                                                            "Enter you phone number",
                                                        border: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        32))),
                                                    validator: (value) {
                                                      if (value!.length != 6)
                                                        return "Invalid OTP";
                                                      return null;
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                  onPressed: () =>
                                                      handleSubmit(context),
                                                  child: const Text("Submit"))
                                            ],
                                          ));
                                });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white),
                        child: const Text("Send OTP"),
                      ),
                    )
                  ],
                )
              : isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          _buildRestaurantCard('Restaurant'),
                          const SizedBox(height: 10),
                          buildDietaryCard(
                              'Diets', diets, () => _showDietPopup(context)),
                          const SizedBox(height: 10),
                          buildDietaryCard("Don't eat", stoppers,
                              () => _showDontEatPopup(context)),
                          const SizedBox(height: 10),
                          buildCaloriesMealsCard(
                            'Daily Calories Intake',
                            dailyCalories != 'Not set yet'
                                ? '$dailyCalories cal'
                                : 'Not set yet',
                            () => _showCaloriesPopup(context),
                          ),
                          const SizedBox(height: 10),
                          buildCaloriesMealsCard(
                            'Meals Per day',
                            mealsPerDay != 'Not set yet'
                                ? '$mealsPerDay'
                                : 'Not set yet',
                            () => _showMealsPerDayPopup(context),
                          ),
                          const SizedBox(height: 10),
                          buildSnacksDessertsCard(eatsSnacks, eatsDesserts),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildRestaurantCard(String title) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style:
                  const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_isRestaurantSet ? _selectedRestaurant! : 'Not set yet'),
                ElevatedButton(
                  onPressed: _showRestaurantPopup,
                  child: Text(_isRestaurantSet ? 'Edit' : 'Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDietaryCard(
      String title, List<dynamic> items, VoidCallback onEditPressed) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style:
                  const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            items.isEmpty
                ? ElevatedButton(
                    onPressed: onEditPressed,
                    child: const Text('Add'),
                  )
                : Column(
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 200),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            return Text('${items[index]}');
                          },
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton(
                          onPressed: onEditPressed,
                          child: const Text('Edit'),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget buildCaloriesMealsCard(
      String title, String value, VoidCallback onEditPressed) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style:
                  const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value, style: TextStyle(fontSize: 16.0)),
                ElevatedButton(
                  onPressed: onEditPressed,
                  child: Text(value != 'Not set yet' ? 'Edit' : 'Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSnacksDessertsCard(bool? eatsSnacks, bool? eatsDesserts) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Snacks And Desserts',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Eats snacks: ${eatsSnacks != null ? (eatsSnacks ? 'Yes' : 'No') : 'Not set yet'}',
                      style: const TextStyle(fontSize: 16.0),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Eats desserts: ${eatsDesserts != null ? (eatsDesserts ? 'Yes' : 'No') : 'Not set yet'}',
                      style: const TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => _showSnacksDessertsPopup(context),
                  child: Text(eatsSnacks == null || eatsDesserts == null
                      ? 'Add'
                      : 'Edit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

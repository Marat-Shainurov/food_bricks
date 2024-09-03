import 'package:flutter/material.dart';
import 'package:food_bricks/services/auth_service.dart';
import 'package:telephony/telephony.dart';
import 'package:food_bricks/services/odoo_service.dart';

class UserProfile extends StatefulWidget {
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
      this.clientData,
      required this.odooService})
      : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  final Telephony telephony = Telephony.instance;

  final _formKey = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();

  dynamic sessionId = '';
  Map clientDataOdoo = {};
  List<dynamic> availableDiets = [];

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
      AuthService.loginWithOtp(otp: _otpController.text).then((value) {
        if (value == "Success") {
          widget.setUserPhone(_phoneController.text);
          _fetchAndSetOdooClient();
          print(widget.clientData);
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

  Future<void> _fetchAvailableDiets() async {
    try {
      availableDiets =
          await widget.odooService.fetchDiets(sessionId, _phoneController.text);
      setState(() {});
    } catch (e) {
      print('Error fetching available diets: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchOdooSession();
    _fetchAvailableDiets();
    if (widget.userPhone != null) {
      _phoneController.text = widget.userPhone!;
    }
  }

  void _showDietPopup(BuildContext context) async {
    if (availableDiets.isEmpty) {
      await _fetchAvailableDiets();
    }

    final currentDiets = widget.clientData?['diets'] ?? [];
    final selectedDiets = Set<String>.from(currentDiets);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit Dietary Preferences'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current Diets:'),
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
                    SizedBox(height: 20),
                    Text('Available Diets:'),
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
                  onPressed: () {
                    // Handle the Apply logic
                    print('currentDiets - ${currentDiets}');
                    print('selectedDiets - ${selectedDiets}');
                    Navigator.pop(context, selectedDiets);
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

  @override
  Widget build(BuildContext context) {
    final clientName = widget.clientData?['name'] ?? 'User';
    final diets = widget.clientData?['diets'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.userPhone != null
              ? 'Welcome, ${widget.userPhone}'
              : 'User Profile',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[500],
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: widget.userPhone == null
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
              : Column(
                  children: [
                    const SizedBox(height: 20),
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Dietary Preferences',
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 30),
                            diets.isEmpty
                                ? ElevatedButton(
                                    onPressed: () => _showDietPopup(context),
                                    child: const Text('Add'),
                                  )
                                : Column(
                                    children: [
                                      ConstrainedBox(
                                        constraints:
                                            BoxConstraints(maxHeight: 200),
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: diets.length,
                                          itemBuilder: (context, index) {
                                            return Text('- ${diets[index]}');
                                          },
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: ElevatedButton(
                                          onPressed: () =>
                                              _showDietPopup(context),
                                          child: const Text('Edit'),
                                        ),
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

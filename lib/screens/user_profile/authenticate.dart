import 'package:flutter/material.dart';

class Authenticate extends StatelessWidget {
  final String phoneNumber;
  final Function(String) setUserPhone;

  const Authenticate(
      {Key? key, required this.phoneNumber, required this.setUserPhone})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController codeController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Authenticate: $phoneNumber',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[500],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: codeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter SMS code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setUserPhone(phoneNumber); // Assign the phone number
                Navigator.pop(context); // Go back to the UserProfile widget
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[500],
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 12.0),
              ),
              child: const Text(
                'Verify Code',
                style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

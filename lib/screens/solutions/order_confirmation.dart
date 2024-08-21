import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:food_bricks/screens/wrapper.dart';

class OrderConfirmation extends StatelessWidget {
  final dynamic response;
  final dynamic solution;
  final String restaurantId;
  final String selectedRestaurant;

  const OrderConfirmation(
      {Key? key,
      required this.response,
      required this.solution,
      required this.restaurantId,
      required this.selectedRestaurant})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final NumberFormat formatter = NumberFormat("###,###", "en_US");

    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Confirmation",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[500],
        centerTitle: true,
        automaticallyImplyLeading: false, // Disable the back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Card displaying image and price
            Card(
              elevation: 4.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image
                  Container(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: Image.network(
                      solution['treemap_image'],
                      fit: BoxFit.contain,
                    ),
                  ),
                  // Price
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${formatter.format(solution['price'].toInt())} VND',
                      style: const TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Text block displaying the order number
            Text(
              '\n\n\nCongratulations! \nYour order has been created!\n\nOrder number: ${response['order_number']}',
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const Spacer(), // Pushes the content above upwards
            // Button to navigate back to the main page (Home widget)
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Wrapper(
                      selectedRestaurant:
                          selectedRestaurant, // Pass the restaurant name back
                      selectedRestaurantId:
                          restaurantId, // Pass the restaurantId back
                    ),
                  ),
                  (Route<dynamic> route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[500],
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 12.0),
              ),
              child: const Text(
                'Back to Main Page',
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

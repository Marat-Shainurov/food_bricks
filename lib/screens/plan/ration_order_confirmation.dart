import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:food_bricks/screens/wrapper.dart';

class RationOrderConfirmation extends StatelessWidget {
  final dynamic response;
  final dynamic ration;
  final Map<dynamic, dynamic>? clientData;
  final String? selectedRestaurant;
  final String? selectedRestaurantId;

  const RationOrderConfirmation({
    Key? key,
    required this.response,
    required this.ration,
    required this.clientData,
    required this.selectedRestaurantId,
    required this.selectedRestaurant,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final NumberFormat formatter = NumberFormat("###,###", "en_US");

    // Join the kitchen orders into a single string, separated by commas
    String kitchenOrders = (response['kitchen_orders'] as List)
        .map((order) => order.toString())
        .join(', ');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Order Confirmation",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
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
                      ration[
                          'image_serving_weight'], // Use the correct image from solution
                      fit: BoxFit.contain,
                    ),
                  ),
                  // Price
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${formatter.format(ration['price'].toInt())} VND',
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
            // Text block displaying the order numbers
            Text(
              '\n\n\nCongratulations! \nYour order has been created!\n\nOrder numbers: $kitchenOrders',
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
                          selectedRestaurantId, // Pass the restaurantId back
                      clientData: clientData,
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

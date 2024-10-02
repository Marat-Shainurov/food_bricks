import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:food_bricks/services/odoo_service.dart';
import 'package:food_bricks/screens/plan/ration_order_confirmation.dart';

class RationOrder extends StatefulWidget {
  final Map<String, dynamic> ration;
  final OdooService odooService;
  final Map<dynamic, dynamic>? clientData;
  final String? selectedRestaurant;
  final String? selectedRestaurantId;

  const RationOrder(
      {Key? key,
      required this.ration,
      required this.odooService,
      required this.clientData,
      required this.selectedRestaurant,
      required this.selectedRestaurantId})
      : super(key: key);

  @override
  _RationOrderState createState() => _RationOrderState();
}

class _RationOrderState extends State<RationOrder> {
  dynamic sessionId;

  @override
  void initState() {
    super.initState();
    print('Solution details widget initialized!');
    print('clientData ${widget.clientData}');
    print('selectedRestaurantId ${widget.selectedRestaurantId}');
    _fetchOdooSession();
  }

  Future<void> _fetchOdooSession() async {
    try {
      sessionId = await widget.odooService.fetchSessionId();
      print('Fetched session id: $sessionId');
    } catch (e) {
      print('Error fetching session ID: $e');
    }
  }

  void _onOrderPressed() async {
    if (sessionId == null) {
      print('Session ID is not available');
      return;
    }

    try {
      final response =
          await widget.odooService.createRationOrder(sessionId, widget.ration);

      if (response != null) {
        print('Order created with ID: ${response['order_identifier']}');
        print('Kitchen orders: ${response['kitchen_orders']}');

        // Navigate to another page or show confirmation
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RationOrderConfirmation(
                response: response,
                ration: widget.ration,
                selectedRestaurantId: widget.selectedRestaurant,
                selectedRestaurant: widget.selectedRestaurantId,
                clientData: widget.clientData),
          ),
        );
      } else {
        print('Failed to create order');
      }
    } catch (e) {
      print('Error creating order: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final NumberFormat formatter = NumberFormat("###,###", "en_US");
    print(widget.ration);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Ration Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[500],
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Image and price section
            Card(
              margin: const EdgeInsets.all(16.0),
              elevation: 4.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image section
                  Container(
                    height: MediaQuery.of(context).size.height * 0.45,
                    child: Image.network(
                      widget.ration['image_serving_weight'],
                      fit: BoxFit.contain,
                    ),
                  ),
                  // Price section
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${formatter.format(widget.ration['price'].toInt())} VND',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16.0),
                    ),
                  ),
                ],
              ),
            ),
            // Dishes list section
            Expanded(
              child: ListView.builder(
                itemCount: widget.ration['dishes'].length,
                itemBuilder: (context, index) {
                  final dish = widget.ration['dishes'][index];
                  return ListTile(
                    title: Text(dish['name']),
                    subtitle:
                        Text('${formatter.format(dish['price'].toInt())} VND'),
                  );
                },
              ),
            ),
            // Order button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _onOrderPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[500], // Button color
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                ),
                child: const Text('Order',
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

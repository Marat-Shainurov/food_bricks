import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:food_bricks/services/odoo_service.dart';
import 'package:food_bricks/screens/solutions/order_confirmation.dart';

class SolutionDetail extends StatefulWidget {
  final dynamic solution;
  final OdooService odooService;
  final String constructorId;

  const SolutionDetail(
      {Key? key,
      required this.solution,
      required this.odooService,
      required this.constructorId})
      : super(key: key);

  @override
  _SolutionDetailState createState() => _SolutionDetailState();
}

class _SolutionDetailState extends State<SolutionDetail> {
  dynamic sessionId;

  @override
  void initState() {
    super.initState();
    print('Solution details widget initialized!');
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

  Future<void> _onOrderPressed() async {
    if (sessionId == null) {
      print('Session ID is not available');
      return;
    }

    try {
      final identifier = widget.solution['identifier'] as String;
      final response =
          await widget.odooService.createKitchenOrder(sessionId, identifier);

      if (response != null) {
        print('Order created with ID: ${response['order_identifier']}');

        // Navigate to another page or show confirmation
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderConfirmation(
              response: response,
              solution: widget.solution,
            ),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Solution Details",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[500],
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Image and price section wrapped in a Card
            Card(
              margin: const EdgeInsets.all(16.0),
              elevation: 4.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image section
                  Container(
                    height: MediaQuery.of(context).size.height *
                        0.45, // 40% of screen height
                    child: Image.network(
                      widget.solution['treemap_image'],
                      fit: BoxFit.contain,
                    ),
                  ),
                  // Price section
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${formatter.format(widget.solution['price'].toInt())} VND',
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Ingredients section
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: widget.solution['ingredients'].length,
                  itemBuilder: (context, index) {
                    final ingredient = widget.solution['ingredients'][index];
                    return ListTile(
                      title: Text(ingredient['name']),
                      subtitle: Text("${ingredient['serving_weight']} g",
                          style: const TextStyle(
                            fontSize: 12.0,
                          )),
                    );
                  },
                ),
              ),
            ),
            // Order Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _onOrderPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[500],
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 12.0),
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

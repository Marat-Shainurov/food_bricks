import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:food_bricks/services/odoo_service.dart';

class SolutionDetail extends StatefulWidget {
  final dynamic solution;
  final OdooService odooService;

  const SolutionDetail(
      {Key? key, required this.solution, required this.odooService})
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
      final identifier = widget.solution['identifier']
          as String; // Ensure identifier is a String
      final response =
          await widget.odooService.createKitchenOrder(sessionId, identifier);

      if (response != null) {
        print('Order created with ID: ${response['order_identifier']}');
        // Optionally, navigate to another page or show a confirmation dialog.
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
        title: const Text("Solution Detail",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[500],
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Image section
            Expanded(
              flex: 5,
              child: Image.network(
                widget.solution['treemap_image'],
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, right: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${formatter.format(widget.solution['price'].toInt())} VND',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.0,
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
                      subtitle: Text(
                        "Weight: ${ingredient['serving_weight']}",
                      ),
                    );
                  },
                ),
              ),
            ),
            // Order Button
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

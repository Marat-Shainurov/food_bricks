import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class SolutionDetail extends StatelessWidget {
  final dynamic solution;

  const SolutionDetail({Key? key, required this.solution}) : super(key: key);

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
                solution['treemap_image'],
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, right: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${formatter.format(solution['price'].toInt())} VND',
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
                  itemCount: solution['ingredients'].length,
                  itemBuilder: (context, index) {
                    final ingredient = solution['ingredients'][index];
                    return ListTile(
                      title: Text(ingredient['name']),
                      subtitle: Text(
                        "Weight: ${ingredient['serving_weight']}",
                        // "Quantity: ${ingredient['serving_weight']}\nCalories: ${ingredient['calories']}",
                      ),
                    );
                  },
                ),
              ),
            ),
            // Order Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Placeholder for order button functionality
                },
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

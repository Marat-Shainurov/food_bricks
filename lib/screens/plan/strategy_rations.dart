import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:food_bricks/services/odoo_service.dart';
import 'package:food_bricks/screens/plan/ration_order.dart';

class StrategyRationsGrid extends StatefulWidget {
  final List<dynamic> strategyRations;
  final String strategyId;
  final OdooService odooService;
  final Map<dynamic, dynamic>? clientData;
  final String? selectedRestaurant;
  final String? selectedRestaurantId;

  const StrategyRationsGrid(
      {Key? key,
      required this.strategyRations,
      required this.odooService,
      required this.strategyId,
      required this.clientData,
      required this.selectedRestaurant,
      required this.selectedRestaurantId})
      : super(key: key);

  @override
  _StrategyRationsGridState createState() => _StrategyRationsGridState();
}

class _StrategyRationsGridState extends State<StrategyRationsGrid> {
  @override
  Widget build(BuildContext context) {
    final NumberFormat formatter = NumberFormat("###,###", "en_US");

    return Scaffold(
      appBar: AppBar(
        title: const Text("Rations",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[500],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 0.75,
          ),
          itemCount: widget.strategyRations.length,
          // Update this method in strategy_ration.dart

          itemBuilder: (context, index) {
            final ration = widget.strategyRations[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RationOrder(
                      ration: ration,
                      odooService: widget.odooService,
                      clientData: widget.clientData,
                      selectedRestaurant: widget.selectedRestaurant,
                      selectedRestaurantId: widget.selectedRestaurantId,
                    ),
                  ),
                );
              },
              child: Card(
                elevation: 4.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Image.network(
                        ration['image_serving_weight'],
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${formatter.format(ration['price'].toInt())} VND',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

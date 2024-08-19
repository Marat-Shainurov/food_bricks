import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:food_bricks/services/odoo_service.dart';
import 'package:food_bricks/screens/plan/strategy_rations.dart';
import 'package:food_bricks/services/utils.dart';

class StrategiesGrid extends StatefulWidget {
  final List<dynamic> strategies;
  final OdooService odooService;

  const StrategiesGrid(
      {Key? key, required this.strategies, required this.odooService})
      : super(key: key);

  @override
  _StrategiesGridState createState() => _StrategiesGridState();
}

class _StrategiesGridState extends State<StrategiesGrid> {
  String sessionId = '';
  Utils utils = Utils();

  void _onStrategyTapped(String strategyId) async {
    utils.showLoaderDialog(context);

    try {
      // Fetch session ID
      sessionId = await widget.odooService.fetchSessionId();

      // Fetch strategy rations using the strategy identifier
      final strategyRations = await widget.odooService.fetchStrategyRations(
        sessionId,
        {'identifier': strategyId},
      );

      Navigator.pop(context);
      // Navigate to the StrategyRationsGrid page and pass the fetched data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StrategyRationsGrid(
            strategyRations: strategyRations,
            strategyId: strategyId,
            odooService: widget.odooService,
          ),
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load strategy rations: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final NumberFormat formatter = NumberFormat("###,###", "en_US");

    return Scaffold(
      appBar: AppBar(
        title: const Text("Plans",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[500],
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.75,
              ),
              itemCount: widget.strategies.length,
              itemBuilder: (context, index) {
                final strategy = widget.strategies[index];
                return GestureDetector(
                  onTap: () => _onStrategyTapped(strategy['identifier']),
                  child: Card(
                    elevation: 4.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Image.network(
                            strategy['image_serving_weight'],
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${formatter.format(strategy['price'].toInt())} VND',
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
        ],
      ),
    );
  }
}

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:food_bricks/services/odoo_service.dart';
import 'solution_details.dart';

class SolutionsGrid extends StatefulWidget {
  final String constructorId;
  final List<dynamic> solutions;
  final OdooService odooService;
  final String restaurantId;
  final String selectedRestaurant;
  final clientData;

  const SolutionsGrid(
      {Key? key,
      required this.solutions,
      required this.odooService,
      required this.constructorId,
      required this.restaurantId,
      required this.selectedRestaurant,
      required this.clientData})
      : super(key: key);

  @override
  _SolutionsGridState createState() => _SolutionsGridState();
}

class _SolutionsGridState extends State<SolutionsGrid> {
  @override
  Widget build(BuildContext context) {
    final NumberFormat formatter = NumberFormat("###,###", "en_US");
    return Scaffold(
      appBar: AppBar(
        title: const Text("Solutions",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[500],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 0.75,
          ),
          itemCount: widget.solutions.length,
          itemBuilder: (context, index) {
            final solution = widget.solutions[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SolutionDetail(
                        solution: solution,
                        odooService: widget.odooService,
                        constructorId: widget.constructorId,
                        restaurantId: widget.restaurantId,
                        selectedRestaurant: widget.selectedRestaurant,
                        clientData: widget.clientData),
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
                        solution['treemap_image'],
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

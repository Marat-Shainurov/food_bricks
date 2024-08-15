import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:food_bricks/services/odoo_service.dart';
import 'solution_details.dart';

class SolutionsGrid extends StatelessWidget {
  final List<dynamic> solutions;
  final OdooService odooService;

  const SolutionsGrid(
      {Key? key, required this.solutions, required this.odooService})
      : super(key: key);

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
          itemCount: solutions.length,
          itemBuilder: (context, index) {
            final solution = solutions[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SolutionDetail(
                      solution: solution,
                      odooService: odooService,
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

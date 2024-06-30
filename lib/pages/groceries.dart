import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'dart:math';
import '../globals.dart' as globals;
import 'package:pantry_planner/components/filter_pill.dart'; // Import FilterPill class
import 'package:pantry_planner/provider/groceryList_provider.dart';
import 'package:pantry_planner/provider/budget_provider.dart';

import 'package:provider/provider.dart';

class GroceriesPage extends StatefulWidget {
  const GroceriesPage({Key? key}) : super(key: key);

  @override
  _GroceriesPageState createState() => _GroceriesPageState();
}

class _GroceriesPageState extends State<GroceriesPage> {
  List<String> selectedStores = [];
  double totalCost = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Grocery List",
          style: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Consumer<BudgetProvider>(
        builder: (context, budgetProvider, _) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text(
                      'Your Budget: \$${budgetProvider.budget.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: GroceryListProvider.stores.length,
                  itemBuilder: (context, index) {
                    String store = GroceryListProvider.stores[index];
                    bool isSelected = selectedStores.contains(store);
                    return Row(children: [
                      FilterPill(
                        // Use FilterPill instead of GestureDetector and Container
                        label: store,
                        onSelectionChanged: _handleFilterSelection,
                      ),
                      const SizedBox(width: 8.0),
                    ]);
                  },
                ),
              ),
              Expanded(
                child: Consumer<GroceryListProvider>(
                  builder: (context, provider, child) {
                    List<GroceryItem> groceryItems = provider.groceryList;
                    if (groceryItems.isEmpty) {
                      return const Center(
                        child: Text('No grocery stores found.'),
                      );
                    } else {
                      // Apply filtering based on selected stores
                      List<GroceryItem> filteredItems = selectedStores.isEmpty
                          ? groceryItems
                          : groceryItems
                              .where(
                                  (item) => selectedStores.contains(item.store))
                              .toList();

                      // Group items by store
                      Map<String, List<GroceryItem>> groupedItems = {};
                      for (var item in filteredItems) {
                        if (!groupedItems.containsKey(item.store)) {
                          groupedItems[item.store] = [];
                        }
                        groupedItems[item.store]!.add(item);
                      }

                      return ListView.builder(
                        itemCount: groupedItems.length,
                        itemBuilder: (context, index) {
                          String storeName = groupedItems.keys.elementAt(index);
                          List<GroceryItem> items = groupedItems[storeName]!;
                          totalCost = items.fold<double>(
                              0,
                              (previousValue, item) =>
                                  previousValue + item.price);
                          double savings = budgetProvider.budget - totalCost;
                          String savingText = savings >= 0
                              ? 'Save \$${savings.toStringAsFixed(2)}'
                              : 'Exceeded by \$${(-savings).toStringAsFixed(2)}';

                          return Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        storeName,
                                        style: const TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const Spacer(),
                                      Text(
                                        savingText,
                                        style: TextStyle(
                                          color: savings >= 0
                                              ? Colors.green
                                              : Color.fromARGB(
                                                  255, 224, 89, 79),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  height: 50,
                                  color: Color.fromARGB(255, 101, 101, 101),
                                  padding: const EdgeInsets.all(8),
                                  margin:
                                      const EdgeInsets.fromLTRB(0, 0, 0, 16),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Total: \$${totalCost.toStringAsFixed(2)}',
                                    textAlign: TextAlign
                                        .center, // Center align the text horizontally
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: items.map((item) {
                                    return Column(
                                      children: [
                                        ListTile(
                                          title: Row(
                                            children: [
                                              Expanded(child: Text(item.item)),
                                              const SizedBox(width: 8),
                                              Text(
                                                  '\$${item.price.toStringAsFixed(2)}'),
                                              const SizedBox(width: 8),
                                              ElevatedButton(
                                                onPressed: () {
                                                  provider
                                                      .removeItemFromGroceryList(
                                                          item);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10),
                                                ),
                                                child: const Text('Remove',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Divider(
                                            color: Colors
                                                .grey), // Divider between each item
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _handleFilterSelection(String label, bool isSelected) {
    setState(() {
      if (isSelected) {
        selectedStores.add(label);
      } else {
        selectedStores.remove(label);
      }
    });
  }
}

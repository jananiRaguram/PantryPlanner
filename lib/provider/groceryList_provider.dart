import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import '../globals.dart' as globals;

class GroceryListProvider extends ChangeNotifier {
  List<GroceryItem> _groceryList = [];

  List<GroceryItem> get groceryList => _groceryList;

  static List<String> stores = [
    "Zehrs Markets",
    "No Frills",
    "Food Basics",
    "FreshCo",
    "Metro",
    "Costco Wholesale",
    "Walmart Supercentre",
    "Longos",
    "Bulk Barn",
    "Goodness Me!"
  ];

  void addItemToGroceryList(List<String> ingredients) {
    // Assign store and random prices to each ingredient and add to the grocery list
    for (String store in stores) {
      for (String ingredient in ingredients) {
        double price =
            Random().nextDouble() * 15.0; // Random price between 0 and 15
        _groceryList
            .add(GroceryItem(store: store, item: ingredient, price: price));
      }
    }

    // print("heer");
    notifyListeners();
  }

  void removeItemFromGroceryList(GroceryItem item) {
    _groceryList.removeWhere((groceryItem) => groceryItem.item == item.item);
    notifyListeners();
  }

  static GroceryListProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<GroceryListProvider>(
      context,
      listen: listen,
    );
  }
}

class GroceryItem {
  final String store;
  final String item;
  final double price;

  GroceryItem({required this.store, required this.item, required this.price});
}

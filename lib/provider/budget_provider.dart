import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pantry_planner/pages/home.dart';
import 'package:pantry_planner/services/recipes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BudgetProvider extends ChangeNotifier {
  double _budget = 0.0;

  double get budget => _budget;

  BudgetProvider() {
    _loadBudgetFromSharedPreferences();
  }

  Future<void> _loadBudgetFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double? savedBudget = prefs.getDouble('user_budget');
    if (savedBudget != null) {
      _budget = savedBudget;
    }
  }

  Future<void> setBudget(double budget) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('user_budget', budget);
    _budget = budget;
    notifyListeners();
  }
}

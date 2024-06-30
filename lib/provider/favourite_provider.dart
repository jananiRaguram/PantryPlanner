import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pantry_planner/pages/home.dart';
import 'package:pantry_planner/services/recipes.dart';

class FavoriteProvider extends ChangeNotifier {
  List<Recipe> _recipes = [];
  List<Recipe> get recipes => _recipes;

  void toggleFavorite(Recipe recipe) {
    final existingIndex = _recipes.indexWhere(
      (existingRecipe) => existingRecipe.name == recipe.name,
    );

    if (existingIndex != -1) {
      _recipes.removeAt(existingIndex);
    } else {
      _recipes.add(recipe);
    }

    notifyListeners();
  }

  bool isExist(Recipe recipe) {
    return _recipes.any((existingRecipe) => existingRecipe.name == recipe.name);
  }

  static FavoriteProvider of(
    BuildContext context, {
    bool listen = true,
  }) {
    return Provider.of<FavoriteProvider>(
      context,
      listen: listen,
    );
  }
}

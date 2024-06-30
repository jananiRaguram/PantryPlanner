import 'package:shared_preferences/shared_preferences.dart';
import 'package:pantry_planner/services/recipes.dart';

import 'dart:convert';

class LocalStorageService {
  Future<void> saveUserCredentials(String email, String password) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('password', password);
  }

  Future<Map<String, String>?> getUserCredentials() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? email = prefs.getString('email');
    final String? password = prefs.getString('password');

    if (email != null && password != null) {
      return {'email': email, 'password': password};
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? email = prefs.getString('email');
    return email != null;
  }

  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all data to log out
  }

  Future<void> cacheRecipes(List<Recipe> recipes) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_recipes',
        json.encode(recipes.map((recipe) => recipe.toJson()).toList()));
  }

  Future<List<Recipe>> getCachedRecipes() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? cachedRecipesJson =
        prefs.getString('cached_recipes_featured');
    if (cachedRecipesJson != null) {
      final List<dynamic> cachedRecipesData = json.decode(cachedRecipesJson);
      return Recipe.fromJsonList(cachedRecipesData);
    }
    return [];
  }

  Future<List<Recipe>> getCachedRecipesByType(String selectedType) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? cachedRecipesJson =
        prefs.getString('cached_recipes_$selectedType');
    if (cachedRecipesJson != null) {
      final List<dynamic> cachedRecipesData = json.decode(cachedRecipesJson);
      return Recipe.fromJsonList(cachedRecipesData);
    }
    return [];
  }
}

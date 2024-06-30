import 'package:flutter/material.dart';
import 'package:pantry_planner/services/recipes.dart';
import 'package:pantry_planner/provider/favourite_provider.dart';
import 'package:provider/provider.dart';
import 'package:pantry_planner/components/filter_pill.dart';
import 'package:pantry_planner/components/more_menu.dart';
import 'package:pantry_planner/pages/search.dart';
import 'recipe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pantry_planner/services/localstorageservice.dart';

class RecipesPage extends StatefulWidget {
  @override
  _RecipesPage createState() => _RecipesPage();
}

class _RecipesPage extends State<RecipesPage> {
  String selectedType = 'Featured';

  void _handleFilterSelection(String label) {
    setState(() {
      if (label != 'Featured') {
        selectedType = label;
      } else {
        selectedType = 'Featured';
      }
    });
  }

  void _navigateToRecipePage(Recipe recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipePage(recipe: recipe),
      ),
    );
  }

  void _navigateToSearchPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> categories = [
      'Featured',
      'Breakfast',
      'Vegan',
      'Vegetarian',
      'Side',
      'Dessert'
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Recipes",
          style: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 25.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.search,
                    size: 25.0,
                  ),
                  onPressed: () {
                    _navigateToSearchPage();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RecipeFilterPills(
            categories: categories,
            onSelect: _handleFilterSelection,
          ),
          Expanded(
            child: RecipeList(
              selectedType: selectedType,
              onTap: _navigateToRecipePage,
            ),
          ),
        ],
      ),
    );
  }
}

class RecipeList extends StatelessWidget {
  final String selectedType;
  final Function(Recipe) onTap;

  const RecipeList({Key? key, required this.selectedType, required this.onTap})
      : super(key: key);

  Future<List<Recipe>> fetchRecipes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // If selectedType is not 'Featured', try fetching filtered recipes from cache
    if (selectedType != 'Featured') {
      final List<Recipe> cachedRecipes =
          await LocalStorageService().getCachedRecipesByType(selectedType);
      if (cachedRecipes.isNotEmpty) {
        return cachedRecipes;
      }
    } else {
      final List<Recipe> cachedRecipes =
          await LocalStorageService().getCachedRecipes();
      if (cachedRecipes.isNotEmpty) {
        return cachedRecipes;
      }
    }

    // Fetch recipes from the API if no cached recipes exist or if the selected type does not match the cached type
    String url = 'https://www.themealdb.com/api/json/v1/1/';
    if (selectedType != 'Featured') {
      url += 'filter.php?c=$selectedType';
    } else {
      url += 'search.php?s=';
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['meals'];
      List<String> recipeIds =
          data.map<String>((json) => json['idMeal']).toList();
      List<Recipe> fetchedRecipes = await fetchFilteredRecipes(recipeIds);

      // Cache the filtered recipes separately
      if (selectedType != 'Featured') {
        prefs.setString(
            'cached_recipes_$selectedType',
            json.encode(
                fetchedRecipes.map((recipe) => recipe.toJson()).toList()));
      } else {
        // Cache the fetched recipes
        prefs.setString(
            'cached_recipes_featured',
            json.encode(
                fetchedRecipes.map((recipe) => recipe.toJson()).toList()));
      }
      return fetchedRecipes;
    } else {
      // Throw an exception only if fetching from the API fails
      throw Exception('Failed to load recipes');
    }
  }

  Future<List<Recipe>> fetchFilteredRecipes(List<String> recipeIds) async {
    try {
      List<Recipe> filteredRecipes = [];

      // Iterate through each recipe ID
      for (String id in recipeIds) {
        // Make API call for detailed recipe information
        final response = await http.get(Uri.parse(
            'https://www.themealdb.com/api/json/v1/1/lookup.php?i=$id'));

        if (response.statusCode == 200) {
          // Parse response JSON
          Map<String, dynamic> data = json.decode(response.body);
          if (data['meals'] != null && data['meals'].length > 0) {
            // Initialize Recipe object and add to list
            filteredRecipes.add(Recipe.fromJson(data['meals'][0]));
          }
        }
      }

      return filteredRecipes;
    } catch (error) {
      throw Exception('Failed to fetch filtered recipes: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Recipe>>(
      future: fetchRecipes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
              child: Text('Error fetching recipes: ${snapshot.error}'));
        }
        final List<Recipe> recipes = snapshot.data ?? [];
        if (recipes.isEmpty) {
          return Center(
            child: Text(
              "We're still on the search for these recipes!",
              style: TextStyle(fontSize: 22.0),
              textAlign: TextAlign.center,
            ),
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (selectedType == "Featured")
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Featured Recipes',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  itemCount: recipes.length,
                  itemBuilder: (context, index) => RecipeTile(
                    recipe: recipes[index],
                    onTap: onTap,
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}

class RecipeTile extends StatelessWidget {
  final Recipe recipe;
  final Function(Recipe) onTap;

  const RecipeTile({Key? key, required this.recipe, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FavoriteProvider>(context);
    return GestureDetector(
      onTap: () {
        onTap(recipe);
      },
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // container for icons separate to keep icons at the top
              // add this: globals.ingredients
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: provider.isExist(recipe)
                            ? const Icon(Icons.favorite, color: Colors.pink)
                            : const Icon(Icons.favorite_border),
                        onPressed: () {
                          provider.toggleFavorite(recipe);
                        },
                      ),
                      MoreMenu(
                        ingredients: recipe.ingredientsG,
                      ),
                    ],
                  ),
                ),
              ),

              // container for image and bottom text
              Container(
                height: 250,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(recipe.imageUrl),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.15),
                      BlendMode.darken,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0, left: 20, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: const TextStyle(
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(recipe.cookingTime.toString()),
                        SizedBox(width: 12),
                        Icon(
                          Icons.shopping_bag,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text('${recipe.ingredientsG.length}'),
                        SizedBox(width: 12),
                        Icon(
                          Icons.help,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(recipe.difficulty.toString()),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

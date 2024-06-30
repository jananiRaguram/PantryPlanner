import 'package:flutter/material.dart';
import 'package:pantry_planner/provider/favourite_provider.dart';
import 'package:provider/provider.dart';
import 'package:pantry_planner/services/recipes.dart';
import 'package:pantry_planner/pages/recipe.dart';
import 'package:pantry_planner/components/filter_pill.dart';

class FavouritesPage extends StatefulWidget {
  @override
  _FavouritesPageState createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  String selectedType = '';

  void _handleFilterSelection(String label, bool isSelected) {
    setState(() {
      if (isSelected) {
        selectedType = label.toLowerCase();
      } else {
        selectedType = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FavoriteProvider>(context);
    List<Recipe> recipes = provider.recipes;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Your Favourites",
          style: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: recipes.isEmpty
          ? Center(
              child: Text(
                'No favourited recipes',
                style: TextStyle(
                  fontSize: 18.0,
                  // fontWeight: FontWeight.bold,
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = recipes[index];
                      return Column(
                        children: [
                          ListTile(
                            leading: Image.network(
                              recipe.imageUrl,
                              width: 100.0,
                              height: 100.0,
                              fit: BoxFit.cover,
                            ),
                            title: Text(
                              recipe.name,
                              style: const TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      RecipePage(recipe: recipe),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8.0),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

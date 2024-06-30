import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pantry_planner/services/recipes.dart';
import 'package:pantry_planner/provider/favourite_provider.dart';
import 'package:pantry_planner/provider/groceryList_provider.dart';

import 'package:provider/provider.dart';
import 'package:pantry_planner/pages/groceries.dart';
import '../../globals.dart' as globals;

class RecipePage extends StatelessWidget {
  final Recipe recipe;
  final Random random = Random();

  RecipePage({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _fetchCachedValues(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return _buildRecipePage(context);
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  Future<void> _fetchCachedValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('cookingTime_${recipe.id}') ||
        !prefs.containsKey('difficulty_${recipe.id}')) {
      int cookingTime = random.nextInt(120) + 10; // 10 min to 2 hours
      int difficulty = random.nextInt(5) + 1; //  1 to 5
      await prefs.setInt('cookingTime_${recipe.id}', cookingTime);
      await prefs.setInt('difficulty_${recipe.id}', difficulty);
    }
  }

  Widget _buildRecipePage(BuildContext context) {
    return FutureBuilder<int>(
      future: _getCachedCookingTime(),
      builder: (context, cookingTimeSnapshot) {
        return FutureBuilder<int>(
          future: _getCachedDifficulty(),
          builder: (context, difficultySnapshot) {
            if (cookingTimeSnapshot.connectionState == ConnectionState.done &&
                difficultySnapshot.connectionState == ConnectionState.done) {
              //Using cached or generated values
              int cookingTime = cookingTimeSnapshot.data ?? 0;
              int difficulty = difficultySnapshot.data ?? 0;

              // Split the instructions
              List<String> instructionLines = recipe.instructions.split('\n');

              return Scaffold(
                appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(350),
                  child: Stack(
                    children: [
                      Container(
                        height: 350,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(recipe.imageUrl),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.3),
                              BlendMode.darken,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: AppBar(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          leading: IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  recipe.name,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            IconButton(
                              icon: Consumer<FavoriteProvider>(
                                builder: (context, provider, child) {
                                  return provider.isExist(recipe)
                                      ? const Icon(Icons.favorite,
                                          color: Colors.pink)
                                      : const Icon(Icons.favorite_border,
                                          color: Colors.white);
                                },
                              ),
                              onPressed: () {
                                Provider.of<FavoriteProvider>(context,
                                        listen: false)
                                    .toggleFavorite(recipe);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, color: Colors.white),
                              onPressed: () {
                                Provider.of<GroceryListProvider>(context,
                                        listen: false)
                                    .addItemToGroceryList(recipe.ingredientsG);
                                // Show a snackbar to provide feedback to the user
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Ingredients added to your grocery list!'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cooking Time (min):',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          recipe.cookingTime.toString(),
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Difficulty:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          recipe.difficulty.toString(),
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Number of ingredients:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${recipe.ingredientsD.length}',
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Ingredients:',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: recipe.ingredientsD.map((ingredient) {
                            return Text(
                              ingredient,
                              style: const TextStyle(
                                fontSize: 20,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Directions:',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:
                              instructionLines.asMap().entries.map((entry) {
                            int index = entry.key + 1;
                            String instruction = entry.value;
                            return Text(
                              '$index. $instruction',
                              style: const TextStyle(
                                fontSize: 20,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return CircularProgressIndicator();
            }
          },
        );
      },
    );
  }

  Future<int> _getCachedCookingTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('cookingTime_${recipe.id}') ?? 0;
  }

  Future<int> _getCachedDifficulty() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('difficulty_${recipe.id}') ?? 0;
  }
}

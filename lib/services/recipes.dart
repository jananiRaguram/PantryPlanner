import 'dart:math';

class Recipe {
  final String id;
  final String name;
  final String category;
  final String instructions;
  final String imageUrl;
  final List<String> ingredientsG; //for grocery list
  final List<String> ingredientsD; //for details
  final int cookingTime;
  final int difficulty;

  Recipe(
      {required this.id,
      required this.name,
      required this.category,
      required this.instructions,
      required this.imageUrl,
      required this.ingredientsG,
      required this.ingredientsD,
      required this.cookingTime,
      required this.difficulty});

  factory Recipe.fromJson(Map<String, dynamic> json) {
    List<String> ingredientsG = [];
    List<String> ingredientsD = [];
    // if(json['ingredientsG'] == null)
    for (int i = 1; i <= 20; i++) {
      // Check if both ingredient and measure are not empty
      String? ingredient = json['strIngredient$i'];
      String? measure = json['strMeasure$i'];
      if ((ingredient != null && ingredient.trim().isNotEmpty) &&
          (measure != null && measure.trim().isNotEmpty)) {
        ingredientsG.add(ingredient);
        ingredientsD.add('$measure $ingredient');
      } else {
        // If either ingredient or measure is empty or null, stop iterating
        break;
      }
    }

    final Random random = Random();
    int cookingTime = random.nextInt(120) + 10; // 10 min to 2 hours
    int difficulty = random.nextInt(5) + 1; //  1 to 5

    return Recipe(
        id: json['idMeal'] ?? '',
        name: json['strMeal'] ?? '',
        category: json['strCategory'] ?? '',
        instructions: json['strInstructions'] ?? '',
        imageUrl: json['strMealThumb'] ?? '',
        ingredientsG: ingredientsG,
        ingredientsD: ingredientsD,
        cookingTime: cookingTime,
        difficulty: difficulty);
  }

  Map<String, dynamic> toJson() {
    return {
      'idMeal': id,
      'strMeal': name,
      'ingredientsG': ingredientsG,
      'strInstructions': instructions,
      'strMealThumb': imageUrl,
      'ingredientsD': ingredientsD,
      'cookingTime': cookingTime,
      'difficulty': difficulty
    };
  }

  factory Recipe.fromJsonCache(Map<String, dynamic> json) {
    List<String> ingredientsG = List<String>.from(json['ingredientsG'] ?? []);
    List<String> ingredientsD = List<String>.from(json['ingredientsD'] ?? []);

    return Recipe(
        id: json['idMeal'] ?? '',
        name: json['strMeal'] ?? '',
        category: json['strCategory'] ?? '',
        instructions: json['strInstructions'] ?? '',
        imageUrl: json['strMealThumb'] ?? '',
        ingredientsG: ingredientsG,
        ingredientsD: ingredientsD,
        cookingTime: json['cookingTime'] ?? 0,
        difficulty: json['difficulty'] ?? 0);
  }

  static List<Recipe> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => Recipe.fromJsonCache(json)).toList();
  }
}

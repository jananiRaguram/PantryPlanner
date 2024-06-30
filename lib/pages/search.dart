import 'package:flutter/material.dart';
import 'package:pantry_planner/services/recipes.dart';
import 'package:pantry_planner/pages/recipe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchPage extends StatefulWidget {
  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Recipe> _filteredRecipes = [];
  bool _searchPerformed = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          controller: _searchController,
          onFieldSubmitted: (_) {
            _submitSearch();
          },
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearSearch,
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: _submitSearch,
            child: const Text(
              'Search',
              style: TextStyle(fontSize: 15.0),
            ),
          ),
        ],
      ),
      body: _searchPerformed // Check if a search has been performed
          ? _filteredRecipes.isEmpty
              ? const Center(
                  child: Text(
                      'No recipes found. \n Try searching for recipe names or ingredients',
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center))
              : ListView.builder(
                  itemCount: _filteredRecipes.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_filteredRecipes[index].name),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RecipePage(recipe: _filteredRecipes[index]),
                          ),
                        );
                      },
                    );
                  },
                )
          : const SizedBox(),
    );
  }

  void _submitSearch() async {
    String query = _searchController.text.trim();
    List<Recipe> filtered = await _fetchFilteredRecipes(query);
    setState(() {
      _filteredRecipes = filtered;
      _searchPerformed = true;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _filteredRecipes = [];
    });
  }

  Future<List<Recipe>> _fetchFilteredRecipes(String query) async {
    final String url =
        'https://www.themealdb.com/api/json/v1/1/search.php?s=$query';
    final response = await http.get(Uri.parse(url));
    print(response.body);
    if (response.statusCode == 200) {
      if (json.decode(response.body)['meals'] == null) {
        return [];
      }

      List<dynamic> data = json.decode(response.body)['meals'];
      return data.map((json) => Recipe.fromJson(json)).toList();
    } else {
      throw Exception('Error fetching');
    }
  }
}

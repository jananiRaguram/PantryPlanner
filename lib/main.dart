import 'package:flutter/material.dart';
import 'pages/home.dart';
import 'pages/groceries.dart';
import 'pages/favourites.dart';
import 'pages/account.dart';
import 'package:pantry_planner/provider/favourite_provider.dart';
import 'package:pantry_planner/provider/groceryList_provider.dart';
import 'package:pantry_planner/provider/budget_provider.dart';

import 'package:provider/provider.dart';

import 'pages/signInPage.dart';
import 'services/localstorageservice.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) =>
                FavoriteProvider()), // Provide your FavoriteProvider
        ChangeNotifierProvider(
            create: (context) =>
                GroceryListProvider()), // Provide your GroceryListProvider
        ChangeNotifierProvider(create: (context) => BudgetProvider()),
      ],
      child: MaterialApp(
        home: FutureBuilder(
          future: LocalStorageService().isLoggedIn(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.data == true) {
                return MyHomePage(); // User is logged in, show the main app interface
              } else {
                // If the user is not logged in, show the SignInPage
                return SignInPage();
              }
            } else {
              // Show a loading indicator while checking the login status
              return Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
          },
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    RecipesPage(),
    FavouritesPage(),
    GroceriesPage(),
    AccountPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Groceries',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800], // Color when an item is selected
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}

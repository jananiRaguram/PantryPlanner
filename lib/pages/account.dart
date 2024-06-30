import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/localstorageservice.dart';
import 'signInPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:pantry_planner/provider/budget_provider.dart';

class AccountPage extends StatefulWidget {
  @override
  AccountPageState createState() => AccountPageState();
}

class AccountPageState extends State<AccountPage> {
  String userEmail = '';
  String selectedDiet = 'Everything';
  String budgetPeriod = 'Monthly';
  final TextEditingController _budgetController = TextEditingController();
  final String userBio = "My aim is to eat healthy and save money.";

  @override
  void initState() {
    super.initState();
    _fetchUserEmail();
  }

  _fetchUserEmail() async {
    final credentials = await LocalStorageService().getUserCredentials();
    if (credentials != null) {
      setState(() {
        userEmail = credentials['email'] ?? 'Unknown';
      });
    }
  }

  void _showChoiceDialog(String choice) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$choice Details'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Workout eating: $choice.'),
                SizedBox(height: 10),
                Text('Diet Plan:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                    '1. Breakfast: Oats\n2. Lunch: Salad\n3. Dinner: Grilled Chicken'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _lineGraph() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Savings Graph",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Container(
          height: 200,
          padding: const EdgeInsets.all(18),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: 11,
              minY: 0,
              maxY: 6,
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    FlSpot(0, 3),
                    FlSpot(2.6, 2),
                    FlSpot(4.9, 5),
                    FlSpot(6.8, 2.5),
                    FlSpot(8, 4),
                    FlSpot(9.5, 3),
                    FlSpot(11, 4),
                  ],
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final budgetProvider = Provider.of<BudgetProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Account'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text(
            userEmail,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          ElevatedButton(
            onPressed: () async {
              await LocalStorageService().logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => SignInPage()),
                (Route<dynamic> route) => false,
              );
            },
            child: Text('Logout'),
          ),
          Divider(),
          Text("User Bio:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(userBio, style: TextStyle(fontSize: 16)),
          Divider(),
          Text("Diet Preference:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          DropdownButton<String>(
            value: selectedDiet,
            isExpanded: true,
            items: <String>[
              'Vegetarian',
              'Vegan',
              'Meat Lover',
              'Protein Based Diet',
              'Everything',
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedDiet = value!;
              });
            },
          ),
          Divider(),
          Text("Budget Period:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          DropdownButton<String>(
            value: budgetPeriod,
            isExpanded: true,
            items: <String>['Monthly', 'Weekly']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                budgetPeriod = value!;
              });
            },
          ),
          TextField(
            controller: TextEditingController(
                text: budgetProvider.budget.toStringAsFixed(2)),
            decoration: InputDecoration(
              labelText: 'Budget Amount',
              hintText: 'Enter your budget here',
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              double newBudget = double.tryParse(value) ?? 0.0;
              budgetProvider.setBudget(newBudget);
            },
          ),
          ListTile(
            title: Text("Food Choice 1"),
            onTap: () => _showChoiceDialog("Choice 1"),
          ),
          ListTile(
            title: Text("Food Choice 2"),
            onTap: () => _showChoiceDialog("Choice 2"),
          ),
          Divider(),
          _lineGraph(),
        ],
      ),
    );
  }
}

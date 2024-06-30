import 'package:flutter/material.dart';
import '../services/localstorageservice.dart';
import 'signInPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'package:pantry_planner/provider/budget_provider.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '', _password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              onSaved: (value) => _email = value!,
              validator: (value) =>
                  value!.isEmpty ? 'Please enter an email' : null,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              onSaved: (value) => _password = value!,
              validator: (value) =>
                  value!.isEmpty ? 'Please enter a password' : null,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            ElevatedButton(
              child: Text('Create Account'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  // Save the user credentials locally
                  await LocalStorageService()
                      .saveUserCredentials(_email, _password);
                  // Navigate to the Budget Entry page
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => BudgetEntryPage()),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class BudgetEntryPage extends StatefulWidget {
  @override
  _BudgetEntryPageState createState() => _BudgetEntryPageState();
}

class _BudgetEntryPageState extends State<BudgetEntryPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Enter Your Budget \$:')),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            Consumer<BudgetProvider>(
              builder: (context, budgetProvider, child) {
                return TextFormField(
                  onSaved: (value) {
                    budgetProvider.setBudget(double.parse(value!));
                  },
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your budget' : null,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Budget'),
                );
              },
            ),
            ElevatedButton(
              child: Text('Save Budget'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            MyHomePage()), // Navigate to home page
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

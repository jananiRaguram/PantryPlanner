import 'package:flutter/material.dart';
import '../services/localstorageservice.dart';
import '../pages/home.dart';
import '../main.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '', _password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign In')),
      body: SingleChildScrollView(
        // Added for scrolling if keyboard covers the form
        padding: EdgeInsets.all(20.0), // Added padding for aesthetic spacing
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center the form
            children: <Widget>[
              TextFormField(
                onSaved: (value) => _email = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter an email' : null,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              SizedBox(height: 10), // Added for spacing
              TextFormField(
                onSaved: (value) => _password = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a password' : null,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
              ),
              SizedBox(height: 20), // Added for spacing
              ElevatedButton(
                child: Text('Sign In'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Attempt to retrieve stored credentials
                    final credentials =
                        await LocalStorageService().getUserCredentials();
                    if (credentials != null &&
                        credentials['email'] == _email &&
                        credentials['password'] == _password) {
                      // Credentials match, navigate to MyHomePage
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                MyHomePage()), // Assuming MyHomePage is now recognized
                      );
                    } else {
                      // Show error
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Invalid email or password')),
                      );
                    }
                  }
                },
              ),
              TextButton(
                child: Text('Don\'t have an account? Sign up'),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

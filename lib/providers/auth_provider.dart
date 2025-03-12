import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:beautywise_ai/providers/auth_provider.dart';
import '../providers/auth_provider.dart';
import 'package:beautywise_ai/ui/screens/home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isLogin = true; // Toggle between login and register

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? "Login" : "Register")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isLogin) // Show username field only during registration
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: "Username"),
              ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            if (authProvider.isLoading)
              CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: () async {
                  if (_isLogin) {
                    await authProvider.login(
                      _emailController.text.trim(),
                      _passwordController.text.trim(),
                    );
                  } else {
                    await authProvider.register(
                      _emailController.text.trim(),
                      _passwordController.text.trim(),
                      _usernameController.text.trim(),
                    );
                  }

                  if (authProvider.user != null) {
                    // Navigate to Home if login successful
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  }
                },
                child: Text(_isLogin ? "Login" : "Register"),
              ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLogin = !_isLogin; // Toggle between login & register
                });
              },
              child: Text(
                _isLogin
                    ? "Create an account"
                    : "Already have an account? Login",
              ),
            ),
            if (authProvider.errorMessage != null)
              Text(
                authProvider.errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}

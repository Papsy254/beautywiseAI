import 'package:beautywise_ai/ui/screens/forgot_password.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Single text field used for both email and phone number
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // For form validation
  bool _isLoading = false;
  bool _obscurePassword = true; // Toggle for password visibility

  // Checks if the input string is in email format
  bool _isValidEmail(String input) {
    return RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(input);
  }

  void loginUser() async {
    if (!_formKey.currentState!.validate()) return; // Validate inputs

    setState(() => _isLoading = true);
    String identifier = _identifierController.text.trim();
    String password = _passwordController.text.trim();
    String? emailToUse;

    try {
      // If the identifier is a valid email, use it directly
      if (_isValidEmail(identifier)) {
        emailToUse = identifier;
      } else {
        // Otherwise, treat it as a phone number and query Firestore for the user
        QuerySnapshot snapshot =
            await _firestore
                .collection("users")
                .where("phone", isEqualTo: identifier)
                .get();

        if (snapshot.docs.isEmpty) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Phone number does not exist",
                style: TextStyle(color: Colors.red),
              ),
              backgroundColor: Colors.white,
            ),
          );
          return;
        }
        // Assume the first matching document is the correct user
        Map<String, dynamic> userData =
            snapshot.docs.first.data() as Map<String, dynamic>;
        emailToUse = userData["email"];
      }

      // Proceed to sign in with the emailToUse and password
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailToUse!,
        password: password,
      );

      // Check if the user exists in Firestore
      DocumentSnapshot userDoc =
          await _firestore
              .collection("users")
              .doc(userCredential.user!.uid)
              .get();

      if (userDoc.exists) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "User does not exist in Firestore",
              style: TextStyle(color: Colors.red),
            ),
            backgroundColor: Colors.white,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      // If the error code indicates the user is not found, show a specific message
      if (e.code == 'user-not-found') {
        String message =
            _isValidEmail(identifier)
                ? "Email does not exist"
                : "Phone number does not exist";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message, style: TextStyle(color: Colors.red)),
            backgroundColor: Colors.white,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.message ?? "An error occurred",
              style: TextStyle(color: Colors.red),
            ),
            backgroundColor: Colors.white,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString(), style: TextStyle(color: Colors.red)),
          backgroundColor: Colors.white,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Form(
          key: _formKey, // Wrap with Form widget
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Sign In",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),
              // This field now accepts either email or phone number
              _buildTextField(
                "Email Address or Phone Number",
                controller: _identifierController,
                validator: (value) {
                  if (value!.isEmpty) return "Field cannot be empty";
                  return null;
                },
              ),
              _buildTextField(
                "Password",
                controller: _passwordController,
                obscureText: _obscurePassword,
                isPasswordField: true,
                validator: (value) {
                  if (value!.isEmpty) return "Password cannot be empty";
                  if (value.length < 6) {
                    return "Password must be at least 6 characters";
                  }
                  return null;
                },
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
              SizedBox(height: 10),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: loginUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text(
                      "Log In",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignupScreen()),
                  );
                },
                child: Text.rich(
                  TextSpan(
                    text: "Don’t Have An Account? ",
                    style: TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: "Sign Up",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label, {
    bool obscureText = false,
    required TextEditingController controller,
    String? Function(String?)? validator,
    bool isPasswordField = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator, // Validate field
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2.0),
          ),
          // Show/hide password icon for password fields
          suffixIcon:
              isPasswordField
                  ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  )
                  : null,
        ),
      ),
    );
  }
}

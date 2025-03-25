import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true; // Toggle for password visibility
  bool _obscureConfirmPassword = true; // Toggle for confirm password visibility

  void registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Create user in Firebase Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      // Save user details in Firestore
      await _firestore.collection("users").doc(userCredential.user!.uid).set({
        "name": _nameController.text.trim(),
        "email": _emailController.text.trim(),
        "phone": _phoneController.text.trim(),
        "uid": userCredential.user!.uid,
        "created_at": FieldValue.serverTimestamp(),
      });

      setState(() => _isLoading = false);

      // Navigate to Home Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Email already exists",
              style: TextStyle(color: Colors.red),
            ),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Sign Up",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 30),
                _buildTextField(
                  label: "Full Names",
                  controller: _nameController,
                  validator:
                      (value) => value!.isEmpty ? "Name is required" : null,
                ),
                _buildTextField(
                  label: "Phone Number",
                  controller: _phoneController,
                  validator:
                      (value) =>
                          value!.isEmpty ? "Phone number is required" : null,
                ),
                _buildTextField(
                  label: "Email Address",
                  controller: _emailController,
                  validator: (value) {
                    if (value!.isEmpty) return "Email is required";
                    if (!RegExp(
                      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
                    ).hasMatch(value)) {
                      return "Enter a valid email";
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  label: "Password",
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  isPasswordField: true,
                  validator: (value) {
                    if (value!.isEmpty) return "Password is required";
                    if (value.length < 6) {
                      return "Password must be at least 6 characters";
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  label: "Confirm Password",
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  isPasswordField: true,
                  validator: (value) {
                    if (value!.isEmpty) return "Confirm password is required";
                    if (value != _passwordController.text) {
                      return "Passwords do not match";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                      onPressed: registerUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text(
                        "Next",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: Text.rich(
                    TextSpan(
                      text: "Already Have An Account? ",
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: "Sign In",
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
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    bool isPasswordField = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 1.5),
            borderRadius: BorderRadius.circular(10),
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
                        if (label == "Password") {
                          _obscurePassword = !_obscurePassword;
                        } else {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        }
                      });
                    },
                  )
                  : null,
        ),
      ),
    );
  }
}

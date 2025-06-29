import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'sign_up_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _errorMsg;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _errorMsg = null;
    });
    try {
      await AuthService().signIn(
        _emailCtrl.text.trim(),
        _passCtrl.text,
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Timeout');
      });
      // successful sign-in will be handled by the StreamBuilder in main
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No account found for that email.';
          break;
        case 'wrong-password':
          message = 'Incorrect password.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'user-disabled':
          message = 'This user account has been disabled.';
          break;
        default:
          message = 'Authentication failed. Please try again.';
      }
      setState(() => _errorMsg = message);
    } on TimeoutException {
      setState(() => _errorMsg = 'Request timed out. Check your connection.');
    } catch (_) {
      setState(() => _errorMsg = 'An unexpected error occurred.');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: width * 0.1, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_errorMsg != null) ...[
                Text(_errorMsg!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  return regex.hasMatch(value) ? null : 'Enter a valid email';
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  return value.length >= 6
                      ? null
                      : 'Password must be at least 6 characters';
                },
              ),
              const SizedBox(height: 24),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      child: const Text('Sign In'),
                    ),
                  ),
                  if (_loading) const CircularProgressIndicator(),
                ],
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _loading
                    ? null
                    : () => Navigator.pushNamed(
                          context, SignUpScreen.routeName),
                child: const Text('Create an account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
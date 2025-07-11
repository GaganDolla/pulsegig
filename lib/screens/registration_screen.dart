import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/home_screen.dart';
import '../services/auth_service.dart';
import 'clinic/clinic_dashboard_screen.dart';
import 'professional/professional_dashboard_screen.dart';

/// A step-by-step registration wizard for both medical offices and professionals.
class RegistrationScreen extends StatefulWidget {
  static const routeName = '/register';
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final PageController _pageController = PageController();
  int _pageIndex = 0;
  final _accountFormKey = GlobalKey<FormState>();
  final _profileFormKey = GlobalKey<FormState>();

  // Controllers for all fields
  final TextEditingController _roleCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _credentialsCtrl = TextEditingController();
  String? _province;
  final TextEditingController _postalCtrl = TextEditingController();
  final TextEditingController _businessCtrl = TextEditingController();
  final TextEditingController _streetCtrl = TextEditingController();
  final TextEditingController _cityCtrl   = TextEditingController();
  bool _termsAccepted = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _roleCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _credentialsCtrl.dispose();
    _postalCtrl.dispose();
    _businessCtrl.dispose();
    _streetCtrl.dispose();
    _cityCtrl.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration (${_pageIndex + 1}/4)'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // PageView
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              onPageChanged: (index) => setState(() => _pageIndex = index),
              children: [
                // Page 1: Role selection
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('I\'m registering as a:', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              onPressed: () {
                                setState(() {
                                  _roleCtrl.text = 'professional';
                                  _error = null;
                                });
                                _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                              },
                              child: Text('Medical Professional'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              onPressed: () {
                                setState(() {
                                  _roleCtrl.text = 'office';
                                  _error = null;
                                });
                                _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                              },
                              child: Text('Medical Clinic'),
                            ),
                          ),
                        ],
                      ),
                      if (_error != null && _roleCtrl.text.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(_error!, style: const TextStyle(color: Colors.red)),
                        ),
                    ],
                  ),
                ),

                // Page 2: Account credentials
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _accountFormKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextFormField(
                          controller: _emailCtrl,
                          decoration: const InputDecoration(labelText: 'Email'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => v != null && v.contains('@') ? null : 'Enter a valid email',
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passCtrl,
                          decoration: const InputDecoration(labelText: 'Password'),
                          obscureText: true,
                          validator: (v) => v != null && v.length >= 6 ? null : 'Min 6 characters',
                        ),
                      ],
                    ),
                  ),
                ),

                // Page 3: Basic profile
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _profileFormKey,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameCtrl,
                            decoration: InputDecoration(
                              labelText: _roleCtrl.text == 'professional' ? 'Your Full Name' : 'Clinic Name',
                            ),
                            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _streetCtrl,
                            decoration: const InputDecoration(labelText: 'Street Address'),
                            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _cityCtrl,
                            decoration: const InputDecoration(labelText: 'City'),
                            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _province,
                            decoration: const InputDecoration(labelText: 'Province / State'),
                            items: ['ON','QC','BC','AB','MB','SK','NS','NB','NL','PE']
                                .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                                .toList(),
                            onChanged: (v) => setState(() => _province = v),
                            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _postalCtrl,
                            decoration: const InputDecoration(labelText: 'Postal / ZIP Code'),
                            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                          ),
                          if (_roleCtrl.text == 'professional') ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _credentialsCtrl,
                              decoration: const InputDecoration(labelText: 'Credentials'),
                              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                            ),
                          ] else ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _businessCtrl,
                              decoration: const InputDecoration(labelText: 'Business Registration #'),
                              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                // Page 4: Terms & submit
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            '''
PulseGig Terms of Service

1. Data Usage
   We collect and store your information securely in Firebase Firestore.
2. User Obligations
   You agree to provide accurate information and abide by local regulations.
3. Payments
   You will complete Stripe onboarding to receive payouts.
4. Privacy
   We do not share your personal data with third parties outside of Stripe as necessary.
''',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: _termsAccepted,
                            onChanged: (v) => setState(() => _termsAccepted = v!),
                          ),
                          const Expanded(child: Text('I agree to the Terms and Privacy Policy')),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Dots indicator
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _pageIndex == i ? 12 : 8,
                  height: _pageIndex == i ? 12 : 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _pageIndex == i ? Theme.of(context).primaryColor : Colors.grey,
                  ),
                );
              }),
            ),
          ),

          if (_pageIndex > 0)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_pageIndex > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        ),
                        child: const Text('Back'),
                      ),
                    ),
                  if (_pageIndex > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        // page-specific validation...
                        if (_pageIndex == 3) {
                          if (!_termsAccepted) return;
                          setState(() => _loading = true);
                          print('🚀 Starting registration flow');
                          try {
                            // 1) Sign up
                            final userCred = await AuthService().signUp(
                              _emailCtrl.text.trim(),
                              _passCtrl.text,
                            );
                            final user = userCred.user;
                            if (user == null) {
                              print('❌ signUp returned null user');
                              setState(() => _error = 'Registration failed: no user returned');
                              return;
                            }
                            print('✔️ Auth user created: uid=${user.uid}');

                            // 2) Write Firestore profile
                            try {
                              print('→ Writing Firestore profile for ${user.uid}');
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user.uid)
                                  .set({
                                'role': _roleCtrl.text,
                                'email': user.email,
                                'name': _nameCtrl.text.trim(),
                                'street': _streetCtrl.text.trim(),
                                'city': _cityCtrl.text.trim(),
                                'province': _province,
                                'postal': _postalCtrl.text.trim(),
                                'credentials': _roleCtrl.text == 'professional'
                                    ? _credentialsCtrl.text.trim()
                                    : null,
                                'businessRegistration': _roleCtrl.text == 'office'
                                    ? _businessCtrl.text.trim()
                                    : null,
                                'createdAt': FieldValue.serverTimestamp(),
                              });
                              print('✔️ Firestore write succeeded');
                            } catch (e, st) {
                              print('❌ Firestore write failed: $e\n$st');
                              setState(() => _error = 'Unable to save profile: $e');
                              return;
                            }

                            // 3) Navigate
                            if (_roleCtrl.text == 'professional') {
                              Navigator.pushReplacementNamed(
                                context,
                                ProfessionalDashboardScreen.routeName,
                              );
                            } else {
                              Navigator.pushReplacementNamed(
                                context,
                                ClinicDashboardScreen.routeName,
                              );
                            }
                          } catch (e, st) {
                            print('❌ Registration flow error: $e\n$st');
                            setState(() => _error = 'Registration error: $e');
                          } finally {
                            setState(() => _loading = false);
                          }
                          return;
                        }
                        // Advance pages
                        if (_pageIndex < 3) {
                          _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                        }
                      },
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(_pageIndex == 3 ? 'Finish' : 'Next'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
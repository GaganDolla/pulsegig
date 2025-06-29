import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  /// Stream of auth changes (signed in/out)
  Stream<User?> get userChanges => _auth.authStateChanges();

  /// Sign in with email & password
  Future<User?> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return cred.user;
  }

  /// Register a new account
  Future<User?> signUp(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return cred.user;
  }

  /// Sign out
  Future<void> signOut() => _auth.signOut();
}
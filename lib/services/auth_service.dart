// File: lib/services/auth_service.dart
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth;

  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth
          .signInWithEmailAndPassword(
            email: email.trim(),
            password: password,
          )
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw 'Connection timed out. Please check your internet connection.';
    } on FirebaseAuthException catch (e) {
      throw getFriendlyErrorMessage(e.code);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          )
          .timeout(const Duration(seconds: 15));
      return credential;
    } on TimeoutException {
      throw 'Connection timed out. Please check your internet connection.';
    } on FirebaseAuthException catch (e) {
      throw getFriendlyErrorMessage(e.code);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  Future<void> resendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user
            .sendEmailVerification()
            .timeout(const Duration(seconds: 15));
      }
    } on TimeoutException {
      throw 'Connection timed out. Please check your internet connection.';
    } on FirebaseAuthException catch (e) {
      throw getFriendlyErrorMessage(e.code);
    } catch (e) {
      throw 'Failed to send verification email. Please try again.';
    }
  }

  Future<bool> reloadAndCheckVerification() async {
    try {
      await _auth.currentUser
          ?.reload()
          .timeout(const Duration(seconds: 10));
      return _auth.currentUser?.emailVerified ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Failed to sign out. Please try again.';
    }
  }

  static String getFriendlyErrorMessage(String code) {
    switch (code) {
      case 'invalid-credential':
        return 'Invalid email or password. Please verify your credentials.';
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please check and try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'The password provided is too weak. It must be at least 6 characters.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network connection error. Please check your internet connection.';
      default:
        return 'Authentication failed. Please check your details and try again.';
    }
  }
}

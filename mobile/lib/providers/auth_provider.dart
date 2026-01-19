import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Since we cannot easily init Firebase in this restricted env without google-services.json,
// we will mock the auth logic but keep the structure correct for the user.

class AuthProvider with ChangeNotifier {
  FirebaseAuth? _auth;

  User? _user;
  User? get user => _user;

  // Mock flag
  bool _isMock = false;
  // Mock User State
  bool _isMockAuthenticated = false;

  bool get isAuthenticated => _isMock ? _isMockAuthenticated : _user != null;

  AuthProvider() {
    // Check if Firebase was successfully initialized
    if (Firebase.apps.isNotEmpty) {
       _auth = FirebaseAuth.instance;
       _auth!.authStateChanges().listen((u) {
         _user = u;
         notifyListeners();
       });
    } else {
       print("⚠️ AuthProvider running in MOCK mode (Firebase not init)");
       _isMock = true;
    }
  }

  Future<bool> signIn(String email, String password) async {
    if (_isMock) {
       // Mock Login Success
       await Future.delayed(const Duration(seconds: 1));
       _isMockAuthenticated = true;
       notifyListeners();
       return true;
    }

    try {
      await _auth!.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      print("Auth Error: $e");
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String name) async {
    if (_isMock) {
       // Mock SignUp Success
       await Future.delayed(const Duration(seconds: 1));
       _isMockAuthenticated = true;
       notifyListeners();
       return true;
    }

    try {
      UserCredential cred = await _auth!.createUserWithEmailAndPassword(email: email, password: password);
      if (cred.user != null) {
        await cred.user!.updateDisplayName(name);
        await cred.user!.updatePhotoURL('https://ui-avatars.com/api/?name=$name');
      }
      return true;
    } catch (e) {
      print("Sign Up Error: $e");
      return false;
    }
  }

  Future<void> signOut() async {
    if (_isMock) {
       _isMockAuthenticated = false;
       notifyListeners();
       return;
    }
    await _auth!.signOut();
  }
}

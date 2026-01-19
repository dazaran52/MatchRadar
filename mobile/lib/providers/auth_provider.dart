import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// Since we cannot easily init Firebase in this restricted env without google-services.json,
// we will mock the auth logic but keep the structure correct for the user.
// In a real app, un-comment the Firestore lines.

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  User? get user => _user;

  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _auth.authStateChanges().listen((u) {
      _user = u;
      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      print("Auth Error: $e");
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String name) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      if (cred.user != null) {
        // Mock saving to Firestore
        // await _firestore.collection('users').doc(cred.user!.uid).set({
        //   'name': name,
        //   'email': email,
        //   'photoUrl': 'https://ui-avatars.com/api/?name=$name',
        //   'createdAt': FieldValue.serverTimestamp(),
        // });

        // Update local display name
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
    await _auth.signOut();
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream of auth state changes
  Stream<User?> get user => _auth.authStateChanges();

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Register with email and password
  Future<UserCredential?> registerWithEmail(String email, String password, String name, String userType) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = result.user;

      // Create a new document for the user in firestore
      if (user != null) {
        await _db.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'email': email,
          'role': userType,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return result;
    } catch (e) {
      print("Registration error: $e");
      rethrow;
    }
  }

  // Login with email and password
  Future<UserCredential?> loginWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print("Login error: $e");
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("Sign out error: $e");
    }
  }
}

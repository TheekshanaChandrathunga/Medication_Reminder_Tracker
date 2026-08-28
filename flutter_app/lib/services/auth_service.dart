import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'database_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Simulation flag linked to DatabaseService
  bool get isSimulation => DatabaseService.isSimulation;

  Stream<User?> get user {
    if (isSimulation) {
      // Return a stream that always says we are logged in
      return Stream.value(null); 
    }
    return _auth.authStateChanges();
  }

  String? get currentUserId {
    if (isSimulation) return "simulated_user_123";
    return _auth.currentUser?.uid;
  }

  Future<UserCredential?> registerWithEmail(String email, String password, String name, String userType) async {
    if (isSimulation) return null;
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      if (result.user != null) {
        await _db.collection('users').doc(result.user!.uid).set({
          'uid': result.user!.uid,
          'name': name,
          'email': email,
          'role': userType,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential?> loginWithEmail(String email, String password) async {
    if (isSimulation) return null;
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    if (isSimulation) return;
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    if (isSimulation) return;
    await _auth.signOut();
  }
}

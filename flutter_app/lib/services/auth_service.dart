import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'database_service.dart';

class AuthService {
  // Check if Firebase is actually initialized without triggering [core/no-app]
  bool get isSimulation => Firebase.apps.isEmpty;

  // We use getters for instances to ensure they are only called when needed
  // and after initialization is checked.
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  Stream<User?> get user {
    if (isSimulation) return Stream.value(null);
    return _auth.authStateChanges();
  }

  String? get currentUserId {
    if (isSimulation) return "simulated_user_123";
    try {
      return _auth.currentUser?.uid;
    } catch (_) {
      return "simulated_user_123";
    }
  }

  Future<UserCredential?> loginWithEmail(String email, String password) async {
    if (isSimulation) return null;
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential?> registerWithEmail(String email, String password, String name, String userType) async {
    if (isSimulation) return null;
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
  }

  Future<void> resetPassword(String email) async {
    if (isSimulation) return;
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    if (isSimulation) return;
    await _auth.signOut();
  }
}

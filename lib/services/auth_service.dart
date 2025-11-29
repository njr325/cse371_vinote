import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream pour suivre l'état de l'utilisateur (connecté ou non)
  Stream<User?> get user => _auth.authStateChanges();

  // --- 1. Inscription ---
  Future<User?> signUp({required String email, required String password}) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // OPTIONNEL : Créer un document utilisateur dans Firestore
      if (credential.user != null) {
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'email': email,
          'createdAt': Timestamp.now(),
        });
      }

      return credential.user;
    } on FirebaseAuthException catch (e) {
      // Gérer les erreurs (email déjà utilisé, mot de passe faible, etc.)
      print("Erreur d'inscription: ${e.message}");
      return null;
    }
  }

  // --- 2. Connexion ---
  Future<User?> signIn({required String email, required String password}) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      print("Erreur de connexion: ${e.message}");
      return null;
    }
  }

  // --- 3. Déconnexion ---
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
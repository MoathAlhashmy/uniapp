import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod/riverpod.dart';
import 'package:uniapp/models/user.dart' as model;
import 'package:uniapp/resources/storage_methods.dart';

class AuthController {
  final AuthMethods authRepository;
  final ProviderRef ref;

  AuthController({
    required this.authRepository,
    required this.ref,
  });

  Future<model.User?> getUserData() async {
    model.User? user = await authRepository.getCurrentUserData();
    return user;
  }
}

class AuthMethods {
  void userDataAuthProvider() {}
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;
    DocumentSnapshot snap =
        await _firestore.collection('users').doc(currentUser.uid).get();
    return model.User.formSnap(snap);
  }

  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    Uint8List? file,
  }) async {
    try {
      final normalizedEmail = email.trim();
      final normalizedUsername = username.trim();
      final normalizedBio = bio.trim();

      if (normalizedEmail.isEmpty ||
          password.isEmpty ||
          normalizedUsername.isEmpty ||
          normalizedBio.isEmpty) {
        return "Please enter all the fields";
      }

      final cred = await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      final user = model.User(
        username: normalizedUsername,
        uid: cred.user!.uid,
        email: normalizedEmail,
        bio: normalizedBio,
        photoUrl: '',
        followers: [],
        following: [],
      );

      await _firestore
          .collection('users')
          .doc(cred.user!.uid)
          .set(user.toJson());

      if (file != null) {
        try {
          final photoUrl = await StorageMethods()
              .uploadImageToStorage('profilePics', file, false);
          await _firestore
              .collection('users')
              .doc(cred.user!.uid)
              .update({'photoUrl': photoUrl});
        } on FirebaseException catch (e) {
          return 'Account created, but profile image upload failed: '
              '${e.message ?? e.code}';
        }
      }

      return "success";
    } on FirebaseAuthException catch (e) {
      return _authErrorMessage(e.code);
    } on FirebaseException catch (e) {
      return e.message ?? "Firebase error: ${e.code}";
    } catch (e) {
      return e.toString();
    }
  }

  String _authErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'operation-not-allowed':
        return 'Email/password sign-up is not enabled in Firebase Authentication.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      default:
        return 'Authentication error: $code';
    }
  }

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {}
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<model.User?> getCurrentUserData() async {
    var userData =
        await _firestore.collection('users').doc(_auth.currentUser?.uid).get();

    model.User? user;
    if (userData.data() != null) {
      user = model.User.formMap(userData.data()!);
    }
    return user;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> sendEmailVerificationLink() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      print(e.toString());
    }
  }
}

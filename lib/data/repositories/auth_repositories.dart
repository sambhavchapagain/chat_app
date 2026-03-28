import 'package:firebase_auth/firebase_auth.dart';

import '../serivices/firebase_auth_services.dart';

class AuthRepositories{
  final AuthService _authService = AuthService();
  User? get currentUser => _authService.currentUser;
  Future<UserCredential?> signInWithGoogle() async {
   return _authService.signInWithGoogle();

  }

  Future<UserCredential?> signInWithEmail({required String email, required String password}) async {
    return _authService.signInWithEmail(email: email, password: password);

  }

  Future<void> signOut() async {
    return _authService.signOut();

  }

  Future<void> sendPasswordResetEmail({required String email}) async {}

  Future<dynamic> signUpWithEmail({required String email, required String password, required String displayName}) async {
    return _authService.signUpWithEmail(email: email, password: password, displayName: displayName);


  }
}
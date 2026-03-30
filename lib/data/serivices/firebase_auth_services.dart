import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  User? get currentUser => _auth.currentUser;
  // Stream that _AuthChangeNotifier listens to
  Stream<User?> get userChanges => _auth.authStateChanges();

  // ── Google Sign-In ────────────────────────────────────────────────────
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // 1. Trigger the Google account picker
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // User cancelled the picker
      if (googleUser == null) return null;

      // 2. Get auth details from the Google account
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      // 3. Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Sign in to Firebase — this triggers authStateChanges()
      //    which fires _AuthChangeNotifier → GoRouter redirects to /home
      return await _auth.signInWithCredential(credential);

    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
    // authStateChanges fires again → GoRouter redirects to /login
  }
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
     return  await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

  }

  // ── Email Sign-Up (Register) ──────────────────────────────────────────
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Save display name to Firebase user profile
    await credential.user?.updateDisplayName(displayName);
    return credential;
  }

  // ── Forgot Password ───────────────────────────────────────────────────
  Future<void> sendPasswordResetEmail({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
  }




import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/serivices/firebase_auth_services.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc(this._authService) : super(const AuthState()) {
    on<GoogleSignInRequested>(_onGoogleSignIn);
    on<EmailSignInRequested>(_onEmailSignIn);
    on<EmailSignUpRequested>(_onEmailSignUp);
    on<ForgotPasswordRequested>(_onForgotPassword);
    on<SignOutRequested>(_onSignOut);
    on<AuthCheckRequested>(_onAuthCheck);
  }

  // ── Google Sign-In ────────────────────────────────────────────────────
  Future<void> _onGoogleSignIn(
      GoogleSignInRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(state.copyWith(authStatus: AuthStatus.loading));
    try {
      final credential = await _authService.signInWithGoogle();
      if(credential != null) {
        emit(state.copyWith(
        authStatus: AuthStatus.authenticated,
        value: credential,
      ));
      }
      else {
        emit(state.copyWith(
          authStatus: AuthStatus.unauthenticated));

      }
    } catch (e) {
      emit(state.copyWith(
        authStatus: AuthStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  // ── Email & Password Sign-In ──────────────────────────────────────────
  Future<void> _onEmailSignIn(
      EmailSignInRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(state.copyWith(authStatus: AuthStatus.loading));
    try {
      final credential = await _authService.signInWithEmail(
        email: event.email,
        password: event.password,
      );
      if(credential != null) {
        emit(state.copyWith(
        authStatus: AuthStatus.authenticated,
        value: credential,
      ));
      }
      else {
        emit(state.copyWith(
          authStatus: AuthStatus.unauthenticated));

      }
    }  on FirebaseAuthException catch (e) {
      emit(state.copyWith(
        authStatus: AuthStatus.error,
        errorMessage: _handleFirebaseError(e.code),
      ));

    }catch (e) {
      emit(state.copyWith(
        authStatus: AuthStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
  String _handleFirebaseError(String code) {
    switch (code) {
    // ── Login errors ─────────────────────────────────────────────────
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password. Please try again';
      case 'invalid-credential':
        return 'Invalid email or password';
      case 'invalid-email':
        return 'Please enter a valid email address';
      case 'user-disabled':
        return 'This account has been disabled';

    // ── Register errors ──────────────────────────────────────────────
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'weak-password':
        return 'Password must be at least 6 characters';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled';

    // ── Google errors ────────────────────────────────────────────────
      case 'account-exists-with-different-credential':
        return 'Account exists with a different sign-in method';
      case 'popup-closed-by-user':
        return 'Sign-in cancelled';

    // ── Network errors ───────────────────────────────────────────────
      case 'network-request-failed':
        return 'No internet connection. Please check your network';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'timeout':
        return 'Request timed out. Please try again';

    // ── Token errors ─────────────────────────────────────────────────
      case 'expired-action-code':
        return 'This link has expired. Please request a new one';
      case 'invalid-action-code':
        return 'This link is invalid. Please request a new one';

      default:
        return 'Something went wrong. Please try again';
    }
  }
  // ── Sign Out ──────────────────────────────────────────────────────────
  Future<void> _onSignOut(
      SignOutRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(state.copyWith(logoutStatus: LogoutStatus.loading));
    try {
      await _authService.signOut();
      emit(state.copyWith(
        logoutStatus: LogoutStatus.logoutSucess,
        value: null,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        logoutStatus: LogoutStatus.fail,
        errorMessage: e.toString(),
      ));
    }
  }

  // ── Check Auth on App Start ───────────────────────────────────────────
  Future<void> _onAuthCheck(
      AuthCheckRequested event,
      Emitter<AuthState> emit,
      ) async {
    final user = _authService.currentUser;
    if (user != null) {
      emit(state.copyWith(authStatus: AuthStatus.authenticated));
    } else {
      emit(state.copyWith(authStatus: AuthStatus.unauthenticated));
    }
  }



Future<void> _onEmailSignUp(
      EmailSignUpRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(state.copyWith(authStatus: AuthStatus.loading));
    try {
      final credential = await _authService.signUpWithEmail(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
      );
      emit(state.copyWith(
        authStatus: AuthStatus.authenticated,
        value: credential,
      ));
    }on FirebaseException catch(e){
      emit(state.copyWith(
        authStatus: AuthStatus.error,
        errorMessage: _handleFirebaseError(e.code)
      ));
    }
    catch (e) {
      emit(state.copyWith(
        authStatus: AuthStatus.error,
    ));
    }
  }

  // ── Forgot Password ───────────────────────────────────────────────────
  Future<void> _onForgotPassword(
      ForgotPasswordRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(state.copyWith(authStatus: AuthStatus.loading));
    try {
      await _authService.sendPasswordResetEmail(email: event.email);
      emit(state.copyWith(
        authStatus: AuthStatus.unauthenticated,
        errorMessage: 'Password reset email sent',  // used as success msg
      ));
    } catch (e) {
      emit(state.copyWith(
        authStatus: AuthStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

}
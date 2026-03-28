import 'package:bloc/bloc.dart';
import 'package:chatapp/data/repositories/auth_repositories.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepositories _authRepositories;

  AuthBloc(this._authRepositories) : super(const AuthState()) {
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
      final credential = await _authRepositories.signInWithGoogle();
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
      final credential = await _authRepositories.signInWithEmail(
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
    } catch (e) {
      emit(state.copyWith(
        authStatus: AuthStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  // ── Sign Out ──────────────────────────────────────────────────────────
  Future<void> _onSignOut(
      SignOutRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(state.copyWith(logoutStatus: LogoutStatus.loading));
    try {
      await _authRepositories.signOut();
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
    final user = _authRepositories.currentUser;
    if (user != null) {
      emit(state.copyWith(authStatus: AuthStatus.authenticated));
    } else {
      emit(state.copyWith(authStatus: AuthStatus.unauthenticated));
    }
  }

  // ── Firebase error messages (user-friendly) ───────────────────────────
  String _mapFirebaseError(String error) {
    if (error.contains('user-not-found'))    return 'No account found with this email';
    if (error.contains('wrong-password'))    return 'Incorrect password';
    if (error.contains('email-already-in-use')) return 'Email already registered';
    if (error.contains('weak-password'))     return 'Password must be at least 6 characters';
    if (error.contains('invalid-email'))     return 'Invalid email address';
    if (error.contains('network-request-failed')) return 'No internet connection';
    return 'Something went wrong. Please try again';
  }

Future<void> _onEmailSignUp(
      EmailSignUpRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(state.copyWith(authStatus: AuthStatus.loading));
    try {
      final credential = await _authRepositories.signUpWithEmail(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
      );
      emit(state.copyWith(
        authStatus: AuthStatus.authenticated,
        value: credential,
      ));
    } catch (e) {
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
      await _authRepositories.sendPasswordResetEmail(email: event.email);
      emit(state.copyWith(
        authStatus: AuthStatus.unauthenticated,
        errorMessage: 'Password reset email sent',  // used as success msg
      ));
    } catch (e) {
      emit(state.copyWith(
        authStatus: AuthStatus.error,
      ));
    }
  }

}
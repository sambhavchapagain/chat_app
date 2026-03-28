part of 'auth_bloc.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading, error }

enum LogoutStatus { initial, loading,logoutSucess,fail }

class AuthState extends Equatable {
  final AuthStatus authStatus;
  final LogoutStatus logoutStatus;
  final UserCredential? value;
  final String? errorMessage;

  const AuthState({
    this.authStatus = AuthStatus.initial,
    this.logoutStatus = LogoutStatus.initial,
    this.value,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? authStatus,
    LogoutStatus? logoutStatus,
    UserCredential? value,
    String? errorMessage,
  }) {
    return AuthState(
      logoutStatus: logoutStatus ?? this.logoutStatus,
      authStatus: authStatus ?? this.authStatus,
      value: value ?? this.value,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [authStatus, value, errorMessage, logoutStatus];
}

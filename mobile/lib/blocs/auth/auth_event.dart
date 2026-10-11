import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {}

class LoginEvent extends AuthEvent {
  final String username;
  final String password;

  const LoginEvent(this.username, this.password);

  @override
  List<Object?> get props => [username, password];
}

class RegisterEvent extends AuthEvent {
  final String username;
  final String email;
  final String password;
  final String? fullName;

  const RegisterEvent({
    required this.username,
    required this.email,
    required this.password,
    this.fullName,
  });

  @override
  List<Object?> get props => [username, email, password, fullName];
}

class LogoutEvent extends AuthEvent {}


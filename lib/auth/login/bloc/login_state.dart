import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {}

class LoginFailure extends LoginState {
  final String message;

  const LoginFailure(this.message);

  @override
  List<Object> get props => [message];
}

class GoogleLoginLoading extends LoginState {}

class GoogleLoginSuccess extends LoginState {}

class GoogleLoginFailure extends LoginState {
  final String message;
  const GoogleLoginFailure(this.message);

  @override
  List<Object> get props => [message];
}


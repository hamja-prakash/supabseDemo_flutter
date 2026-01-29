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

class AppleLoginLoading extends LoginState {}

class AppleLoginSuccess extends LoginState {}

class AppleLoginFailure extends LoginState {
  final String message;
  const AppleLoginFailure(this.message);

  @override
  List<Object> get props => [message];
}

class MagicLinkLoading extends LoginState {}
class MagicLinkSuccess extends LoginState {}
class MagicLinkFailure extends LoginState {
  final String message;
  const MagicLinkFailure(this.message);
}

class OTPLoading extends LoginState {}
class OTPSuccess extends LoginState {}
class OTPFailure extends LoginState {
  final String message;
  const OTPFailure(this.message);
}

class OTPVerifyLoading extends LoginState {}
class OTPVerifySuccess extends LoginState {}
class OTPVerifyFailure extends LoginState {
  final String message;
  const OTPVerifyFailure(this.message);
}

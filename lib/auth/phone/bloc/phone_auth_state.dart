import 'package:equatable/equatable.dart';

abstract class PhoneAuthState extends Equatable {
  const PhoneAuthState();

  @override
  List<Object> get props => [];
}

class PhoneAuthInitial extends PhoneAuthState {}

class PhoneAuthLoading extends PhoneAuthState {}

class PhoneAuthCodeSent extends PhoneAuthState {}

class PhoneAuthVerified extends PhoneAuthState {}

class PhoneAuthFailure extends PhoneAuthState {
  final String message;

  const PhoneAuthFailure(this.message);

  @override
  List<Object> get props => [message];
}

class PhoneAuthVerifyLoading extends PhoneAuthState {}

class PhoneAuthVerifyFailure extends PhoneAuthState {
  final String message;

  const PhoneAuthVerifyFailure(this.message);

  @override
  List<Object> get props => [message];
}

part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class CheckLogin extends LoginEvent {}

class SetLogin extends LoginEvent {
  final String number;
  SetLogin(this.number);

  @override
  List<Object> get props => [number];
}

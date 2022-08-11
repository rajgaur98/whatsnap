part of 'login_bloc.dart';

abstract class LoginState extends Equatable {
  const LoginState();
  
  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {}

class LoggedIn extends LoginState {
  final String number;
  LoggedIn(this.number);

  @override
  List<Object> get props => [number];
}

class NotLoggedIn extends LoginState {}

class LoggedInLoading extends LoginState {}

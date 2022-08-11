import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial());

  @override
  Stream<LoginState> mapEventToState(
    LoginEvent event,
  ) async* {
    if(event is CheckLogin) {
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      if(sharedPreferences.containsKey('number')) {
        yield LoggedIn(sharedPreferences.get('number'));
      }
      else {
        yield NotLoggedIn();
      }
    }
    if(event is SetLogin) {
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setString('number', event.number);
      yield LoggedIn(sharedPreferences.get('number'));
    }
  }
}

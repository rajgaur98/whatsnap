import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:whatsnap/services.dart';

part 'otp_event.dart';
part 'otp_state.dart';

class OtpBloc extends Bloc<OtpEvent, OtpState> {
  final Services _services;
  OtpBloc(this._services) : super(OtpInitial());

  @override
  Stream<OtpState> mapEventToState(
    OtpEvent event,
  ) async* {
    if(event is SendOtp) {
      yield OtpLoading();
      final res = await _services.sendOtp(event.number);
      if(res == null) {
        yield OtpError();
      }
      else {
        yield OtpSent(res);
      }
    }
    else if(event is VerifyOtp) {
      yield OtpLoading();
      final res = await _services.verifyOtp(event.sessionId, event.otp);
      if(res == true) {
        yield OtpVerified();
      }
      else {
        yield OtpInvalid();
      }
    }
  }
}

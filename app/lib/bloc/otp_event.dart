part of 'otp_bloc.dart';

abstract class OtpEvent extends Equatable {
  const OtpEvent();

  @override
  List<Object> get props => [];
}

class SendOtp extends OtpEvent {
  final String number;
  SendOtp(this.number);

  @override
  List<Object> get props => [number];
}

class VerifyOtp extends OtpEvent {
  final String sessionId;
  final String otp;
  VerifyOtp(this.sessionId, this.otp);

  @override
  List<Object> get props => [sessionId, otp];
}

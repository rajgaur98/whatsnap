part of 'otp_bloc.dart';

abstract class OtpState extends Equatable {
  const OtpState();
  
  @override
  List<Object> get props => [];
}

class OtpInitial extends OtpState {}

class OtpLoading extends OtpState {}

class OtpSent extends OtpState {
  final String sessionId;
  OtpSent(this.sessionId);

  @override
  List<Object> get props => [sessionId];
}

class OtpVerified extends OtpState {}

class OtpInvalid extends OtpState {}

class OtpError extends OtpState {}

class OtpLoggedIn extends OtpState {
  final String number;
  OtpLoggedIn(this.number);

  @override
  List<Object> get props => [number];
}

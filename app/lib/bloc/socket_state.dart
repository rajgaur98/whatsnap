part of 'socket_bloc.dart';

abstract class SocketState extends Equatable {
  const SocketState();
  
  @override
  List<Object> get props => [];
}

class SocketInitial extends SocketState {}

class SocketLoading extends SocketState {}

class SocketLoaded extends SocketState {}

class SocketLoginError extends SocketState {}

class SocketUserAlreadyExists extends SocketState {}

class SocketLoggedIn extends SocketState {
  final String username;
  final Map<String, List> chats;
  SocketLoggedIn(this.chats, {this.username});

  @override
  List<Object> get props => [chats, username];
}

class ReceiverExists extends SocketState {}

class ReceiverDoesntExist extends SocketState {}

class JoinedRoom extends SocketState {}

class JoinedRoomError extends SocketState {}

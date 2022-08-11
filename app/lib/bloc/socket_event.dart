part of 'socket_bloc.dart';

abstract class SocketEvent extends Equatable {
  const SocketEvent();

  @override
  List<Object> get props => [];
}

class SendMessage extends SocketEvent {
  final username;
  final msg;
  final event;
  SendMessage(this.username, this.msg, this.event);

  @override
  List<Object> get props => [username, msg, event];
}

class MessageReceived extends SocketEvent {
  final Map data;
  MessageReceived(this.data);

  @override
  List<Object> get props => [data];
}

class Join extends SocketEvent {
  final String username;
  Join(this.username);

  @override
  List<Object> get props => [username];
}

class UserAvailable extends SocketEvent {
  final String username;
  UserAvailable(this.username);

  @override
  List<Object> get props => [username];
}

class JoinRoom extends SocketEvent {
  final String roomName;
  JoinRoom(this.roomName);

  @override
  List<Object> get props => [roomName];
}

class UserAlreadyExists extends SocketEvent {}

class Typing extends SocketEvent {
  final String targetName;
  Typing(this.targetName);

  @override
  List<Object> get props => [targetName];
}

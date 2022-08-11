import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:encrypt/encrypt.dart';
import 'package:equatable/equatable.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:whatsnap/services.dart';

part 'socket_event.dart';
part 'socket_state.dart';

class Chat{
  final String room;
  final String username;
  final String msg;
  final String type;
  final DateTime date;
  Chat(this.room, this.username, this.msg, this.type, this.date);
}

class SocketBloc extends Bloc<SocketEvent, SocketState> {
  final IO.Socket _socket;
  final Services _services;
  Map<String, List> chats;
  String username;
  var key;
  var iv;
  var encrypter;
  SocketBloc(this._socket, this._services, this.chats) : super(SocketInitial());

  @override
  Stream<SocketState> mapEventToState(
    SocketEvent event,
  ) async* {
    if(event is Join){
      key = Key.fromUtf8('11111111111111110000000000000000');
      iv = IV.fromLength(16);
      encrypter = Encrypter(AES(key));
      this.username = event.username;
      yield SocketLoggedIn(chats, username: event.username);
    }
    if(event is UserAlreadyExists){
      yield SocketUserAlreadyExists();
    }
    if(event is JoinRoom) {
      yield SocketLoading();
      final res = await _services.joinRoom(this.username, event.roomName);
      if(res == null)
        yield SocketLoginError();
      else{
        if(res){
          yield JoinedRoom();
        }
        else
          yield JoinedRoomError();
      }
    }
    if(event is MessageReceived){
      Map<String, List> newChats = Map.from(chats);
      Map data = event.data;
      DateTime date;
      if(data['date'] != null){
        date = DateTime.parse(data['date']);
      }
      String room = data['room'];
      String username = data['username'];
      String msg = data['msg'];
      if(username != 'bot')
        msg = encrypter.decrypt(Encrypted.fromBase64(msg), iv: iv);
      String type = data['type'];
      if(!newChats.containsKey(room)){
        newChats[room] = [];
      }
      List newList = List.from(newChats[room]);
      newList.add(Chat(room, username, msg, type, date));
      newChats[room] = newList;
      chats = Map.from(newChats);
      yield SocketLoggedIn(newChats, username: this.username);
    }
    if(event is SendMessage){
      var msg = event.msg;
      msg = encrypter.encrypt(msg, iv: iv);
      print(msg.base64);
      if(event.event == 'privateChat'){
        List<String> list = event.username.split('-');
        String targetname = list[0] == username? list[1]: list[0];
        _socket.emit('privateChat', <String, String>{
          'msg': msg.base64,
          'targetname': targetname,
          'date': DateTime.now().toString()
        });
      }
      else{
        _socket.emit('chatMessage', <String, String>{
          'msg': msg.base64,
          'room': event.username,
          'date': DateTime.now().toString()
        });
      }
    }
    if(event is UserAvailable){
      yield SocketLoading();
      print(this.username);
      final res = await _services.receiver(event.username, this.username);
      if(res == null)
        yield SocketLoginError();
      else{
        if(res){
          yield ReceiverExists();
        }
        else
          yield ReceiverDoesntExist();
      }
    }
    if(event is JoinRoom){
      _socket.emit('joinRoom', event.roomName);
    }
  }
}

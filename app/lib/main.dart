import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:whatsnap/bloc/login_bloc.dart';
import 'package:whatsnap/bloc/socket_bloc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:whatsnap/services.dart';
import 'package:whatsnap/wrapper.dart';

void main() async {
  final String _url = 'https://whatsnap.herokuapp.com/';
  final String _localhost = 'http://10.0.2.2:3000';
  IO.Socket socket = IO.io(_localhost, <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': false,
  });
  socket.connect();
  Map<String, List> chats = Map();
  runApp(
    BlocProvider(
      create: (context) => SocketBloc(socket, Services(), chats),
      child: MyApp(socket),
    )
  );
}

class MyApp extends StatefulWidget {
  final IO.Socket socket;
  MyApp(this.socket);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    widget.socket.on('message', (data) => {
      Provider.of<SocketBloc>(context, listen: false).add(MessageReceived(data)),
    });
    return MaterialApp(
      home: BlocProvider(
        create: (context) => LoginBloc(),
        child: Wrapper(widget.socket),
      )
    );
  }

  @override
  void dispose() {
    widget.socket.dispose();
    super.dispose();
  }
}

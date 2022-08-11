import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:whatsnap/bloc/socket_bloc.dart';
import 'package:whatsnap/chat_list.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class Login extends StatefulWidget {
  final IO.Socket socket;
  Login(this.socket);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  TextEditingController _controller;
  bool isUsernameEmpty;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    isUsernameEmpty = false;
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SocketBloc, SocketState>(
      builder: (context, state) {
        widget.socket.on('userLoggedIn', (data) => {
          Provider.of<SocketBloc>(context, listen: false).add(Join(_controller.text)),
          Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => ChatList(_controller.text, widget.socket),
          ))
        });
        widget.socket.on('userAlreadyExists', (data) => {
          Provider.of<SocketBloc>(context, listen: false).add(UserAlreadyExists()),
        });
        return _buildScaffold(state);
      },
    );
  }

  Scaffold _buildScaffold(SocketState state) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if(_controller.text.length > 0) {
            setState(() {
              isUsernameEmpty = false;
            });
            widget.socket.emit('join', _controller.text);
          }
          else {
            setState(() {
              isUsernameEmpty = true;
            });
          }
        },
        child: Icon(
          Icons.navigate_next,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 2),
                height: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  border: Border.all(
                    color: Colors.blue,
                  ),
                ),
                child: TextFormField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Username',
                    border: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none
                  ),
                ),
              ),
              state is SocketUserAlreadyExists? SizedBox(height: 20.0,): Container(),
              state is SocketUserAlreadyExists? Text(
                'Username already taken! Please try another.',
                style: TextStyle(
                  color: Colors.red,
                ),
              ): Container(),
              isUsernameEmpty? SizedBox(height: 20.0,): Container(),
              isUsernameEmpty? Text(
                'Username cant be empty!',
                style: TextStyle(
                  color: Colors.red,
                ),
              ): Container(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

}

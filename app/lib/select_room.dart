import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:whatsnap/bloc/socket_bloc.dart';
import 'package:whatsnap/chat_page.dart';
import 'package:whatsnap/loading.dart';

class SelectRoom extends StatefulWidget {
  final String username;
  SelectRoom(this.username);

  @override
  _SelectRoomState createState() => _SelectRoomState();
}

class _SelectRoomState extends State<SelectRoom> {

  TextEditingController _roomController = new TextEditingController();
  bool isRoomEmpty = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocketBloc, SocketState>(
      listener: (context, state) {
        if(state is JoinedRoom) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => ChatPage(_roomController.text, Map<String, String>()),
          ));
        }
      },
      builder: (context, state) {
        if(state is SocketLoading)
          return LoadingScreen();
        else
          return buildScaffold(context, state);
      },
    );
  }

  Scaffold buildScaffold(BuildContext context, SocketState state) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if(_roomController.text.length > 0) {
            setState(() {
              isRoomEmpty = false;
            });
            Provider.of<SocketBloc>(context, listen: false).add(JoinRoom(_roomController.text));
          }
          else {
            setState(() {
              isRoomEmpty = true;
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
                  controller: _roomController,
                  decoration: InputDecoration(
                    hintText: 'Enter room name',
                    border: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none
                  ),
                ),
              ),
              SizedBox(height: 20.0,),
              state is JoinedRoomError? Text(
                'Some error occured :(',
                style: TextStyle(
                  color: Colors.red,
                ),
              ): Container(),
              isRoomEmpty? Text(
                'Enter a room name!',
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
}

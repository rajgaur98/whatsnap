import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:whatsnap/bloc/socket_bloc.dart';


class ChatPage extends StatefulWidget {
  final String username;
  final Map<String, String> contactMapping;
  ChatPage(this.username, this.contactMapping);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  ScrollController _scrollController = new ScrollController();
  List<Widget> _chats;
  TextEditingController _msg = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SocketBloc, SocketState>(
      builder: (context, state) {
        if(state is SocketLoggedIn){
          _chats = [];
          if(state.chats[widget.username] != null){
            state.chats[widget.username].forEach((element) {
              DateTime date = element.date;
              String botMsg;
              if(element.username == 'bot') {
                botMsg = element.msg;
                botMsg = botMsg.replaceAll(botMsg.split(" ")[0], widget.contactMapping[botMsg.split("")[0]] ?? botMsg.split(" ")[0]);
              }
              _chats.add(
                element.username == 'bot'? Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  margin: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.blue[200],
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                  child: Text(
                    botMsg,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                )
                :Align(
                  alignment: element.username == state.username? Alignment.centerRight: Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    margin: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0), bottomRight: element.username == state.username? Radius.circular(0.0): Radius.circular(10.0), bottomLeft: element.username == state.username? Radius.circular(10.0): Radius.circular(0.0)),
                    ),
                    child: element.type == 'room' && element.username != state.username? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.contactMapping[element.username] ?? element.username,
                          style: TextStyle(
                            color: Colors.green[100],
                            fontSize: 17.0
                          ),
                        ),
                        Text(
                          element.msg,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0
                          ),
                        ),
                        Text(
                          date.hour.toString() + ':' + date.minute.toString(),
                          style: TextStyle(
                            color: Colors.green[100],
                            fontSize: 14.0,
                          ),
                        ),
                      ],
                    ): Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          element.msg,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0
                          ),
                        ),
                        SizedBox(height: 3,),
                        Text(
                          date.hour.toString() + ':' + date.minute.toString(),
                          style: TextStyle(
                            color: Colors.green[100],
                            fontSize: 14.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              );
            });
          }
          if(_scrollController.hasClients){
            _scrollController.animateTo(
              0.0,
              curve: Curves.easeOut,
              duration: const Duration(milliseconds: 300),
            );
          }
        }
        return _buildScaffold(context);
      }
    );
  }

  Scaffold _buildScaffold(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
      title: Text(
        widget.username.split("-").length != 2? widget.username: widget.username.split("-")[0] == widget.username? widget.contactMapping[widget.username.split("-")[0]] ?? widget.username.split("-")[0]: widget.contactMapping[widget.username.split("-")[1]] ?? widget.username.split("-")[1],
      ),
    ),
    body: Container(
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          Expanded(
            child: Container(
              child: SingleChildScrollView(
                controller: _scrollController,
                reverse: true,
                child: Column(
                  children: _chats == null? []: _chats,
                ),
              ),
            ),
          ),
          Container(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: 10.0, top: 10.0, bottom: 10.0),
                        padding: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 2),
                        height: 45,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                          border: Border.all(
                            color: Colors.blue,
                          ),
                        ),
                        child: TextField(
                          controller: _msg,
                          decoration: InputDecoration(
                            hintText: 'Type a message',
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 50,
                      //padding: EdgeInsets.only(right: 10.0, top: 10.0, bottom: 10.0),
                      child: Center(
                        child: IconButton(
                          padding: EdgeInsets.all(0),
                          onPressed: () {
                            Provider.of<SocketBloc>(context, listen: false).add(SendMessage(widget.username, _msg.text, widget.username.contains("-")? 'privateChat': 'groupChat'));
                            setState(() {
                              _msg.clear();
                            });
                          },
                          icon: Icon(
                            Icons.send,
                            size: 40.0,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
  }
}


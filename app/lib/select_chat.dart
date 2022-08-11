import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:whatsnap/bloc/socket_bloc.dart';
import 'package:whatsnap/chat_page.dart';
import 'package:whatsnap/loading.dart';
import 'package:whatsnap/select_contact.dart';

class SelectChat extends StatefulWidget {
  final String username;
  SelectChat(this.username);

  @override
  _SelectChatState createState() => _SelectChatState();
}

class _SelectChatState extends State<SelectChat> {

  TextEditingController _receiverController = new TextEditingController();
  bool isUsernameEmpty = false;
  bool hasPermission;
  bool isLoading;

  void checkPermission() async {
    setState(() {
      isLoading = true;
    });
    final PermissionStatus permission = await Permission.contacts.request();
    if(permission == PermissionStatus.granted) {
      hasPermission = true;
    }
    else
      hasPermission = false;
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    checkPermission();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading? LoadingScreen(): BlocConsumer<SocketBloc, SocketState>(
      listener: (context, state) {
        if(state is ReceiverExists){
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => ChatPage(widget.username + '-' + _receiverController.text, Map<String, String>()),
          ));
        }
      },
      builder: (context, state) {
        if(state is SocketLoading)
          return LoadingScreen();
        else
          return _buildScaffold(state);
      },
    );
  }

  Scaffold _buildScaffold(SocketState state) {
    return Scaffold(
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        if(_receiverController.text.length > 0) {
          setState(() {
            isUsernameEmpty = false;
          });
          Provider.of<SocketBloc>(context, listen: false).add(UserAvailable(_receiverController.text));
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
                controller: _receiverController,
                decoration: InputDecoration(
                  hintText: 'Enter receiver\'s number',
                  border: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none
                ),
              ),
            ),
            SizedBox(height: 20.0,),
            (state is ReceiverDoesntExist || state is SocketLoginError)? Text(
              'User doesnt exist or isnt online',
              style: TextStyle(
                color: Colors.red,
              ),
            ): Container(),
            isUsernameEmpty? Text(
              'Username cant be empty!',
              style: TextStyle(
                color: Colors.red,
              ),
            ): Container(),
            hasPermission? Row(
              children: [
                Expanded(
                  child: Divider(
                    thickness: 1,
                  )
                ),      
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text("OR"),
                ),    
                Expanded(
                  child: Divider(
                    thickness: 1,
                  )
                ),
              ],
            ): Container(),
            hasPermission? FlatButton(
              onPressed: () async {
                String number = await Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => SelectContact(),
                ));
                if(number != null) {
                  number = number.trim().replaceAll(" ", "");
                  number = number.replaceAll("-", "");
                  number = number.replaceAll("(", "");
                  number = number.replaceAll(")", "");
                  if(number.length > 10)
                    number = number.substring(number.length-10);
                  _receiverController.text = number;
                  Provider.of<SocketBloc>(context, listen: false).add(UserAvailable(number));
                }
              },
              child: Text(
                'Select from contacts',
              ),
            ): Container(),
          ],
        ),
      ),
    ),
  );
  }
}

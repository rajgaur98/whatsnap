import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:whatsnap/bloc/socket_bloc.dart';
import 'package:whatsnap/chat_page.dart';
import 'package:whatsnap/loading.dart';
import 'package:whatsnap/select_chat.dart';
import 'package:whatsnap/select_room.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatList extends StatefulWidget {
  final username;
  final IO.Socket socket;
  ChatList(this.username, this.socket);

  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {

  List<Widget> chatList;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  List<String> senders;
  bool isJoining = false;
  bool isLoading = false;
  Iterable<Contact> contacts;
  Map<String, String> contactMapping;

  Future onClickNotification(String payload) async {
    showDialog(context: context);
  }

  Future showNotificationWithDefaultSound(dynamic data) async {
    if(widget.username == data['username'] || data['username'] == 'bot') return;
    int channel = senders.indexOf(data['username']);
    if(channel == -1) {
      channel = senders.length;
      senders.add(data['username']);
    }

    final androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'your channel id', 'your channel name', 'your channel description',
      importance: Importance.max, priority: Priority.high
    );
    final platformChannelSpecifics = new NotificationDetails(
        android: androidPlatformChannelSpecifics
    );
    await flutterLocalNotificationsPlugin.show(
      channel,
      data['username'],
      data['msg'],
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );
  }

  void _getPermission() async {
    setState(() {
      isLoading = true;
    });
    contactMapping = Map();
    if(await Permission.contacts.request().isGranted) {
      final Iterable<Contact> contacts = await ContactsService.getContacts();
      setState(() {
        this.contacts = contacts;
      });
      contacts.forEach((contact) {
        contact.phones.forEach((phone) {
          String number = phone.value;
          number = number.trim().replaceAll(" ", "");
          number = number.replaceAll("-", "");
          number = number.replaceAll("(", "");
          number = number.replaceAll(")", "");
          if(number.length > 10)
            number = number.substring(number.length-10);
          contactMapping[number] = contact.displayName;
        });
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _getPermission();
    setState(() {
      isJoining = true;
    });
    widget.socket.emit('join', widget.username);
    widget.socket.on('userLoggedIn', (data) => {
      setState(() {
        isJoining = false;
      }),
    });
    senders = [];
    final initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    final initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: onClickNotification);
    
    chatList = [];
  }

  @override
  Widget build(BuildContext context) {
    return isJoining || isLoading? LoadingScreen(): BlocBuilder<SocketBloc, SocketState>(
      builder: (context, state) {
        Provider.of<SocketBloc>(context, listen: false).add(Join(widget.username));
        if(state is SocketLoading)
          return LoadingScreen();
        else if(state is SocketLoggedIn){
          chatList = [];
          state.chats.forEach((key, value) {
            chatList.add(
              ListTile(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ChatPage(key, contactMapping),
                  ));
                },
                title: Text(
                  key.split("-").length != 2? key: key.split("-")[0] == widget.username? contactMapping[key.split("-")[1]] ?? key.split("-")[1]: contactMapping[key.split("-")[0]] ?? key.split("-")[0],
                ),
                trailing: Text(
                  value.last.date == null? "": value.last.date.hour.toString() + ':' + value.last.date.minute.toString(),
                ),
                subtitle: Text(
                  value.last.msg,
                ),
              ),
            );
          });
        }
        return _buildScaffold(context);
      },
    );
  }

  Scaffold _buildScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Messages',
        ),
        centerTitle: true,
        titleSpacing: 2,
      ),
      floatingActionButton: buildSpeedDial(),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: ListView(
          children: chatList,
        ),
      ),
    );
  }

  SpeedDial buildSpeedDial() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 22.0),
      onOpen: () => print('OPENING DIAL'),
      onClose: () => print('DIAL CLOSED'),
      curve: Curves.bounceIn,
      children: [
        SpeedDialChild(
          child: Icon(Icons.people, color: Colors.white),
          backgroundColor: Colors.blue[300],
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => SelectRoom(widget.username),
            ));
          },
          label: 'Chat room',
          labelStyle: TextStyle(fontWeight: FontWeight.w500),
          labelBackgroundColor: Colors.blue[100],
        ),
        SpeedDialChild(
          child: Icon(Icons.person_add, color: Colors.white),
          backgroundColor: Colors.blue[300],
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => SelectChat(widget.username),
            ));
          },
          label: 'Personal Chat',
          labelStyle: TextStyle(fontWeight: FontWeight.w500),
          labelBackgroundColor: Colors.blue[100],
        ),
      ],
    );
  }

}

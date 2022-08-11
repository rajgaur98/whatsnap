import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:provider/provider.dart';
import 'package:whatsnap/bloc/login_bloc.dart';
import 'package:whatsnap/bloc/otp_bloc.dart';
import 'package:whatsnap/chat_list.dart';
import 'package:whatsnap/enter_number.dart';
import 'package:whatsnap/loading.dart';
import 'package:whatsnap/services.dart';

class Wrapper extends StatelessWidget {
  final IO.Socket socket;
  Wrapper(this.socket);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        if(state is LoginInitial) {
          Provider.of<LoginBloc>(context, listen: false).add(CheckLogin());
          return LoadingScreen();
        }
        else if(state is LoggedIn) {
          print('in wrapper');
          return ChatList(state.number, socket);
        }
        else {
          return BlocProvider(
            create: (context) => OtpBloc(Services()),
            child: NumberScreen(socket),
          );
        }
      },
    );
  }
}

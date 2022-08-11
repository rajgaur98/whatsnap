import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:whatsnap/bloc/login_bloc.dart';
import 'package:whatsnap/bloc/otp_bloc.dart';
import 'package:whatsnap/enter_otp.dart';
import 'package:whatsnap/loading.dart';
import 'package:whatsnap/services.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class NumberScreen extends StatefulWidget {
  final IO.Socket socket;
  NumberScreen(this.socket);

  @override
  _NumberScreenState createState() => _NumberScreenState();
}

class _NumberScreenState extends State<NumberScreen> {

  TextEditingController number;

  @override
  void initState() {
    super.initState();
    number = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OtpBloc, OtpState>(
      listener: (context, state) {
        if(state is OtpSent) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => OtpBloc(Services()),
                ),
                BlocProvider(
                  create: (context) => LoginBloc(),
                ),
              ],
              child: VerifyOtpPage(state.sessionId, number.text, widget.socket),
            ),
          ));
        }
      },
      builder: (context, state) {
        if(state is OtpLoading)
          return LoadingScreen();
        else
          return buildScaffold(context);
      },
    );
  }

  Scaffold buildScaffold(BuildContext context) {
    return Scaffold(
    floatingActionButton: Container(
      height: 70,
      width: 70,
      child: FittedBox(
        child: FloatingActionButton(
          onPressed: () {
            if(number.text.length == 10) {
              Provider.of<OtpBloc>(context, listen: false).add(SendOtp(number.text));
            }
          },
          child: Icon(
            Icons.navigate_next,
          ),
        ),
      ),
    ),
    body: SafeArea(
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.perm_phone_msg,
              size: 100,
              color: Colors.blue,
            ),
            Text(
              'Hey, Whats your number?',
              style: TextStyle(
                fontSize: 25.0,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.0,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '+91',
                  style: TextStyle(
                    fontSize: 30.0,
                  ),
                ),
                SizedBox(width: 10.0,),
                Container(
                  // height: 50.0,
                  width: 175.0,
                  child: TextFormField(
                    autofocus: true,
                    controller: number,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(10),
                      WhitelistingTextInputFormatter.digitsOnly
                    ],
                    decoration: InputDecoration(
                      hintText: '1234567890',
                    ),
                    style: TextStyle(
                      fontSize: 30.0,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 50.0,),
          ],
        ),
      ),
    ),
  );
  }

  @override
  void dispose() {
    number.dispose();
    super.dispose();
  }

}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:whatsnap/bloc/login_bloc.dart';
import 'package:whatsnap/bloc/otp_bloc.dart';
import 'package:whatsnap/chat_list.dart';
import 'package:whatsnap/loading.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class VerifyOtpPage extends StatefulWidget {
  final String sessionId;
  final String number;
  final IO.Socket socket;
  VerifyOtpPage(this.sessionId, this.number, this.socket);

  @override
  _VerifyOtpPageState createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {

  FocusNode focus1;
  FocusNode focus2;
  FocusNode focus3;
  FocusNode focus4;
  FocusNode focus5;
  FocusNode focus6;
  TextEditingController controller1;
  TextEditingController controller2;
  TextEditingController controller3;
  TextEditingController controller4;
  TextEditingController controller5;
  TextEditingController controller6;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    focus1 = FocusNode();
    focus2 = FocusNode();
    focus3 = FocusNode();
    focus4 = FocusNode();
    focus5 = FocusNode();
    focus6 = FocusNode();
    controller1 = TextEditingController();
    controller2 = TextEditingController();
    controller3 = TextEditingController();
    controller4 = TextEditingController();
    controller5 = TextEditingController();
    controller6 = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OtpBloc, OtpState>(
      listener: (context, state) {
        if(state is OtpVerified) {
          Provider.of<LoginBloc>(context, listen: false).add(SetLogin(widget.number));
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => ChatList(widget.number, widget.socket),
          ));
        }
        if(state is OtpInvalid) {
          print('otp invalid');
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
      key: scaffoldKey,
      floatingActionButton: Container(
        height: 70,
        width: 70,
        child: FittedBox(
          child: FloatingActionButton(
            onPressed: () {
              String otp = controller1.text + controller2.text + controller3.text + controller4.text + controller5.text + controller6.text;
              if(otp.length == 6) {
                Provider.of<OtpBloc>(context, listen: false).add(VerifyOtp(widget.sessionId, otp));
              }
            },
            child: Icon(
              Icons.check,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.textsms,
                size: 100,
                color: Colors.blue,
              ),
              Text(
                'Enter the OTP received',
                style: TextStyle(
                  fontSize: 25.0,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.0,),
              buildOtpRow(),
              SizedBox(height: 50.0,),
            ],
          ),
        ),
      ),
    );
  }

  Row buildOtpRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(),
        SizedBox(),
        Container(
          width: 30,
          child: TextField(
            style: TextStyle(
              fontSize: 25.0
            ),
            controller: controller1,
            inputFormatters: [
              LengthLimitingTextInputFormatter(1),
              WhitelistingTextInputFormatter.digitsOnly,
            ],
            focusNode: focus1,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              if(value.length == 1){
                focus2.requestFocus();
              }
            },
            autofocus: true,
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          width: 30,
          child: TextField(
            style: TextStyle(
              fontSize: 25.0
            ),
            controller: controller2,
            inputFormatters: [
              LengthLimitingTextInputFormatter(1),
              WhitelistingTextInputFormatter.digitsOnly,
            ],
            focusNode: focus2,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              if(value.length == 1){
                focus3.requestFocus();
              }
            },
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          width: 30,
          child: TextField(
            style: TextStyle(
              fontSize: 25.0
            ),
            controller: controller3,
            inputFormatters: [
              LengthLimitingTextInputFormatter(1),
              WhitelistingTextInputFormatter.digitsOnly,
            ],
            focusNode: focus3,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                if(value.length == 1){
                  focus4.requestFocus();
                }
              });
            },
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          width: 30,
          child: TextField(
            style: TextStyle(
              fontSize: 25.0
            ),
            controller: controller4,
            inputFormatters: [
              LengthLimitingTextInputFormatter(1),
              WhitelistingTextInputFormatter.digitsOnly,
            ],
            focusNode: focus4,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                if(value.length == 1){
                  focus5.requestFocus();
                }
              });
            },
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          width: 30,
          child: TextField(
            style: TextStyle(
              fontSize: 25.0
            ),
            controller: controller5,
            inputFormatters: [
              LengthLimitingTextInputFormatter(1),
              WhitelistingTextInputFormatter.digitsOnly,
            ],
            focusNode: focus5,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                if(value.length == 1){
                  focus6.requestFocus();
                }
              });
            },
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          width: 30,
          child: TextField(
            style: TextStyle(
              fontSize: 25.0
            ),
            controller: controller6,
            keyboardType: TextInputType.number,
            inputFormatters: [
              LengthLimitingTextInputFormatter(1),
              WhitelistingTextInputFormatter.digitsOnly,
            ],
            focusNode: focus6,
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(),
        SizedBox(),
      ],
    );
  }

  @override
  void dispose() {
    focus1.dispose();
    focus2.dispose();
    focus3.dispose();
    focus4.dispose();
    focus5.dispose();
    focus6.dispose();
    controller1.dispose();
    controller2.dispose();
    controller3.dispose();
    controller4.dispose();
    controller5.dispose();
    controller6.dispose();
    super.dispose();
  }

}

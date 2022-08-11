import 'dart:convert';

import 'package:http/http.dart';

class Services {

  final baseUrl = 'http://10.0.2.2:3000';
  // final baseUrl = 'https://whatsnap.herokuapp.com';
  final apiKey = 'ddfba030-230f-11eb-965d-0200cd936042';
  final otpBaseUrl = 'https://2factor.in/API/V1';

  Future login(String username) async {
    final url = baseUrl + '/join';
    Response response = await post(url, body: {
      'username': username
    });

    if(response.statusCode == 200){
      final jsonResponse = json.decode(response.body);
      return jsonResponse;
    }
    else{
      return null;
    }
  }

  Future receiver(String username, String sender) async {
    final url = baseUrl + '/receiver';
    Response response = await post(url, body: {
      'username': username,
      'sender': sender
    });

    if(response.statusCode == 200){
      final jsonResponse = json.decode(response.body);
      return jsonResponse;
    }
    else{
      return null;
    }
  }

  Future joinRoom(String username, String room) async {
    final url = baseUrl + '/joinRoom';
    Response response = await post(url, body: {
      'username': username,
      'room': room
    });

    if(response.statusCode == 200){
      final jsonResponse = json.decode(response.body);
      return jsonResponse;
    }
    else{
      return null;
    }
  }

  Future sendOtp(String number) async {
    final url = otpBaseUrl + '/$apiKey/SMS/$number/AUTOGEN';
    Response response = await get(url);
    if(response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['Details'];
    }
    else {
      return null;
    }
  }

  Future verifyOtp(String sessionId, String otp) async {
    final url = otpBaseUrl + '/$apiKey/SMS/VERIFY/$sessionId/$otp';
    Response response = await get(url);
    if(response.statusCode == 200) {
      return true;
    }
    else {
      return null;
    }
  }

}
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../popUpGreen.dart';
import '../popUpRed.dart';

//Registrierung in Firebase

Future<void> signUp(BuildContext context, String email, String password) async {
  const url = 'https://rest-api-rho-hazel.vercel.app/auth/register';
  final body = jsonEncode({
    'email': email,
    'password': password,
  });

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final String uid = data['uid'];
      final String token = data['token'];

      await saveUidLocal(uid);
      await saveTokenLocal(token);

      print('User ID: $uid');
      print('Token ID: $token');

      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: NotificationPopupGreen(message: 'Registration was successful'),
        duration: Duration(seconds: 3),
      ),
    );
    
      //INFO für chrisi dort ist die Route wenn die anmeldung erfolgreif war

      Navigator.pushNamed(context, '/basicCalories');
    } else {
      final Map<String, dynamic> errorData = json.decode(response.body);
      final String errorMessage = errorData['message'] ?? 'Unbekannter Fehler';
      print('Fehler beim Registrieren - ${response.statusCode}: $errorMessage');
      //fehler im frontend anzeigen lassen
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: NotificationPopupRed(message: errorMessage),
        duration: Duration(seconds: 3),
      ),
      );
    }
  } catch (error) {
    print('Fehler beim Registrieren: $error');
    //fehler im frontend anzeigen lassen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: NotificationPopupRed(message: error.toString()),
        duration: Duration(seconds: 3),
      ),
      );
  }
}




//Meldet User an

Future<void> signIn(BuildContext context, String email, String password) async {
  const url = 'https://rest-api-rho-hazel.vercel.app/auth/login';
  final body = jsonEncode({
    'email': email,
    'password': password,
  });

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final String uid = data['uid'];
      final String token = data['token'].toString();

      await saveUidLocal(uid);
      await saveTokenLocal(token);

      print('User ID: $uid');
      print('User ID: $token');

      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: NotificationPopupGreen(message: 'Login was successful'),
        duration: Duration(seconds: 3),
      ),
    );
      //Navigator.pushNamed(context, '/home');
      Navigator.pushNamed(context, '/hauptseite');
    } else {
      final Map<String, dynamic> errorData = json.decode(response.body);
      final String errorMessage = errorData['message'];
      print('Fehler beim Anmelden - ${response.statusCode}: $errorMessage');
      //fehler im frontend anzeigen lassen
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: NotificationPopupRed(message: errorMessage),
        duration: Duration(seconds: 3),
      ),
      );
    }
  } catch (error) {
    print('Fehler beim Anmelden: $error');
    //fehler im frontend anzeigen lassen
        ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: NotificationPopupRed(message: error.toString()),
        duration: Duration(seconds: 3),
      ),
      );
  }
}



//Speichert UID Lokal

Future<void> saveUidLocal(String uid) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('userUid', uid);
}

//Speichert Token Lokal

Future<void> saveTokenLocal(String token) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('userToken', token);
}


//Zeigt das Token an
Future<String?> getToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('userToken');
}

//Zeigt die UID an
Future<String?> getUid() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('userUid');
}

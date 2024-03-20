import 'package:flutter/material.dart';
import '../nutrition/basicCalories.dart';
import '../nutrition/foodTracking.dart';
import '../login/login.dart';
import '../login/register.dart';

class Startseite extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 5,
          toolbarHeight: 100,
          backgroundColor: Colors.black,
          title: Stack(
            alignment: Alignment.topRight,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/Logo_Menu_App.png',
                    fit: BoxFit.cover,
                    height: 60,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Light Weight',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                ],
              ),
            ],
          ),
        ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 280.0,
                height: 280.0,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/Logo_Menu_App.png',
                    width: 250.0,
                  ),
                ),
              ),
              const SizedBox(height: 5.0),
              const Text(
                'LightWeight',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5.0),
              Container(
                width: 300.0,
                height: 50.0,
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: Colors.black, width: 1.0),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Image.asset('assets/Logo_Menu_App.png'),
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                    ),
                    const Text(
                      'Login with LightWeight',
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'You have no account?',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text(
                      'Sign up now',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

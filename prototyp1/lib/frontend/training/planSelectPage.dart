import 'package:flutter/material.dart';
import 'package:prototyp1/frontend/training/splitSelectPage.dart';

class PlanSelectPage extends StatefulWidget {
  @override
  State<PlanSelectPage> createState() => _PlanSelectPageState();
}

class _PlanSelectPageState extends State<PlanSelectPage> {
  String _selectedGoal = 'strength';
  String _selectedLevel = 'beginner';

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Image.asset(
                    'assets/search_icon3.png',
                    height: 25,
                  ),
                  onPressed: () {
                    //do something
                  },
                ),
                IconButton(
                  icon: Image.asset(
                    'assets/login_App.png',
                    height: 25,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/start');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                offset: Offset(0, 3),
                spreadRadius: 0,
              ),
            ],
          ),
          width: screenSize.width * 0.9, // 80% of screen width
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Create your plan",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "What is your goal ?",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                DropdownButton<String>(
                  value: _selectedGoal,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedGoal = newValue!;
                    });
                  },
                  items: <String>['strength', 'definition', 'bodyweight']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),
                Text(
                  "What is your training level ?",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                DropdownButton<String>(
                  value: _selectedLevel,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedLevel = newValue!;
                    });
                  },
                  items: <String>[
                    'beginner',
                    'advanced',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/splitSelect',
                      arguments: {
                        'selectedGoal': _selectedGoal,
                        'selectedLevel': _selectedLevel,
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 36),
                  ),
                  child: Text('Show your training splits'),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 30.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
              bottomLeft: Radius.circular(20.0),
              bottomRight: Radius.circular(20.0),
            ),
          ),
          height: 60.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                child: IconButton(
                  icon: Image.asset('assets/hantel_App.png', width: 30, height: 30),
                  onPressed: () {},
                ),
              ),
              SizedBox(
                child: IconButton(
                  icon: Image.asset('assets/apfel_App.png', width: 30, height: 30),
                  onPressed: () {},
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                ),
                width: 100,
                height: 100,
                margin: EdgeInsets.only(bottom: 0),
                child: IconButton(
                  icon: Image.asset('assets/Logo_Menu_App.png', height: 80, width: 80),
                  onPressed: () {},
                ),
              ),
              SizedBox(
                child: IconButton(
                  icon: Image.asset('assets/kalender_App.png', height: 30, width: 30),
                  onPressed: () {},
                ),
              ),
              SizedBox(
                child: IconButton(
                  icon: Image.asset('assets/dreiPunkte_App.png', height: 30, width: 30),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

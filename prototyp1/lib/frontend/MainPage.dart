import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';


class HauptseitePage extends StatefulWidget {
  @override
  State<HauptseitePage> createState() => _HauptSeitePageState();
}

class _HauptSeitePageState extends State<HauptseitePage> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    const greyColor = Color.fromARGB(255, 42, 41, 41);

    return MaterialApp(
      home: Scaffold(
        backgroundColor: greyColor,
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
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      _openCalendar(context);
                    },
                    child: TableCalendar(
                      focusedDay: _focusedDay,
                      firstDay: DateTime(2024, 1, 1),
                      lastDay: DateTime(2028, 12, 31),
                      calendarFormat: CalendarFormat.week,
                      selectedDayPredicate: (day) {
                        return isSameDay(_selectedDay, day);
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                        });
                      },
                      calendarStyle: const CalendarStyle(
                        defaultTextStyle: TextStyle(color: Colors.white),
                        weekendTextStyle: TextStyle(color: Colors.white),
                        outsideTextStyle: TextStyle(color: Colors.white),
                        todayTextStyle: TextStyle(color: Colors.white),
                        selectedTextStyle: TextStyle(color: Colors.white),
                      ),
                      headerStyle: const HeaderStyle(
                        titleTextStyle: TextStyle(color: Colors.white),
                        leftChevronIcon:
                            Icon(Icons.chevron_left, color: Colors.white),
                        rightChevronIcon:
                            Icon(Icons.chevron_right, color: Colors.white),
                        formatButtonTextStyle: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            left: 20,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/training');
                              },
                              child: const Text(
                                "Workout",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            left: 20,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/nutritionPage');
                              },
                              child: const Text(
                                "Nutrition",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 50,
                            left: 20,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildNutrientBars(
                                  nutrientName: 'Carbs',
                                  nutrientValue: 100,
                                  barColor: Colors.blue,
                                ),
                                buildNutrientBars(
                                  nutrientName: 'Fat',
                                  nutrientValue: 50,
                                  barColor: Colors.red,
                                ),
                                buildNutrientBars(
                                  nutrientName: 'Protein',
                                  nutrientValue: 80,
                                  barColor: Colors.green,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 30.0),
          child: Container(
            decoration: const BoxDecoration(
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
                    icon: Image.asset(
                      'assets/hantel_App.png',
                      width: 30,
                      height: 30,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/training');
                    },
                  ),
                ),
                SizedBox(
                  child: IconButton(
                    icon: Image.asset(
                      'assets/apfel_App.png',
                      width: 30,
                      height: 30,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/nutritionPage');
                    },
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                  ),
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.only(bottom: 0),
                  child: IconButton(
                    icon: Image.asset(
                      'assets/Logo_Menu_App.png',
                      width: 80,
                      height: 80,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/hauptseite');
                    },
                  ),
                ),
                SizedBox(
                  child: IconButton(
                    icon: Image.asset(
                      'assets/kalender_App.png',
                      width: 30,
                      height: 30,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/training');
                    },
                  ),
                ),
                SizedBox(
                  child: IconButton(
                    icon: Image.asset(
                      'assets/dreiPunkte_App.png',
                      width: 30,
                      height: 30,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/planSelect');
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildNutrientBars({
    required String nutrientName,
    required double nutrientValue,
    required Color barColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$nutrientName: $nutrientValue',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        SizedBox(
          height: 10,
          width: nutrientValue,
          child: Container(
            color: barColor,
          ),
        ),
      ],
    );
  }

  Future<void> _openCalendar(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDay,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime(2028, 12, 31),
    );
    if (pickedDate != null && pickedDate != _selectedDay) {
      setState(() {
        _selectedDay = pickedDate;
      });
    }
  }
}

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'basicCalories.dart';
import '../../backend/nutrition_http.dart';

class FoodTracking extends StatefulWidget {
  @override
  _FoodTrackingState createState() => _FoodTrackingState();
}

class _FoodTrackingState extends State<FoodTracking> {
  late DateTime selectedDate;
  late DateTime _focusedDay;

  late int basicCalories;
  late int uebrig;
  late int totalCalories;
  late double totalCarbs;
  late double totalFat;
  late double totalProtein;
  int verbrannt = 500;

  late Map<String, double> maxNutrientValues = {
    'carbs': 0,
    'protein': 0,
    'fat': 0,
  };

  late Future<void> maxNutrientValuesFuture;

  // Variable to track the number of meals added
  int mealCount = 3;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    selectedDate = DateTime.now();
    uebrig = 0;
    totalCalories = 0;
    totalCarbs = 0;
    totalFat = 0;
    totalProtein = 0;

    _fetchMealData(selectedDate);
    maxNutrientValuesFuture = _fetchMaxNutrientValues(selectedDate);
    _fetchMealType(); // Call _fetchMealType function to set mealCount
  }

  // Function to fetch meal type data and set mealCount
  void _fetchMealType() async {
    try {
      String formattedDate =
          "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
      Map<String, dynamic>? mealTypeData = await getMealNumber(formattedDate);
      if (mealTypeData != null) {
        setState(() {
          if (mealTypeData['mealNumber'] < 3) {
            mealCount = 3;
          }
        else{
          mealCount = mealTypeData['mealNumber'];
        }
        });
      } else {
        print('Error: mealCount not found');
      }
    } catch (e) {
      print('Error when retrieving the meal type: $e');
    }
  }

  Future<void> _fetchMaxNutrientValues(DateTime selectedDate) async {
    String formattedDate =
        "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

    try {
      var data = await calculateNutritionIntake(formattedDate);
      setState(() {
        maxNutrientValues = {
          'carbs': (data['carbIntakeGrams'] ?? 0).toDouble(),
          'protein': (data['proteinIntakeGrams'] ?? 0).toDouble(),
          'fat': (data['fatIntakeGrams'] ?? 0).toDouble(),
        };
      });
    } catch (error) {
      print('Fehler beim Abrufen der maximalen Nährstoffwerte: $error');
      setState(() {
        maxNutrientValues = {
          'carbs': 0,
          'protein': 0,
          'fat': 0,
        };
      });
    }
  }

  void _fetchMealData(DateTime selectedDate) {
    setState(() {
      totalCalories = 0;
      totalCarbs = 0;
      totalFat = 0;
      totalProtein = 0;
      basicCalories = 0;
    });

    String formattedDate =
        "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

    getBasicCalories().then((data) {
      setState(() {
        final double basicCaloriesDouble =
            double.parse(data['basicCalories'].toString());
        basicCalories = basicCaloriesDouble.toInt();
        uebrig = basicCalories - totalCalories + verbrannt;
      });
    }).catchError((error) {
      print('Error when retrieving the basic calories: $error');
      setState(() {
        basicCalories = 0;
        uebrig = 0;
      });
    });

    getMealSum(formattedDate).then((data) {
      setState(() {
        if (data != null) {
          totalCalories = (data['totalCalories'] ?? 0).round();
          totalCarbs = data['totalCarbs'] ?? 0;
          totalFat = data['totalFat'] ?? 0;
          totalProtein = data['totalProtein'] ?? 0;
          uebrig = basicCalories - totalCalories + verbrannt;
        }
      });
    }).catchError((error) {
      print('Fehler beim Abrufen der Mahlzeitsumme: $error');
      setState(() {
        totalCalories = 0;
        totalCarbs = 0;
        totalFat = 0;
        totalProtein = 0;
      });
    });
  }

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 15),
              Container(
                height: 150,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                    bottomLeft: Radius.circular(20.0),
                    bottomRight: Radius.circular(20.0),
                  ),
                ),
                child: TableCalendar(
                  focusedDay: _focusedDay,
                  firstDay: DateTime(2024, 1, 1),
                  lastDay: DateTime(2028, 12, 31),
                  calendarFormat: CalendarFormat.week,
                  selectedDayPredicate: (day) {
                    return isSameDay(selectedDate, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      selectedDate = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    _fetchMealData(selectedDay);
                    maxNutrientValuesFuture = _fetchMaxNutrientValues(selectedDay);
                    _fetchMealType(); // Call _fetchMealType function on day selection
                  },
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNutritionBlock('Eaten', totalCalories.toString()),
                    _buildNutritionBlock('Remaining', uebrig.toString()),
                    _buildNutritionBlock('Burnt', verbrannt.toString()),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              FutureBuilder(
                future: maxNutrientValuesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return _buildNutrientBars(totalCarbs, totalFat, totalProtein);
                  }
                },
              ),
              const SizedBox(height: 20),
              // Build meal containers based on mealCount
              for (int i = 1; i <= mealCount; i++)
                Column(
                  children: [
                    _buildMealContainer('Meal $i'),
                    const SizedBox(height: 5),
                  ],
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () {
                      setState(() {
                        if (mealCount > 0) {
                          mealCount--; // Decrement mealCount when removing a meal, but keep it positive
                        }
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        mealCount++; // Increment mealCount when adding a new meal
                      });
                    },
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
      );
  }

Widget _buildNutritionBlock(String title, String value) {
  Color textColor = Colors.white;
  String displayTitle = title;
  String displayValue = value;

  if (title == 'Übrig') {
    int numericValue = int.tryParse(value) ?? 0;
    if (numericValue < 0) {
      displayTitle = 'Too much';
      textColor = Colors.red;
      displayValue = (numericValue * -1).toString();
    }
  }

  return Column(
    children: [
      Text(
        displayValue,
        style: TextStyle(
          fontSize: 15,
          color: textColor,
        ),
      ),
      SizedBox(height: 5),
      Text(
        displayTitle,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
        ),
      ),
    ],
  );
}


  Widget _buildNutrientBars(double carbs, double protein, double fat) {
    final maxCarbs = maxNutrientValues['carbs'] ?? 0;
    final maxFat = maxNutrientValues['fat'] ?? 0;
    final maxProtein = maxNutrientValues['protein'] ?? 0;
    return _buildNutrientBarsWithValues(carbs, fat, protein, maxCarbs, maxProtein, maxFat);
  }

  Widget _buildNutrientBarsWithValues(double carbs, double protein, double fat, double maxCarbs, double maxProtein, double maxFat) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildNutrientBar('Carbs', carbs, maxCarbs, Colors.blue),
        _buildNutrientBar('Protein', protein, maxProtein, Colors.green),
        _buildNutrientBar('Fat', fat, maxFat, Colors.orange),
      ],
    );
  }

  Widget _buildNutrientBar(String title, double value, double maxValue, Color color) {
    final barWidth = 100.0;

    return Column(
      children: [
        Text(
          "${value.toStringAsFixed(0)} g",
          style: const TextStyle(
            fontSize: 15,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 5),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 5),
        Container(
          width: barWidth,
          height: 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.grey,
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: maxValue != 0 ? value / maxValue : 1,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: color,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMealContainer(String mealType) {
    String formattedDate =
        '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
    return FutureBuilder(
      future: getMealTypeSum(formattedDate, mealType),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else {
          int caloriesSum = 0;
          int carbsSum = 0;
          int fatSum = 0;
          int proteinSum = 0;

          if (snapshot.hasError || snapshot.data == null || snapshot.data!['statusCode'] == 404) {
            caloriesSum = 0;
            carbsSum = 0;
            fatSum = 0;
            proteinSum = 0;
          } else {
            // Andernfalls setze die Werte entsprechend den zurückgegebenen Daten
            Map<String, dynamic>? mealData = snapshot.data as Map<String, dynamic>?;
            caloriesSum = mealData?['caloriesSum'] ?? 0;
            carbsSum = (mealData?['carbsSum'] ?? 0).round();
            fatSum = (mealData?['fatSum'] ?? 0).round();
            proteinSum = (mealData?['proteinSum'] ?? 0).round();
          }

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/previousAddsPage',
                  arguments: {
                    'mealType': mealType,
                    'selectedDate': selectedDate,
                  },
                ).then((_) {
                  _fetchMealData(selectedDate);
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              mealType,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                Text(
                                  '$caloriesSum',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Calories',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 10),
                            Column(
                              children: [
                                Text(
                                  '$carbsSum',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Carbs',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 10),
                            Column(
                              children: [
                                Text(
                                  '$proteinSum',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Protein',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 10),
                            Column(
                              children: [
                                Text(
                                  '$fatSum',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                const Text(
                                  'Fat',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      Map<String, dynamic> arguments = {
                        'selectedDate': selectedDate,
                        'mealType': mealType,
                      };
                      Navigator.pushNamed(context, '/searchFood', arguments: arguments).then((_) {
                        _fetchMealData(selectedDate);
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
// Importe für die Backend-Funktionen
import '../../backend/nutrition_http.dart';

class FoodDetailPage extends StatefulWidget {
  final Map<String, dynamic> foodDetails;
  final String mealType;
  final DateTime selectedDate;

  const FoodDetailPage({
    Key? key,
    required this.foodDetails,
    required this.mealType,
    required this.selectedDate,
  }) : super(key: key);

  @override
  _FoodDetailPageState createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPage> {
  late Future<Map<String, dynamic>> _nutritionData;
  late Future<Map<String, dynamic>> _originalData;
  TextEditingController _notesController = TextEditingController();
  String newAmount = '';

  Future<void> _updateNewAmount() async {
    double newAmountValue = double.tryParse(_notesController.text) ?? 0.0;

    if (newAmountValue == 0.0) {
      newAmountValue = 1.0;
    }

    Map<String, dynamic> adjustedNutritionData =
        await adjustNutritionData(newAmountValue, await _originalData);

    setState(() {
      _nutritionData = Future.value(adjustedNutritionData);
    });
  }

  @override
  void initState() {
    super.initState();
    _nutritionData = extractNutritionData(widget.foodDetails['food_description'] ?? '');
    _originalData = extractNutritionData(widget.foodDetails['food_description'] ?? '');
  }

  Future<Map<String, dynamic>> extractNutritionData(String nutritionData) async {
    final Map<String, dynamic> extractedData = await splitNutritionData(nutritionData);
    print('Extracted Data: $extractedData');
    return extractedData;
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate =
        '${widget.selectedDate.year}-${widget.selectedDate.month.toString().padLeft(2, '0')}-${widget.selectedDate.day.toString().padLeft(2, '0')}';

    return Scaffold(
      //appBar: AppBar(
      //  title: Text(widget.foodDetails['food_name'] ?? 'Details'),
      //),
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
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _nutritionData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error loading nutrition information'));
            } else {
              int calories = snapshot.data?['calories'] ?? 0;
              double fat = snapshot.data?['fat'] ?? 0.0;
              double carbs = snapshot.data?['carbs'] ?? 0.0;
              double protein = snapshot.data?['protein'] ?? 0.0;
              int amountValue = snapshot.data?['amount']['value'] ?? 0;
              String amountUnit = snapshot.data?['amount']['unit'] ?? '';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 40), // Increased height for Nutritional Information
                    Text(
                      'Nutritional Information:\n'
                      '${widget.foodDetails['food_name'] ?? 'Details'}',
                      textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24, // Increased font size for Nutritional Information
                          ),
                      ),

                  SizedBox(height: 10),
                  NutritionCircle(
                    fat: fat,
                    carbs: carbs,
                    protein: protein,
                    totalCalories: calories,
                  ),
                  SizedBox(height: 0), // Reduced height between circle and calories
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      NutritionInfoItem(
                        value: '$calories kcal', // Updated to display calories only
                        color: Colors.white, // Changed color to white
                        fontSize: 24, // Increased font size for calories
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      NutritionInfoItem(
                        label: 'Fat',
                        value: fat.toStringAsFixed(2),
                        color: Colors.blue,
                        fontSize: 18,
                      ),
                      SizedBox(width: 20),
                      NutritionInfoItem(
                        label: 'Carbs',
                        value: carbs.toStringAsFixed(2),
                        color: Colors.green,
                        fontSize: 18,
                      ),
                      SizedBox(width: 20),
                      NutritionInfoItem(
                        label: 'Protein',
                        value: protein.toStringAsFixed(2),
                        color: Colors.red,
                        fontSize: 18,
                      ),
                      SizedBox(width: 20),
                      NutritionInfoItem(
                        label: 'Amount',
                        value: '$amountValue $amountUnit',
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _notesController,
                          decoration: InputDecoration(
                            hintText: 'Amount: $amountValue $amountUnit',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () async {
                          _updateNewAmount(); // Button calls function to update amount
                        },
                        child: const Text('Change Amount'),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      int calories = snapshot.data?['calories'] ?? 0;
                      double fat = snapshot.data?['fat'] ?? 0.0;
                      double carbs = snapshot.data?['carbs'] ?? 0.0;
                      double protein = snapshot.data?['protein'] ?? 0.0;
                      String foodName = widget.foodDetails['food_name'] ?? '';

                      await saveNutritionDataToFirebase(
                        calories: calories,
                        fat: fat,
                        carbs: carbs,
                        protein: protein,
                        foodName: foodName,
                        amount: '1', // Default amount
                        selectedDate: formattedDate,
                        mealType: widget.mealType,
                        context: context,
                      );
                    },
                    child: const Text('Save'),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

class NutritionCircle extends StatelessWidget {
  final double fat;
  final double carbs;
  final double protein;
  final int totalCalories;

  const NutritionCircle({
    Key? key,
    required this.fat,
    required this.carbs,
    required this.protein,
    required this.totalCalories,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double total = fat + carbs + protein;

    double fatAngle = (fat / total) * 2 * pi;
    double carbsAngle = (carbs / total) * 2 * pi;
    double proteinAngle = (protein / total) * 2 * pi;

    return SizedBox(
      width: 250,
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
            ),
            child: CustomPaint(
              painter: CirclePainter(
                fatAngle: fatAngle,
                carbsAngle: carbsAngle,
                proteinAngle: proteinAngle,
              ),
            ),
          ),
        ]
      )
    );
  }
}

class CirclePainter extends CustomPainter {
  final double fatAngle;
  final double carbsAngle;
  final double proteinAngle;

  CirclePainter({
    required this.fatAngle,
    required this.carbsAngle,
    required this.proteinAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final fatPaint = Paint()..color = Colors.blue;
    final carbsPaint = Paint()..color = Colors.green;
    final proteinPaint = Paint()..color = Colors.red;

    final startAngle = -pi / 2;

    // Draw Fat sector
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, fatAngle, true, fatPaint);

    // Draw Carbs sector
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle + fatAngle,
      carbsAngle,
      true,
      carbsPaint,
    );

    // Draw Protein sector
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle + fatAngle + carbsAngle,
      proteinAngle,
      true,
      proteinPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class NutritionInfoItem extends StatelessWidget {
  final String? label;
  final String value;
  final Color color;
  final double fontSize;

  const NutritionInfoItem({
    Key? key,
    this.label,
    required this.value,
    required this.color,
    required this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label ?? '', // Use label if provided, otherwise an empty string
          style: TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: TextStyle(fontSize: fontSize),
        ),
      ],
    );
  }
}

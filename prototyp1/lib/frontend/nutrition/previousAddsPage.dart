import 'package:flutter/material.dart';
import '../../backend/nutrition_http.dart';

class PreviousAddsPage extends StatefulWidget {
  final String mealType;
  final DateTime selectedDate;

  const PreviousAddsPage({
    Key? key,
    required this.selectedDate,
    required this.mealType,
  }) : super(key: key);

  @override
  _PreviousAddsPageState createState() => _PreviousAddsPageState();
}

class _PreviousAddsPageState extends State<PreviousAddsPage> {
  late Future<List<Map<String, dynamic>>> _mealDataFuture;
  late Future<Map<String, dynamic>?> _mealTypeSumFuture;
  late Future<Map<String, dynamic>?> _mealTypeTotalSumFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    String formattedDate =
        '${widget.selectedDate.year}-${widget.selectedDate.month.toString().padLeft(2, '0')}-${widget.selectedDate.day.toString().padLeft(2, '0')}';

    _mealDataFuture = getMealData(formattedDate, widget.mealType);
    _mealTypeSumFuture = getMealTypeSum(formattedDate, widget.mealType);
    _mealTypeTotalSumFuture = getMealSum(formattedDate);
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
      /*
      appBar: AppBar(
        title: Text(
          widget.mealType,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      */
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                Text(
                    widget.mealType,
                    style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FutureBuilder<Map<String, dynamic>?>(
              future: _mealTypeSumFuture,
              builder: (context, sumSnapshot) {
                if (sumSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  final Map<String, dynamic>? mealTypeSumData = sumSnapshot.data;
                  return mealTypeSumData != null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildNutrientInfo('Calories', mealTypeSumData['caloriesSum'], Colors.red),
                            _buildNutrientInfo('Carbs', mealTypeSumData['carbsSum'], Colors.blue),
                            _buildNutrientInfo('Protein', mealTypeSumData['proteinSum'], Colors.green),
                            _buildNutrientInfo('Fat', mealTypeSumData['fatSum'], Colors.orange),
                          ],
                        )
                      : SizedBox.shrink();
                }
              },
            ),
          ),
          SizedBox(height: 8),
          Divider(), // Trennlinie hinzugefügt
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _mealDataFuture,
              builder: (context, dataSnapshot) {
                if (dataSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (dataSnapshot.hasError) {
                  return Center(child: Text('Error loading meal data'));
                }
                else if (!dataSnapshot.hasData || dataSnapshot.data!.isEmpty) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'No meals found',
          style: TextStyle(fontSize: 20),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
  await Navigator.pushNamed(
    context,
    '/searchFood',
    arguments: {
      'mealType': widget.mealType,
      'selectedDate': widget.selectedDate,
    },
  );
  // Nach dem Zurückkehren von der Suchseite die Daten neu laden
  _loadData();
},

          child: const Text('Add Meals'),
        ),
      ],
    ),
  );
}

                
                else {
                  return ListView.builder(
                    itemCount: dataSnapshot.data!.length,
                    itemBuilder: (BuildContext context, int index) {
                      final mealData = dataSnapshot.data![index];
                      return _buildMealRow(mealData);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealRow(Map<String, dynamic> mealData) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Food Name: ${mealData['foodName']}'),
                Text('Amount: ${mealData['amount']}'),
              ],
            ),
          ),
          Text('Calories: ${mealData['calories']}'),
          IconButton(
            onPressed: () {
              final String selectedDate =
                  '${widget.selectedDate.year}-${widget.selectedDate.month.toString().padLeft(2, '0')}-${widget.selectedDate.day.toString().padLeft(2, '0')}';
              final String mealType = widget.mealType;
              final String mealId = mealData['mealId'];

              deleteMeal(selectedDate, mealType, mealId).then((_) {
                setState(() {
                  // Aktualisieren Sie den Bildschirm nach dem Löschen des Mahlzeitelements
                  _mealDataFuture = getMealData(selectedDate, mealType);
                  _mealTypeSumFuture = getMealTypeSum(selectedDate, mealType);
                  _mealTypeTotalSumFuture = getMealSum(selectedDate);
                });
              });
            },
            icon: Icon(Icons.delete),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientInfo(String label, dynamic value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 20.0),
        ),
        Text(
          value.round().toString(),
          style: const TextStyle(color: Colors.white, fontSize: 18.0),
        ), // Umwandlung in double
      ],
    );
  }
}


import 'package:flutter/material.dart';
import '../../backend/nutrition_http.dart';

class BasicCaloriesPage extends StatefulWidget {
  @override
  _BasicCaloriesPageState createState() => _BasicCaloriesPageState();
}

class _BasicCaloriesPageState extends State<BasicCaloriesPage> {
  final TextEditingController alterController = TextEditingController();
  final TextEditingController gewichtController = TextEditingController();
  double groesse = 100.0; // Startwert für Größe
  String? selectedGender; // Variable zur Speicherung des ausgewählten Geschlechts

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Basic calorie calculator'),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(16.0),
          width: screenSize.width * 0.9,
          height: screenSize.height * 0.6,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButtonFormField<String>(
                value: selectedGender,
                hint: Text('Select gender', style: TextStyle(color: Colors.white)),
                onChanged: (String? value) {
                  setState(() {
                    selectedGender = value;
                  });
                },
                items: <String>['male', 'female'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(color: Colors.white)),
                  );
                }).toList(),
              ),
              SizedBox(height: 10),
              TextField(
                controller: alterController,
                decoration: InputDecoration(labelText: 'Age', labelStyle: TextStyle(color: Colors.white)),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.scale, color: Colors.white), // Icon für Gewicht
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: gewichtController,
                      decoration: InputDecoration(labelText: 'Weight', labelStyle: TextStyle(color: Colors.white)),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text('Height:', style: TextStyle(color: Colors.white)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Slider(
                      value: groesse,
                      min: 0,
                      max: 200,
                      divisions: 200,
                      label: groesse.round().toString(),
                      onChanged: (double value) {
                        setState(() {
                          groesse = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Text('${groesse.round()} cm', style: TextStyle(color: Colors.white)),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await berechneUndSpeichereGrundKalorien(
                    selectedGender!, // Geschlecht übergeben
                    int.parse(alterController.text),
                    double.parse(gewichtController.text),
                    groesse,
                    context,
                  );
                },
                child: Text('Calculate'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

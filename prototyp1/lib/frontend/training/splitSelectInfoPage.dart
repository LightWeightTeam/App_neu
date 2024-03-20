/*
import 'package:flutter/material.dart';
import '../../backend/training_http.dart';

class SplitSelectInfoPage extends StatefulWidget {
  @override
  _SplitSelectInfoPageState createState() => _SplitSelectInfoPageState();
}

class _SplitSelectInfoPageState extends State<SplitSelectInfoPage> {
  late Future<Map<String, Map<String, Map<String, List<Map<String, dynamic>>>>>> _trainingDataFuture;
  late String selectedGoal;
  late String selectedLevel;
  late String selectedSplit;
  late String day;
  late String planName;

  @override
  void initState() {
    super.initState();
    _trainingDataFuture = _loadTrainingDataFuture();
  }

  Future<Map<String, Map<String, Map<String, List<Map<String, dynamic>>>>>> _loadTrainingDataFuture() async {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      setState(() {
        selectedGoal = args['selectedGoal'];
        selectedLevel = args['selectedLevel'];
        selectedSplit = args['selectedSplit'];
        day = args['day'];
        planName = args['planName'];
      });
      return loadTrainingDataForDaySelectSplit(
        selectedGoal,
        selectedLevel,
        selectedSplit,
        day,
        planName,
      );
    } else {
      throw Exception('Arguments not found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Training Data for Day Select Split'),
      ),
      body: FutureBuilder(
        future: _trainingDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            Map<String, Map<String, Map<String, List<Map<String, dynamic>>>>> data = snapshot.data as Map<String, Map<String, Map<String, List<Map<String, dynamic>>>>>;
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                String key = data.keys.elementAt(index);
                Map<String, Map<String, List<Map<String, dynamic>>>> innerMap = data[key]!;
                return ExpansionTile(
                  title: Text(key),
                  children: innerMap.entries.map((entry) {
                    String innerKey = entry.key;
                    List<Map<String, dynamic>>? exercises = entry.value[innerKey];
                    if (exercises != null) {
                      return ListTile(
                        title: Text(innerKey),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: exercises.map((exercise) {
                            return Text('Reps: ${exercise['Reps']}, Sets: ${exercise['Sets']}, Number: ${exercise['number']}');
                          }).toList(),
                        ),
                      );
                    } else {
                      return SizedBox(); // Return an empty widget if exercises is null
                    }
                  }).toList(),
                );
              },
            );
          }
        },
      ),
    );
  }
}
*/
import 'package:flutter/material.dart';
import '../../backend/training_http.dart';

class SplitSelectInfoPage extends StatefulWidget {
  @override
  _SplitSelectInfoPageState createState() => _SplitSelectInfoPageState();
}

class _SplitSelectInfoPageState extends State<SplitSelectInfoPage> {
  late String selectedGoal;
  late String selectedLevel;
  late String selectedSplit;
  late String day;
  late String planName;
  List<Map<String, dynamic>> exercisesList = [];
  bool dataLoaded = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Extrahiere die Argumente
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    if (args != null && !dataLoaded) {
      selectedGoal = args['selectedGoal'];
      selectedLevel = args['selectedLevel'];
      selectedSplit = args['selectedSplit'];
      day = args['day'];
      planName = args['planName'];

      // Hier könnten Sie die Funktionalität zum Laden der Trainingsdaten aufrufen
      loadTrainingData();
      dataLoaded = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Training Split Informationen'),
      ),
      body: Center(
        child: exercisesList.isEmpty
            ? Text(
                'Daten werden geladen...',
                style: TextStyle(fontSize: 18.0),
              )
            : ListView.builder(
                itemCount: exercisesList.length,
                itemBuilder: (BuildContext context, int index) {
                  String exerciseName = exercisesList[index]['exerciseName'];
                  int reps = exercisesList[index]['Reps'];
                  int sets = exercisesList[index]['Sets'];
                  int number = exercisesList[index]['number'];

                  return ListTile(
                    title: Text('$exerciseName'),
                    subtitle: Text('Reps: $reps, Sets: $sets, Number: $number'),
                  );
                },
              ),
      ),
    );
  }

  void loadTrainingData() async {
    // Annahme: selectedGoal, selectedLevel, selectedSplit, day und planName sind bereits definiert
    Map<String, List<Map<String, dynamic>>> trainingData =
        await loadTrainingDataForDaySelectSplit(selectedGoal, selectedLevel, selectedSplit, day, planName);

    // Überprüfen, ob Daten erfolgreich geladen wurden
    if (trainingData.isNotEmpty) {
      // Iteriere über die Pläne und ihre Übungen
      trainingData.forEach((planName, exercises) {
        exercisesList.addAll(exercises);
      });
      // Sortiere die Übungen nach der Nummer
      exercisesList.sort((a, b) => a['number'].compareTo(b['number']));
    } else {
      print('Fehler beim Laden der Trainingsdaten.');
    }
    // Aktualisiere die Anzeige nach dem Laden der Daten
    setState(() {});
  }
}

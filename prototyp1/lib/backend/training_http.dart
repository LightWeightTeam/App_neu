import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

Future<void> saveSelectedTrainingPlan(BuildContext context, String selectedGoal, String selectedLevel, String selectedSplit, String currentDate) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? uid = prefs.getString('userUid');
  String? token = prefs.getString('userToken');

  const String url = 'https://rest-api-rho-hazel.vercel.app/training/saveTrainingData';

  final Map<String, dynamic> body = {
    'uid': uid,
    'selectedGoal': selectedGoal,
    'selectedLevel': selectedLevel,
    'selectedSplit': selectedSplit,
    'currentDate': currentDate,
  };

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      Navigator.pushNamed(context, '/hauptseite');
      
    } else {
      print('Fehler beim Speichern der Trainingsdaten - ${response.statusCode}: ${response.body}');
      // TODO: Funktion zum Anzeigen des Fehlers für den Benutzer
    }
  } catch (error) {
    print('Fehler beim Senden der Anfrage: $error');
    // TODO: Funktion zum Anzeigen des Fehlers für den Benutzer
  }
}


Future<Map<String, Map<String, List<Map<String, dynamic>>>>?> loadTrainingSplitData(String selectedGoal, String selectedLevel, String selectedSplit) async {
  const String url = 'https://rest-api-rho-hazel.vercel.app/training/TrainingSplitData';
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('userToken');

  Map<String, dynamic> requestData = {
    'selectedGoal': selectedGoal,
    'selectedLevel': selectedLevel,
    'selectedSplit': selectedSplit,
  };

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      String responseData = response.body;
      return processResponseTrainingSplitData(responseData);
    } else {
      print('Request failed with status: ${response.statusCode}');
      return null;
    }
  } catch (error) {
    print('HTTP request error: $error');
    return null;
  }
}

Map<String, Map<String, List<Map<String, dynamic>>>> processResponseTrainingSplitData(String responseData) {
  try {
    Map<String, dynamic> decodedData = jsonDecode(responseData);
    Map<String, dynamic> data = decodedData['data'];
    Map<String, Map<String, List<Map<String, dynamic>>>> processedData = {};

    data.forEach((dayName, dayData) {
      print('Day Name: $dayName');
      Map<String, List<Map<String, dynamic>>> planExercises = {};

      (dayData as Map<String, dynamic>).forEach((planName, exercisesList) {
        print('\tPlan Name: $planName');
        List<Map<String, dynamic>> exercises = [];

        (exercisesList as List<dynamic>).forEach((exerciseData) {
          exercises.add({
            'id': exerciseData['id'],
            'data': Map<String, dynamic>.from(exerciseData['data']),
          });
          print('\t\tExercise ID: ${exerciseData['id']}');
          print('\t\tExercise Data: ${exerciseData['data']}');
        });

        planExercises[planName] = exercises;
      });

      processedData[dayName] = planExercises;
    });

    return processedData;
  } catch (e) {
    print('Error processing response data: $e');
    return {};
  }
}


Future<Map<String, String>> splitNameForDay(String selectedGoal, String selectedLevel, String selectedSplit) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('userToken');
  
  const String url = 'https://rest-api-rho-hazel.vercel.app/training/SplitNameForDay';
  
  final Map<String, dynamic> body = {
    'selectedGoal': selectedGoal,
    'selectedLevel': selectedLevel,
    'selectedSplit': selectedSplit,
  };
  
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      print('Serverantwort: $data');
      
      // Hier werden die Daten in eine Map gespeichert
      Map<String, String> splitData = {};
      data.forEach((key, value) {
        splitData[key] = value.toString();
      });
      
      return splitData;
    } else {
      print('Fehler beim Abrufen der Daten - ${response.statusCode}: ${response.body}');
      // TODO: Funktion zum Anzeigen des Fehlers für den Benutzer
      return {};
    }
  } catch (error) {
    print('Fehler beim Senden der Anfrage: $error');
    // TODO: Funktion zum Anzeigen des Fehlers für den Benutzer
    return {};
  }
}

Future<Map<String, List<Map<String, dynamic>>>> loadTrainingDataForDaySelectSplit(String selectedGoal, String selectedLevel, String selectedSplit, String day, String planName) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('userToken');

  const String url = 'https://rest-api-rho-hazel.vercel.app/training/TrainingDataForDaySplitSelect';

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: json.encode({
        'selectedGoal': selectedGoal,
        'selectedLevel': selectedLevel,
        'selectedSplit': selectedSplit,
        'day': day,
        'planName': planName // Füge den planName Parameter hinzu
      }),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      return processResponseTrainingDataForDaySelectSplit(responseData); // Verarbeitete Daten zurückgeben
    } else {
      print('Fehler beim Abrufen der Daten. Statuscode: ${response.statusCode}');
      // TODO: Funktion zum Anzeigen des Fehlers für den Benutzer
      return {}; // Leeres Objekt oder null zurückgeben, je nach Bedarf
    }
  } catch (error) {
    print('Fehler bei der HTTP-Anfrage: $error');
    // TODO: Funktion zum Anzeigen des Fehlers für den Benutzer
    return {}; // Leeres Objekt oder null zurückgeben, je nach Bedarf
  }
}

Map<String, List<Map<String, dynamic>>> processResponseTrainingDataForDaySelectSplit(Map<String, dynamic> responseData) {
  Map<String, List<Map<String, dynamic>>> processedData = {};

  try {
    if (responseData['success'] == true) {
      List<dynamic> data = responseData['data'];

      data.forEach((exercise) {
        String id = exercise['id'];
        Map<String, dynamic>? exerciseData = exercise['data']; // Verwenden Sie ein Nullable-Map
        if (id != null && exerciseData != null && exerciseData.isNotEmpty) { // Überprüfen Sie, ob exerciseData nicht leer ist
          processedData.putIfAbsent(responseData['message'], () => []);
          processedData[responseData['message']]!.add({
            'exerciseName': id,
            'Reps': exerciseData['Reps'] ?? 0,
            'Sets': exerciseData['Sets'] ?? 0,
            'number': exerciseData['number'] ?? 0
          });
        }
      });
    } else {
      print('Fehler beim Abrufen der Daten: ${responseData['message']}');
      // TODO: Fehlerbehandlung
    }
  } catch (error) {
    print('Fehler bei der Verarbeitung der Daten: $error');
    // TODO: Fehlerbehandlung
  }

  return processedData;
}

StartingDayOfWeek getStartingDayOfWeek() {
      // Bestimme den Wochentag des aktuellen Datums
      int currentWeekday = DateTime.now().weekday;

      // Konvertiere den Wochentag in StartingDayOfWeek
      // Hier wird Montag als erster Tag der Woche festgelegt (können Sie ändern)
      switch (currentWeekday) {
        case DateTime.monday:
          return StartingDayOfWeek.monday;
        case DateTime.tuesday:
          return StartingDayOfWeek.tuesday;
        case DateTime.wednesday:
          return StartingDayOfWeek.wednesday;
        case DateTime.thursday:
          return StartingDayOfWeek.thursday;
        case DateTime.friday:
          return StartingDayOfWeek.friday;
        case DateTime.saturday:
          return StartingDayOfWeek.saturday;
        case DateTime.sunday:
        default:
          return StartingDayOfWeek.sunday;
      }
    }




Future<Map<String, List<Map<String, dynamic>>>> loadTrainingDataForDay(String day) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? uid = prefs.getString('userUid');
  String? token = prefs.getString('userToken');

  if (uid != null) {
    const String url = 'https://rest-api-rho-hazel.vercel.app/training/TrainingDataForDay';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: json.encode({'uid': uid, 'day': day}),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);
        return processResponseTrainingDataForDay(responseData); // Verarbeitete Daten zurückgeben
      } else {
        print('Fehler beim Abrufen der Daten. Statuscode: ${response.statusCode}');
        // TODO: Funktion zum Anzeigen des Fehlers für den Benutzer
        return {}; // Leeres Objekt oder null zurückgeben, je nach Bedarf
      }
    } catch (error) {
      print('Fehler bei der HTTP-Anfrage: $error');
      // TODO: Funktion zum Anzeigen des Fehlers für den Benutzer
      return {}; // Leeres Objekt oder null zurückgeben, je nach Bedarf
    }
  } else {
    print('Keine Benutzer-ID gefunden');
    // TODO: Funktion zum Anzeigen des Fehlers für den Benutzer
    return {}; // Leeres Objekt oder null zurückgeben, je nach Bedarf
  }
}

Map<String, List<Map<String, dynamic>>> processResponseTrainingDataForDay(Map<String, dynamic> responseData) {
  Map<String, List<Map<String, dynamic>>> processedData = {};

  try {
    if (responseData['success'] == true) {
      Map<String, dynamic> data = responseData['data'];

      data.forEach((splitName, splitData) {
        List<dynamic> exercises = splitData.values.first;

        List<Map<String, dynamic>> exercisesData = exercises.map((exercise) {
          String exerciseName = exercise['id'];
          Map<String, dynamic> exerciseDetails = exercise['data'];

          return {
            'exerciseName': exerciseName,
            'Reps': exerciseDetails['Reps'] ?? 0,
            'Sets': exerciseDetails['Sets'] ?? 0,
            'number': exerciseDetails['number'] ?? 0,
          };
        }).toList();

        processedData[splitName] = exercisesData;
      });
    } else {
      print('Fehler beim Abrufen der Daten: ${responseData['message']}');
      // TODO: Fehlerbehandlung
    }
  } catch (error) {
    print('Fehler bei der Verarbeitung der Daten: $error');
    // TODO: Fehlerbehandlung
  }

  return processedData;
}





//get Current Date
Future<DateTime?> getCurrentDate() async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? uid = prefs.getString('userUid');
    String? token = prefs.getString('userToken');
    
    if (uid == null || uid.isEmpty) {
      throw Exception('UID nicht gefunden oder leer');
    }

    final url = Uri.parse('https://rest-api-rho-hazel.vercel.app/training/getCurrentDate?uid=$uid');

    final response = await http.get(url, headers: <String, String>{
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json; charset=UTF-8',
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      final String? currentDateStr = data['currentDate'] as String?;
      
      if (currentDateStr != null) {
        DateTime? currentDate = DateTime.tryParse(currentDateStr);

        if (currentDate != null) {
          return currentDate;
        }
      }
      throw Exception('Ungültiges Datumformat');
    } else {
      throw Exception('Fehler beim Abrufen der Mahlzeiten-Daten: ${response.statusCode}');
    }
  } catch (e) {
    print('Fehler beim Abrufen der Mahlzeiten-Daten: $e');
    return null;
  }
}

Future<void> saveTrainingDataToFirebase(List<Map<String, dynamic>> workoutData, String exerciseID, String splitName, String selectedDate) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? uid = prefs.getString('userUid');
  String? token = prefs.getString('userToken');

  if (uid != null && token != null) {
    const String url = 'https://rest-api-rho-hazel.vercel.app/training/saveTrainingDataToFirebase'; // Ersetze 'URL_DER_REST_API' durch deine tatsächliche URL

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'uid': uid,
          'workoutData': workoutData,
          'exerciseID': exerciseID,
          'splitName': splitName,
          'selectedDate': selectedDate,
        }),
      );

      if (response.statusCode == 200) {
        print('Daten erfolgreich gespeichert');
      } else {
        print('Fehler beim Speichern der Daten. Statuscode: ${response.statusCode}');
        // TODO: Funktion zum Anzeigen des Fehlers für den Benutzer
      }
    } catch (error) {
      print('Fehler bei der HTTP-Anfrage: $error');
      // TODO: Funktion zum Anzeigen des Fehlers für den Benutzer
    }
  } else {
    print('Keine Benutzer-ID oder Token gefunden');
    // TODO: Funktion zum Anzeigen des Fehlers für den Benutzer
  }
}

Future<Map<String, dynamic>> getTrainingDataFromFirebase(String selectedDate, String splitName, String exercise) async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? uid = prefs.getString('userUid');
    String? token = prefs.getString('userToken');
    
    const String url = 'https://rest-api-rho-hazel.vercel.app/training/getTrainingDataFromFirebase';

    // Anfragekörper erstellen
    final Map<String, dynamic> requestBody = {
      'uid': uid,
      'selectedDate': selectedDate,
      'splitName': splitName,
      'exercise': exercise,
    };

    // HTTP-POST-Anfrage senden
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestBody),
    );

    // Überprüfen der Antwort
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return responseData;
    } else {
      print('Fehler beim Abrufen der Daten - ${response.statusCode}: ${response.body}');
      return {'success': false, 'message': 'Fehler beim Abrufen der Daten'};
    }
  } catch (error) {
    print('Fehler beim Senden der Anfrage: $error');
    return {'success': false, 'message': 'Fehler beim Senden der Anfrage'};
  }
}
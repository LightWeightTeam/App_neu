import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../popUpGreen.dart';
import '../popUpRed.dart';

// Funktion zur Suche von Lebensmittelitems
Future<List<Map<String, dynamic>>> searchFoodItems(String query, int pageNumber) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('userToken');

    final headers = <String, String>{
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json; charset=UTF-8',
    };

    final url = Uri.parse('https://rest-api-rho-hazel.vercel.app/nutrition/searchFoodItems?query=$query&pageNumber=$pageNumber');

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> foodList = data['foods']['food'];

      List<Map<String, dynamic>> foodItems = [];

      for (var item in foodList) {
        foodItems.add({
          'food_name': item['food_name'][0],
          'food_description': item['food_description'][0],
        });
      }

      return foodItems;
    } else {
      print('Fehler beim Suchen von Lebensmitteln: ${response.statusCode}');
      // Hier können Sie eine Meldung anzeigen oder andere Aktionen ausführen
      return [];  // Leere Liste zurückgeben, wenn ein Fehler auftritt
    }
  } catch (e) {
    print('Fehler beim Suchen von Lebensmitteln: $e');
    // Hier können Sie eine Meldung anzeigen oder andere Aktionen ausführen
    return [];  // Leere Liste zurückgeben, wenn ein Fehler auftritt
  }
}

Future<void> loadFoodPage(
  String query,
  List<Map<String, dynamic>> searchResults,
  bool loadingMore,
  int pageNumber,
  TextEditingController searchController,
  Function(bool) setLoadingMore,
  Function(List<Map<String, dynamic>>) setSearchResults,
  Function(int) setPageNumber,
) async {
  try {
    if (!loadingMore) {
      pageNumber = 1;
      searchResults.clear();
    }

    List<Map<String, dynamic>> foods = await searchFoodItems(query, pageNumber);

    if (foods.isNotEmpty) {
      searchResults.addAll(foods);
      pageNumber++;
    }

    setLoadingMore(false); // Set loading more to false after the results are fetched
    setSearchResults(searchResults);
    setPageNumber(pageNumber);
  } catch (error) {
    print('Fehler bei der Suche nach Lebensmitteln: $error');
    // Hier können Sie eine Meldung anzeigen oder andere Aktionen ausführen
  }
}

Future<Map<String, dynamic>> adjustNutritionData(double newAmount, Map<String, dynamic> originalNutritionData) async {
  try {
    int adjustedCalories = ((originalNutritionData['calories'] / originalNutritionData['amount']['value']) * newAmount).round();
    double adjustedFat = (originalNutritionData['fat'] / originalNutritionData['amount']['value']) * newAmount;
    adjustedFat = double.parse(adjustedFat.toStringAsFixed(2));
    double adjustedCarbs = (originalNutritionData['carbs'] / originalNutritionData['amount']['value']) * newAmount;
    adjustedCarbs = double.parse(adjustedCarbs.toStringAsFixed(2));
    double adjustedProtein = (originalNutritionData['protein'] / originalNutritionData['amount']['value']) * newAmount;
    adjustedProtein = double.parse(adjustedProtein.toStringAsFixed(2));

    int adjustedAmountValue = newAmount.toInt();
    String adjustedAmountUnit = originalNutritionData['amount']['unit'];

    return {
      'calories': adjustedCalories,
      'fat': adjustedFat,
      'carbs': adjustedCarbs,
      'protein': adjustedProtein,
      'amount': {
        'value': adjustedAmountValue,
        'unit': adjustedAmountUnit,
      },
    };
  } catch (error) {
    print('Fehler bei der Anpassung der Nährwertdaten: $error');
    // Hier können Sie eine Meldung anzeigen oder andere Aktionen ausführen
    return {};
  }
}


// Funktion zum Splitten von Nährwertdaten
Future<Map<String, dynamic>> splitNutritionData(String nutritionData) async {
  try {
    List<String> values = nutritionData.split('-');

    int calories = 0;
    double fat = 0.0;
    double carbs = 0.0;
    double protein = 0.0;
    int amountValue = 0;
    String amountUnit = '';

    // Extrahiere die Menge und Einheit
    RegExp amountRegex = RegExp(r'(\d+)\s*([a-zA-Z]+)');
    String amountSection = values[0].trim();
    Match? amountMatch = amountRegex.firstMatch(amountSection);

    if (amountMatch != null) {
      amountValue = int.tryParse(amountMatch.group(1)!) ?? 0;
      amountUnit = amountMatch.group(2)!;
    }

    // Extrahiere Nährwertinformationen
    for (int i = 1; i < values.length; i++) {
      List<String> nutrientInfo = values[i].split('|');

      for (String info in nutrientInfo) {
        List<String> parts = info.split(':');
        String nutrientName = parts[0].trim();
        String nutrientValue = parts[1].trim().replaceAll(RegExp(r'[a-zA-Z]'), '');

        if (nutrientName.contains('Calories')) {
          calories = int.tryParse(nutrientValue) ?? 0;
        } else if (nutrientName.contains('Fat')) {
          fat = double.tryParse(nutrientValue) ?? 0.0;
        } else if (nutrientName.contains('Carbs')) {
          carbs = double.tryParse(nutrientValue) ?? 0.0;
        } else if (nutrientName.contains('Protein')) {
          protein = double.tryParse(nutrientValue) ?? 0.0;
        }
      }
    }

    return {
      'calories': calories,
      'fat': fat,
      'carbs': carbs,
      'protein': protein,
      'amount': {
        'value': amountValue,
        'unit': amountUnit,
      },
    };
  } catch (error) {
    print('Fehler beim Splitten der Nährwertdaten: $error');
    // Hier können Sie eine Meldung anzeigen oder andere Aktionen ausführen
    return {};
  }
}


// Funktion zum Speichern von Nährwertdaten in Firebase
Future<void> saveNutritionDataToFirebase({
  required int calories,
  required double fat,
  required double carbs,
  required double protein,
  required String foodName,
  required String amount,
  required String selectedDate,
  required String mealType,
  required BuildContext context,
}) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('userUid');
    final String? token = prefs.getString('userToken');

    // Setze leere oder null Daten auf 0, bevor du sie sendest
    calories ??= 0;
    fat ??= 0.0;
    carbs ??= 0.0;
    protein ??= 0.0;

    if (uid != null) {
      String serverUrl = 'https://rest-api-rho-hazel.vercel.app/nutrition/saveNutritionData';

      Map<String, dynamic> data = {
        'uid': uid,
        'calories': calories,
        'fat': fat,
        'carbs': carbs,
        'protein': protein,
        'foodName': foodName,
        'amount': amount,
        'selectedDate': selectedDate.toString(),
        'mealType': mealType,
      };

      final response = await http.post(
        Uri.parse(serverUrl),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        print('Nährwertdaten erfolgreich an die API übergeben und in Firestore gespeichert');
        // Hier können Sie weitere Aktionen ausführen
      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: NotificationPopupGreen(message: 'Entry successfully saved'),
        duration: Duration(seconds: 3),
      ),
    );
      Navigator.pushNamed(context, '/nutritionPage');
      } else {
        print('Fehler beim Übergeben der Nährwertdaten an die API - ${response.statusCode}: ${response.body}');
      }
    } else {
      print('UID ist nicht vorhanden');
    }
  } catch (error) {
    print('Fehler beim Senden der Nährwertdaten an den Server: $error');
    // Hier können Sie eine Meldung anzeigen oder andere Aktionen ausführen
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: NotificationPopupRed(message: error.toString()),
        duration: Duration(seconds: 3),
      ),
    );
  }
}

Future<Map<String, dynamic>?> getMealSum(String selectedDate) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? uid = prefs.getString('userUid');
    final String? token = prefs.getString('userToken');

    if (uid == null || uid.isEmpty) {
      throw Exception('UID nicht gefunden oder leer');
    }

    final url = Uri.parse('https://rest-api-rho-hazel.vercel.app/nutrition/getMealSum?uid=$uid&selectedDate=$selectedDate');

    final response = await http.get(url, headers: <String, String>{
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json; charset=UTF-8',
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      final Map<String, dynamic> mealTotalSumData = {
        'totalCalories': data['totalCalories'] ?? 0,
        'totalCarbs': (data['totalCarbs'] ?? 0).toDouble(),
        'totalFat': (data['totalFat'] ?? 0).toDouble(),
        'totalProtein': (data['totalProtein'] ?? 0).toDouble(),
      };

      return mealTotalSumData;
    }
}

// Funktion zum Abrufen der Grundkalorien eines Benutzers
Future<Map<String, dynamic>> getBasicCalories() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? uid = prefs.getString('userUid');
  final String? token = prefs.getString('userToken');

  if (uid == null) {
    throw Exception('User ID not found in SharedPreferences');
  }

  final url = Uri.parse('https://rest-api-rho-hazel.vercel.app/nutrition/getBasicCalories?uid=$uid');

  try {
    final response = await http.get(url, headers: <String, String>{
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json; charset=UTF-8',
    });

    if (response.statusCode == 200) {
    // Erfolgreiche Anfrage
    final Map<String, dynamic> responseData = json.decode(response.body);
    // Extrahieren und Konvertieren von 'basicCalories' zu einem int
    final double basicCaloriesDouble = double.parse(responseData['basicCalories'].toString());
    final int basicCalories = basicCaloriesDouble.toInt();
    return {'basicCalories': basicCalories};
    }else if (response.statusCode == 401) {
      // Unzureichende Berechtigung, Token möglicherweise abgelaufen
      throw Exception('Unauthorized: ${response.statusCode}');
    } else {
      // Andere fehlerhafte Anfragen
      throw Exception('Failed to load basic calories: ${response.statusCode}');
    }
  } catch (error) {
    // Netzwerkfehler
    throw Exception('Network error: $error');
  }
}



Future<List<Map<String, dynamic>>> getMealData(String selectedDate, String mealType) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('userUid');
    final String? token = prefs.getString('userToken');

    if (uid == null || uid.isEmpty) {
      throw Exception('UID nicht gefunden oder leer');
    }

    final url = Uri.parse('https://rest-api-rho-hazel.vercel.app/nutrition/getMeal?uid=$uid&selectedDate=$selectedDate&mealType=$mealType');

    final response = await http.get(url, headers: <String, String>{
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json; charset=UTF-8',
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      List<Map<String, dynamic>> mealDataArray = [];

      for (var meal in data) {
        mealDataArray.add({
          'amount': meal['amount'] ?? '',
          'calories': meal['calories'] ?? 0,
          'carbs': meal['carbs'] ?? 0,
          'fat': meal['fat'] ?? 0,
          'foodName': meal['foodName'] ?? '',
          'mealId': meal['mealId'] ?? '',
          'protein': meal['protein'] ?? 0,
        });
      }

      return mealDataArray;
    } else {
      throw Exception('Fehler beim Abrufen der Mahlzeiten-Daten: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Fehler beim Abrufen der Mahlzeiten-Daten: $e');
  }
}


Future<Map<String, dynamic>?> getMealTypeSum(String selectedDate, String mealType) async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? uid = prefs.getString('userUid');
    final String? token = prefs.getString('userToken');

    if (uid == null || uid.isEmpty) {
      throw Exception('UID nicht gefunden oder leer');
    }

    final url = Uri.parse('https://rest-api-rho-hazel.vercel.app/nutrition/getMealTypeSum?uid=$uid&selectedDate=$selectedDate&mealType=$mealType');

    final response = await http.get(url, headers: <String, String>{
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json; charset=UTF-8',
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      final Map<String, dynamic> mealSumData = {
        'caloriesSum': data['caloriesSum'] ?? 0,
        'carbsSum': (data['carbsSum'] ?? 0).toDouble(),
        'fatSum': (data['fatSum'] ?? 0).toDouble(),
        'proteinSum': (data['proteinSum'] ?? 0).toDouble(),
      };

      return mealSumData;
    } else {
      throw Exception('Fehler beim Abrufen der Mahlzeiten-Daten: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Fehler beim Abrufen der Mahlzeiten-Daten: $e');
  }
}


Future<void> deleteMeal(String selectedDate, String mealType, String mealId) async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? uid = prefs.getString('userUid');
    final String? token = prefs.getString('userToken');

    if (uid == null || uid.isEmpty) {
      throw Exception('UID nicht gefunden oder leer');
    }

    final url = Uri.parse('https://rest-api-rho-hazel.vercel.app/nutrition/deleteMeal?uid=$uid&selectedDate=$selectedDate&mealType=$mealType&mealId=$mealId');

    final response = await http.get(url, headers: <String, String>{
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json; charset=UTF-8',
    });

    if (response.statusCode == 200) {
      print('Erfolgreich gelöscht');
    } else {
      print('Fehler: ${response.statusCode}');
    }
  } catch (error) {
    print('Fehler beim Senden der Anfrage: $error');
  }
}

Future<Map<String, double>> calculateNutritionIntake(String selectedDate) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('userToken');
    final String? uid = prefs.getString('userUid');

    final headers = <String, String>{
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json; charset=UTF-8',
    };

    final url = Uri.parse('https://rest-api-rho-hazel.vercel.app/nutrition/calculateNutritionIntake?uid=$uid&selectedDate=$selectedDate');

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      return {
        'proteinIntakeGrams': data['proteinIntakeGrams'],
        'fatIntakeGrams': data['fatIntakeGrams'],
        'carbIntakeGrams': data['carbIntakeGrams'],
      };
    } else {
      print('Fehler beim Berechnen der Nährstoffaufnahme: ${response.statusCode}');
      return {};
    }
  } catch (error) {
    print('Fehler beim Berechnen der Nährstoffaufnahme: $error');
    return {};
  }
}

Future<Map<String, dynamic>?> getMealNumber(String selectedDate) async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? uid = prefs.getString('userUid');
    final String? token = prefs.getString('userToken');

    if (uid == null || uid.isEmpty) {
      throw Exception('UID nicht gefunden oder leer');
    }

    final url = Uri.parse('https://rest-api-rho-hazel.vercel.app/nutrition/getMealNumber?uid=$uid&selectedDate=$selectedDate');

    final response = await http.get(url, headers: <String, String>{
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json; charset=UTF-8',
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      print(data);
      return data;
    } else {
      throw Exception('Fehler beim Abrufen des Mahlzeitentyps: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Fehler beim Abrufen des Mahlzeitentyps: $e');
  }
}

// Funktion zur Berechnung und Speicherung der Grundkalorien
Future<void> berechneUndSpeichereGrundKalorien(
  String geschlecht,
  int alter,
  double gewicht,
  double groesse,
  BuildContext context,
) async {
    // Eingabeüberprüfung
    if (geschlecht.isEmpty || alter <= 0 || gewicht <= 0 || groesse <= 0) {
      throw Exception('Ungültige Eingabewerte');
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('userUid');
    String? token = prefs.getString('userToken');
    String serverUrl = 'https://rest-api-rho-hazel.vercel.app/nutrition/saveBasicCalories';

    Map<String, dynamic> data = {
      'uid': uid,
      'gender': geschlecht,
      'age': alter,
      'weight': gewicht,
      'height': groesse,
    };

    final response = await http.post(
      Uri.parse(serverUrl),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      print('Response Body: ${response.body}');
      final Map<String, dynamic> result = json.decode(response.body);
      double grundKalorien = result['basicCalories'];

    // Benachrichtigung anzeigen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: NotificationPopupGreen(message: 'Entry successfully saved'),
        duration: Duration(seconds: 3),
      ),
    );
    Navigator.pushNamed(context, '/planSelect');
    } else {
      print('Fehler beim Berechnen der Grundkalorien - ${response.statusCode}: ${response.body}');
    }
}

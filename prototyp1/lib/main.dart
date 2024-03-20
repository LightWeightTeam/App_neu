import 'package:flutter/material.dart';
import 'frontend/login/startseite.dart';
import 'frontend/login/login.dart';
import 'frontend/login/register.dart';
import 'frontend/nutrition/foodTracking.dart';
import 'frontend/nutrition/searchFood.dart';
import 'frontend/nutrition/foodDetailPage.dart';
import 'frontend/nutrition/previousAddsPage.dart';
import 'frontend/nutrition/basicCalories.dart';

import 'frontend/training/planSelectPage.dart';
import 'frontend/training/splitSelectPage.dart';
import 'frontend/training/trainingPage.dart';
import 'frontend/training/splitSelectInfoPage.dart';
import 'frontend/training/notebook.dart';
import 'frontend/training/previousWorkout.dart';
import 'frontend/MainPage.dart';
import 'backend/login_http.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final String? uid = await getUid();
  final String? token = await getToken();

  String initialRoute = '/start';

  if (uid != null && token != null) {
    initialRoute = '/hauptseite';
  }

  runApp(MaterialApp(
    navigatorKey: navigatorKey,
    title: 'Meine Flutter App',
    theme: ThemeData.dark(),
    initialRoute: initialRoute,
    routes: {
      '/login': (context) => LoginPage(),
      '/register': (context) => RegisterPage(),
      '/start': (context) => Startseite(),
      '/nutritionPage': (context) => FoodTracking(),
      '/searchFood': (context) => SearchPage(),
      '/training': (context) => TrainingPage(),
      '/foodDetailPage': (context) {
        final Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return FoodDetailPage(
          foodDetails: args['foodDetails'],
          mealType: args['mealType'],
          selectedDate: args['selectedDate'],
        );
      }, 
      '/previousAddsPage': (context) {
        final Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return PreviousAddsPage(
          mealType: args['mealType'],
          selectedDate: args['selectedDate'],
        );
      },
      '/basicCalories': (context) => BasicCaloriesPage(),
      '/planSelect': (context) => PlanSelectPage(),
      '/splitSelect': (context) => SplitSelectPage(),
      '/splitSelectInfo': (context) => SplitSelectInfoPage(),
      '/hauptseite': (context) => HauptseitePage(),
      '/noteBook': (context) => Notebook(),
      '/previousWorkout': (context) => PreviousWorkoutPage(),
    },
  ));
}

final navigatorKey = GlobalKey<NavigatorState>();

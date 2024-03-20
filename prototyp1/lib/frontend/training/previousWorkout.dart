import 'package:flutter/material.dart';
import '../../backend/training_http.dart';

class PreviousWorkoutPage extends StatefulWidget {
  @override
  _PreviousWorkoutPageState createState() => _PreviousWorkoutPageState();
}

class _PreviousWorkoutPageState extends State<PreviousWorkoutPage> {
  Future<Map<String, dynamic>> _getPreviousWorkoutData() async {
    // Abrufen der Argumente von ModalRoute
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final String exercise = arguments['exerciseName'];
    final String selectedDate = arguments['formattedDate'];
    final String splitName = 'Push'; // Hier können Sie den Split-Namen festlegen oder dynamisch abrufen

    return await getTrainingDataFromFirebase(selectedDate, splitName, exercise);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Previous Workout'),
      ),
      body: Center(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _getPreviousWorkoutData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final Map<String, dynamic> data = snapshot.data!;
              if (data['success']) {
                // Handle successful response
                return Text('Previous workout data: ${data.toString()}');
              } else {
                // Handle unsuccessful response
                return Text('Failed to fetch previous workout data: ${data['message']}');
              }
            }
          },
        ),
      ),
    );
  }
}

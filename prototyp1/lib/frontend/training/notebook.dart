import 'package:flutter/material.dart';
import '../../backend/training_http.dart';
import 'dart:async';

class Notebook extends StatefulWidget {
  @override
  _NotebookState createState() => _NotebookState();
}

class _NotebookState extends State<Notebook> {
  late Timer _timer;
  int _seconds = 0;
  bool _isTimerRunning = false;
  String _selectedExercise = '';
  int _sets = 0;
  List<TextEditingController> _repControllers = [];
  List<TextEditingController> _weightControllers = [];

  List<Map<String, dynamic>> workoutData = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
      setState(() {
        _sets = arguments['sets'];
      });
    });
  }

  String _formatTimer(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$hours:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _toggleTimer() {
    if (_isTimerRunning) {
      _timer.cancel();
    } else {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          _seconds++;
        });
      });
    }
    _isTimerRunning = !_isTimerRunning;
  }

  void _pauseTimer() {
    if (_isTimerRunning) {
      _timer.cancel();
      _isTimerRunning = false;
    }
  }

  void _stopTimer() {
    _timer.cancel();
    setState(() {
      _seconds = 0;
      _isTimerRunning = false;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  List<Widget> _generateInputs() {
    List<Widget> inputs = [];
    for (int i = 0; i < _sets; i++) {
      TextEditingController repController = TextEditingController();
      TextEditingController weightController = TextEditingController();
      _repControllers.add(repController);
      _weightControllers.add(weightController);
      inputs.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: repController,
              decoration: InputDecoration(labelText: 'Reps in set ${i + 1}'),
            ),
            TextField(
              controller: weightController,
              decoration: InputDecoration(labelText: 'Weight in set ${i + 1}'),
            ),
          ],
        ),
      );
    }
    return inputs;
  }

  void _saveWorkout() {
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final String exerciseName = arguments['exerciseName'];
    final String formattedDate = arguments['selectedDate'];

    workoutData.clear();
    for (int i = 0; i < _sets; i++) {
      workoutData.add({
        'weight': _weightControllers[i].text,
        'reps': _repControllers[i].text,
      });
    }
    _repControllers.clear();
    _weightControllers.clear();
    setState(() {
      _sets = 0;
    });

    saveTrainingDataToFirebase(workoutData, exerciseName, 'Push', formattedDate); // Hier wird saveTrainingDataToFirebase aufgerufen
  }

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final String exerciseName = arguments['exerciseName'];
    final int reps = arguments['reps'];
    final int sets = arguments['sets'];
    final String formattedDate = arguments['selectedDate'];

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
                Expanded(child: Container()),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Image.asset(
                    'assets/login_App.png',
                    height: 25,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Exercise: $exerciseName',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              Text(
                'recommended: Reps: $reps, Sets: $_sets',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Text(
                'Timer: ${_formatTimer(_seconds)}',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: _toggleTimer,
                    child: Text(_isTimerRunning ? 'Pause' : 'Start'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _pauseTimer,
                    child: Text('Pause'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: !_isTimerRunning ? null : _stopTimer,
                    child: const Text('Stop'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                onChanged: (value) {
                  setState(() {
                    _sets = int.tryParse(value) ?? 0;
                  });
                },
                decoration: InputDecoration(labelText: 'Sets'),
              ),
              const SizedBox(height: 20),
              ..._generateInputs(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveWorkout,
                child: const Text('Save Workout'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/previousWorkout',
                    arguments: {
                      'exerciseName': exerciseName,
                      'formattedDate': formattedDate,
                    },
                  );
                },
                child: const Text('Go to Previous Workout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Notebook(),
  ));
}

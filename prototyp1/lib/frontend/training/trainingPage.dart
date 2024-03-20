/*
// Training.dart
import 'package:flutter/material.dart';
import 'package:prototyp1/frontend/training/notebook.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:video_player/video_player.dart';
import 'package:prototyp1/frontend/training/exercise_showcase.dart';
import '../../backend/training_http.dart';

class Training extends StatefulWidget {
  @override
  _TrainingState createState() => _TrainingState();
}

class _TrainingState extends State<Training> {
  late DateTime selectedDate;
  late DateTime _focusedDay;
  late String trainingDay;
  List<String> exercises = [];
  int currentExerciseIndex = 0;
  late VideoPlayerController _videoController;
  late bool _isVideoPlaying;
  int sets = 3;
  int repsPerSet = 10;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    selectedDate = _focusedDay;
    _updateTrainingDay(_focusedDay);
    _initializeVideoController();
    _isVideoPlaying = true;
  }

  void _initializeVideoController() {
    _videoController = VideoPlayerController.asset('assets/Liegestuetze.mp4')
      ..initialize().then((_) {
        setState(() {});
        if (_isVideoPlaying) {
          _videoController.play();
        }
      });

    _videoController.addListener(_checkVideoEnd);
  }

void _checkVideoEnd() {
  if (_videoController.value.position == _videoController.value.duration) {
    if (_videoController.value.isPlaying) {
      _videoController.pause();
      _videoController.seekTo(Duration.zero);
      _videoController.play();
    }
  }
}


  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  void _updateTrainingDay(DateTime date) {
    final int dayOfWeek = date.weekday;
    setState(() {
      trainingDay = 'Trainingstag $dayOfWeek';
      exercises = _generateExercises(dayOfWeek);
    });
  }

  List<String> _generateExercises(int dayNumber) {
    List<String> generatedExercises = [];
    for (int i = 1; i <= 10; i++) {
      generatedExercises.add('Übung $dayNumber.$i');
    }
    return generatedExercises;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      selectedDate = selectedDay;
      _focusedDay = focusedDay;
      _updateTrainingDay(selectedDay);
    });
  }

  void _navigateToNextExercise() {
    setState(() {
      currentExerciseIndex = (currentExerciseIndex + 1) % exercises.length;
    });
  }

  void _navigateToPreviousExercise() {
    setState(() {
      currentExerciseIndex =
          (currentExerciseIndex - 1 + exercises.length) % exercises.length;
    });
  }

  void _toggleVideoPlayback() {
    if (_videoController.value.isPlaying) {
      _videoController.pause();
      _isVideoPlaying = false;
    } else {
      _videoController.play();
      _isVideoPlaying = true;
    }
  }

  void _navigateToExerciseShowcase() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseShowcase(
          exerciseName:
              exercises.isNotEmpty ? exercises[currentExerciseIndex] : '',
          videoController: _videoController,
        ),
      ),
    );
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
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: TableCalendar(
                  focusedDay: _focusedDay,
                  firstDay: DateTime(2024, 1, 1),
                  lastDay: DateTime(2028, 12, 31),
                  calendarFormat: CalendarFormat.week,
                  selectedDayPredicate: (day) {
                    return isSameDay(selectedDate, day);
                  },
                  onDaySelected: _onDaySelected,
                ),
              ),
              const SizedBox(height: 15),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trainingDay,
                      style: TextStyle(fontSize: 22, color: Colors.white),
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: _navigateToExerciseShowcase,
                      child: Text(
                        exercises.isNotEmpty
                            ? exercises[currentExerciseIndex]
                            : '',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Sets: $sets',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Reps per Set: $repsPerSet',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: _navigateToPreviousExercise,
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward),
                    onPressed: _navigateToNextExercise,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Notebook(),
                      ),
                    );
                  },
                  child: const Text('Go to Notebook'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 25, horizontal: 50),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../backend/training_http.dart';

class TrainingPage extends StatefulWidget {
  @override
  _TrainingPageState createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late DateTime _startingDay;
  List<Map<String, dynamic>> exercisesList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _startingDay = DateTime.utc(2023, 1, 1); // Setze den Starttag auf den Anfang der Woche
    _loadTrainingData(_selectedDay);
  }

  Future<void> _loadTrainingData(DateTime selectedDay) async {
    setState(() {
      isLoading = true;
      exercisesList.clear();
    });

    String dayId = _getDayId(selectedDay);
    Map<String, List<Map<String, dynamic>>> trainingData = await loadTrainingDataForDay(dayId);

    if (trainingData.isNotEmpty) {
      trainingData.forEach((splitName, exercises) {
        exercisesList.addAll(exercises);
      });
      exercisesList.sort((a, b) => a['number'].compareTo(b['number']));
    } else {
      print('Keine Trainingsdaten gefunden.');
    }

    setState(() {
      isLoading = false;
    });
  }

  String _getDayId(DateTime day) {
    int diff = day.difference(_startingDay).inDays % 7;
    return 'day${diff + 1}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Training'),
      ),
      body: Column(
        children: [
          TableCalendar(
            calendarFormat: CalendarFormat.week,
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(3000, 12, 31),
            startingDayOfWeek: StartingDayOfWeek.sunday,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _loadTrainingData(selectedDay);
              });
            },
          ),
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : exercisesList.isNotEmpty
                    ? ListView.builder(
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
                      )
                    : Center(
                        child: Text('Keine Trainingsdaten gefunden.'),
                      ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/noteBook');
            },
            child: Text('Notebook'),
          ),
        ],
      ),
    );
  }
}
*/
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../backend/training_http.dart';

class TrainingPage extends StatefulWidget {
  @override
  _TrainingPageState createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late DateTime _startingDay;
  List<Map<String, dynamic>> exercisesList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _startingDay = DateTime.utc(2023, 1, 1); // Setze den Starttag auf den Anfang der Woche
    _loadTrainingData(_selectedDay);
  }

  Future<void> _loadTrainingData(DateTime selectedDay) async {
    setState(() {
      isLoading = true;
      exercisesList.clear();
    });

    String dayId = _getDayId(selectedDay);
    Map<String, List<Map<String, dynamic>>> trainingData = await loadTrainingDataForDay(dayId);

    if (trainingData.isNotEmpty) {
      trainingData.forEach((splitName, exercises) {
        exercisesList.addAll(exercises);
      });
      exercisesList.sort((a, b) => a['number'].compareTo(b['number']));
    } else {
      print('Keine Trainingsdaten gefunden.');
    }

    setState(() {
      isLoading = false;
    });
  }

  String _getDayId(DateTime day) {
    int diff = day.difference(_startingDay).inDays % 7;
    return 'day${diff + 1}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Training'),
      ),
      body: Column(
        children: [
          TableCalendar(
            calendarFormat: CalendarFormat.week,
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(3000, 12, 31),
            startingDayOfWeek: StartingDayOfWeek.sunday,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _loadTrainingData(selectedDay);
              });
            },
          ),
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : exercisesList.isNotEmpty
                    ? ListView.builder(
                        itemCount: exercisesList.length,
                        itemBuilder: (BuildContext context, int index) {
                          String exerciseName = exercisesList[index]['exerciseName'];
                          int reps = exercisesList[index]['Reps'];
                          int sets = exercisesList[index]['Sets'];
                          int number = exercisesList[index]['number'];
                          String formattedDate =
                          '${_selectedDay.year}-${_selectedDay.month.toString().padLeft(2, '0')}-${_selectedDay.day.toString().padLeft(2, '0')}';
                          return InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/noteBook',
                                arguments: {
                                  'exerciseName': exerciseName,
                                  'reps': reps,
                                  'sets': sets,
                                  'selectedDate': formattedDate,
                                },
                              );
                            },
                            child: ListTile(
                              title: Text('$exerciseName'),
                              subtitle: Text('Reps: $reps, Sets: $sets, Number: $number'),
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Text('Keine Trainingsdaten gefunden.'),
                      ),
          ),
        ],
      ),
    );
  }
}

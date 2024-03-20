import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ExerciseShowcase extends StatefulWidget {
  final String exerciseName;
  final VideoPlayerController videoController;

  ExerciseShowcase({required this.exerciseName, required this.videoController});

  @override
  _ExerciseShowcaseState createState() => _ExerciseShowcaseState();
}

class _ExerciseShowcaseState extends State<ExerciseShowcase> {
  late VideoPlayerController _videoController;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _videoController = widget.videoController;
    _videoController.addListener(() {
      final isPlaying = _videoController.value.isPlaying;
      if (isPlaying != _isPlaying) {
        setState(() {
          _isPlaying = isPlaying;
        });
      }
    });
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              widget.exerciseName,
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (_isPlaying) {
                _videoController.pause();
              } else {
                _videoController.play();
              }
            },
            child: AspectRatio(
              aspectRatio: _videoController.value.aspectRatio,
              child: VideoPlayer(_videoController),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 30.0),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
              bottomLeft: Radius.circular(20.0),
              bottomRight: Radius.circular(20.0),
            ),
          ),
          height: 60.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                child: IconButton(
                  icon: Image.asset(
                    'assets/hantel_App.png',
                    width: 30,
                    height: 30,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/training');
                  },
                ),
              ),
              SizedBox(
                child: IconButton(
                  icon: Image.asset(
                    'assets/apfel_App.png',
                    width: 30,
                    height: 30,
                  ),
                  onPressed: () {
                  },
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                ),
                width: 100,
                height: 100,
                margin: const EdgeInsets.only(bottom: 0),
                child: IconButton(
                  icon: Image.asset(
                    'assets/Logo_Menu_App.png',
                    width: 80,
                    height: 80,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/hauptseite');
                  },
                ),
              ),
              SizedBox(
                child: IconButton(
                  icon: Image.asset(
                    'assets/kalender_App.png',
                    width: 30,
                    height: 30,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/nutritionPage');
                  },
                ),
              ),
              SizedBox(
                child: IconButton(
                  icon: Image.asset(
                    'assets/dreiPunkte_App.png',
                    width: 30,
                    height: 30,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/planSelect');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

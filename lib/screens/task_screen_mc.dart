import 'dart:convert';
import 'package:flutter/material.dart';
import '../user_database.dart';
import 'package:lottie/lottie.dart';
import 'package:floating_animation/floating_animation.dart';

class TaskScreenMc extends StatefulWidget {
  final int taskId;
  final int topicId;
  final int userId;
  const TaskScreenMc({super.key, required this.taskId, required this.topicId, required this.userId});

  @override
  State<TaskScreenMc> createState() => _TaskScreenMcState();
}

class _TaskScreenMcState extends State<TaskScreenMc> {
  Map<String, dynamic>? task;
  String? _selectedOption;
  String? _result;
  late Color backgroundColor;
  late Color containerColor;
  late Color taskTextColor;
  late Color circlesColor;
  List<Offset?> _fullScreenPoints = [];

  @override
  void initState() {
    super.initState();
    _loadTask();
    _setThemeForTopic();
  }

  void _setThemeForTopic() {
    switch (widget.topicId) {
      case 1:
        backgroundColor = const Color.fromARGB(255, 255, 245, 181);
        containerColor = const Color.fromARGB(255, 255, 237, 124);
        taskTextColor = const Color.fromARGB(255, 255, 237, 124);
        circlesColor = const Color(0xFFFDF7B5);
        break;
      case 2:
        backgroundColor = const Color.fromRGBO(199, 217, 255, 1);
        containerColor = const Color.fromRGBO(146, 181, 255, 1);
        taskTextColor = const Color.fromRGBO(146, 181, 255, 1);
        circlesColor = const Color(0xFFC9E7FC);
        break;
      case 3:
        backgroundColor = const Color.fromRGBO(255, 219, 219, 1);
        containerColor = const Color.fromRGBO(248, 186, 186, 1);
        taskTextColor = Color.fromRGBO(248, 186, 186, 1);
        circlesColor = Colors.redAccent;
        break;
      case 4:
        backgroundColor = const Color.fromRGBO(255, 229, 241, 1);
        containerColor = const Color.fromRGBO(251, 190, 218, 1);
        taskTextColor = const Color.fromRGBO(251, 190, 218, 1);
        circlesColor = const Color(0xFFF8E1F0);
        break;
      default:
        backgroundColor = Colors.white;
        containerColor = Colors.grey[200]!;
        taskTextColor = Colors.blueAccent;
        circlesColor = Colors.blueAccent;
    }
  }

  Future<void> _loadTask() async {
    final db = UserDatabase();
    final data = await db.getTaskById(widget.taskId);
    setState(() {
      task = data;
    });
  }

  void _checkAnswer(String selected) async {
    if (task == null) return;

    final correct = task!['correct_answer'].toString().trim();
    final screenHeight = MediaQuery.of(context).size.height;

    setState(() => _selectedOption = selected);

    if (selected == correct) {
      _result = "Correct!";

      final db = UserDatabase();
      final progress = await db.getUserProgress(widget.userId);

      final completed = progress.any(
        (entry) => entry['task_id'] == widget.taskId && entry['completed'] == 1,
      );

      if (!completed) {
        await db.markTaskCompleted(widget.userId, widget.taskId);
        await db.addStarsToUser(widget.userId, 100);
      }

      showModalBottomSheet(
        context: context,
        constraints: const BoxConstraints(maxWidth: double.infinity),
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) {
          return Container(
            height: screenHeight * 0.55,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset('assets/Success.json', height: 180),
                const SizedBox(height: 20),
                const Text(
                  "Great job!",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontFamily: 'Ubuntu',
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "You answered correctly and earned 100 stars 🌟",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 40, color: Colors.black87),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: backgroundColor,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 32,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(fontSize: 30, color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      setState(() {
        _result = "Incorrect. Try again!";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    if (task == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final List<dynamic> options = jsonDecode(task!['options']);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [backgroundColor, Colors.white],
            stops: [0.0, 0.99],
          ),
        ),
        child: Stack(
          children: [
            // Floating shapes as background
            FloatingAnimation(
              maxShapes: 40,
              speedMultiplier: 0.6,
              sizeMultiplier: 0.8,
              selectedShape: 'circle',
              shapeColors: {'circle': circlesColor, 'heart': circlesColor},
              direction: FloatingDirection.down,
              spawnRate: 8.0,
              enableRotation: true,
              enablePulse: true,
              pulseSpeed: 1.2,
              pulseAmplitude: 0.4,
            ),

            _buildMainContent(
              context,
              MediaQuery.of(context).size.height,
              options,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    double screenHeight,
    List<dynamic> options,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          SizedBox(height: screenHeight * 0.08),

          Text(
            '📝 Task ${task!['id'].toString().substring(1)}',
            style: TextStyle(
              fontSize: 80,
              fontWeight: FontWeight.bold,
              fontFamily: 'Ubuntu',
              color: taskTextColor,
              shadows: [
                Shadow(
                  offset: Offset(2, 2),
                  blurRadius: 4,
                  color: Colors.black26,
                ),
              ],
            ),
          ),

          SizedBox(height: screenHeight * 0.06),

          Expanded(
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.6,
                child: Card(
                  elevation: 10,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          containerColor.withOpacity(0.9),
                          containerColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 16),

                          Text(
                            task!['question'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Ubuntu',
                              color: Color.fromRGBO(52, 51, 46, 0.867),
                            ),
                          ),

                          const SizedBox(height: 32),

                          for (final o in options)
                            _buildOptionButton(o.toString()),

                          if (_result != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              _result!,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w600,
                                color: _result!.contains("Correct")
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                          ElevatedButton.icon(
                            onPressed: _openFullScreenCanvas,
                            icon: const Icon(Icons.brush, size: 32),
                            label: const Text(
                              "Open Canvas",
                              style: TextStyle(fontSize: 32),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: backgroundColor,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 24,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(String option) {
    final bool isSelected = option == _selectedOption;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: ElevatedButton(
        onPressed: () => _checkAnswer(option),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? backgroundColor : Colors.white,
          elevation: 6,
          shadowColor: Colors.black26,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: backgroundColor, width: 3),
          ),
        ),
        child: Text(
          option,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            fontFamily: 'Ubuntu',
            color: isSelected ? Colors.white : Colors.blueAccent,
          ),
        ),
      ),
    );
  }

  void _openFullScreenCanvas() {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => StatefulBuilder(
          builder: (context, setState) => Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text("Drawing Canvas"),
              backgroundColor: backgroundColor,
              actions: [
                IconButton(
                  icon: const Icon(Icons.replay),
                  tooltip: "Clear Drawing",
                  onPressed: () => setState(() => _fullScreenPoints.clear()),
                ),
              ],
            ),
            body: GestureDetector(
              onPanStart: (details) {
                final box = context.findRenderObject() as RenderBox;
                final local = box.globalToLocal(details.globalPosition);
                setState(() => _fullScreenPoints.add(local));
              },
              onPanUpdate: (details) {
                final box = context.findRenderObject() as RenderBox;
                final local = box.globalToLocal(details.globalPosition);
                setState(() => _fullScreenPoints.add(local));
              },
              onPanEnd: (_) => setState(() => _fullScreenPoints.add(null)),
              child: CustomPaint(
                painter: DrawingPainter(points: _fullScreenPoints),
                size: Size.infinite,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<Offset?> points;
  final double gridSize; // size of the squares
  final Color gridColor;

  DrawingPainter({
    required this.points,
    this.gridSize = 40,
    this.gridColor = const Color(0xFFE0E0E0),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(255, 3, 9, 82)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}

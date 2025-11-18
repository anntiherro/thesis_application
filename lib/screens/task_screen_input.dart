import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../user_database.dart';
import 'package:floating_animation/floating_animation.dart';

class TaskScreenInput extends StatefulWidget {
  final int taskId;
  final int topicId;

  const TaskScreenInput({
    super.key,
    required this.taskId,
    required this.topicId,
  });

  @override
  State<TaskScreenInput> createState() => _TaskScreenInputState();
}

class _TaskScreenInputState extends State<TaskScreenInput>
    with TickerProviderStateMixin {
  Map<String, dynamic>? task;
  final TextEditingController _controller = TextEditingController();
  String? _result;
  final int userId = 1;
  late Color backgroundColor;
  late Color containerColor;
  late Color taskTextColor;
  late Color circlesColor;

  @override
  void initState() {
    super.initState();
    _loadTask();
    _setThemeForTopic();
  }

  void _setThemeForTopic() {
    switch (widget.topicId) {
      case 1:
        backgroundColor = Colors.blueAccent;
        containerColor = const Color.fromARGB(255, 249, 241, 220);
        taskTextColor = Color.fromARGB(255, 253, 247, 181);
        circlesColor = Color.fromARGB(255, 253, 247, 181);
        break;
      case 2:
        backgroundColor = Colors.blueAccent;
        containerColor = const Color.fromARGB(255, 249, 241, 220);
        taskTextColor = Color.fromARGB(255, 201, 231, 252);
        circlesColor = Color.fromARGB(255, 201, 231, 252);
        break;
      case 3:
        backgroundColor = const Color.fromARGB(255, 95, 161, 159);
        containerColor = const Color.fromARGB(255, 248, 120, 120);
        taskTextColor = Colors.redAccent;
        break;
      case 4:
        backgroundColor = Colors.blueAccent;
        containerColor = const Color.fromARGB(255, 249, 241, 220);
        taskTextColor = Color.fromARGB(255, 248, 225, 240);
        circlesColor = Color.fromARGB(255, 248, 225, 240);
        break;
      default:
        backgroundColor = Colors.white;
        containerColor = Colors.grey[200]!;
        taskTextColor = Colors.blueAccent;
    }
  }

  Future<void> _loadTask() async {
    final db = UserDatabase();
    final data = await db.getTaskById(widget.taskId);
    setState(() {
      task = data;
    });
  }

  void _checkAnswer() async {
    if (task == null) return;
    final userAnswer = _controller.text.trim();
    final correctAnswer = task!['correct_answer'].toString().trim();
    final screenHeight = MediaQuery.of(context).size.height;

    if (userAnswer.toLowerCase() == correctAnswer.toLowerCase()) {
      _result = "✅ Correct!";

      final db = UserDatabase();
      final progress = await db.getUserProgress(userId);
      final taskCompleted = progress.any(
        (entry) => entry['task_id'] == widget.taskId && entry['completed'] == 1,
      );

      if (!taskCompleted) {
        await db.markTaskCompleted(userId, widget.taskId);
        await db.addStarsToUser(userId, 100);
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
      _result = "❌ Incorrect. Try again.";
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    if (task == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              backgroundColor,
              const Color.fromARGB(255, 95, 161, 159).withOpacity(0.8),
            ],
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

            // Then your main content on top
            _buildMainContent(context, MediaQuery.of(context).size.height),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, double screenHeight) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: screenHeight * 0.08),

          // Header
          Text(
            '🧮 Task ${task!['id'].toString().substring(1)}',
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

          // Question Card
          Center(
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
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [containerColor.withOpacity(0.9), containerColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        task!['question'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Ubuntu',
                          color: Color.fromRGBO(52, 51, 46, 0.867),
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildAnswerField(context),
                      const SizedBox(height: 28),
                      _buildCheckButton(),
                      if (_result != null) ...[
                        const SizedBox(height: 20),
                        Text(
                          _result!,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: _result!.contains("✅")
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerField(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.6,
      child: TextField(
        controller: _controller,
        style: const TextStyle(fontSize: 40, color: Colors.black87),
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: "Type your answer...",
          hintStyle: const TextStyle(fontSize: 32, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.amber, width: 3),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 3),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckButton() {
    return ElevatedButton.icon(
      onPressed: _checkAnswer,
      icon: const Icon(
        Icons.check_circle_outline,
        color: Colors.white,
        size: 32,
      ),
      label: const Text(
        "Check",
        style: TextStyle(fontSize: 40, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        shadowColor: backgroundColor.withOpacity(0.4),
      ),
    );
  }
}

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

class _TaskScreenInputState extends State<TaskScreenInput> {
  Map<String, dynamic>? task;
  final TextEditingController _controller = TextEditingController();
  String? _result;
  final int userId = 1;

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
              const Color.fromARGB(255, 255, 255, 239).withOpacity(0.8),
            ],
          ),
        ),
        child: Stack(
          children: [
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
            _buildMainContent(screenHeight),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(double screenHeight) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          SizedBox(height: screenHeight * 0.08),
          Text(
            '📖 Task ${task!['id'].toString().substring(1)}',
            style: TextStyle(
              fontSize: 80,
              fontWeight: FontWeight.bold,
              fontFamily: 'Ubuntu',
              color: taskTextColor,
              shadows: const [
                Shadow(
                  offset: Offset(2, 2),
                  blurRadius: 4,
                  color: Colors.black26,
                ),
              ],
            ),
          ),
          SizedBox(height: screenHeight * 0.06),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              height: screenHeight * 0.6,
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
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        task!['question'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Ubuntu',
                          color: Color(0xFF34332E),
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildAnswerField(),
                      const SizedBox(height: 20),
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
                      const SizedBox(height: 10),
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

  Widget _buildAnswerField() => Container(
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

  Widget _buildCheckButton() => ElevatedButton.icon(
    onPressed: _checkAnswer,
    icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 32),
    label: const Text(
      "Check",
      style: TextStyle(fontSize: 40, color: Colors.white),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color.fromRGBO(32, 189, 172, 1),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      shadowColor: backgroundColor.withOpacity(0.4),
    ),
  );

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
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
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

import 'package:flutter/material.dart';
import '../user_database.dart';
import 'dart:convert';
import 'package:floating_animation/floating_animation.dart';
import 'package:lottie/lottie.dart';

class TaskScreenMultiStep extends StatefulWidget {
  final int taskId;
  final int userId;

  const TaskScreenMultiStep({
    super.key,
    required this.taskId,
    required this.userId,
  });

  @override
  State<TaskScreenMultiStep> createState() => _TaskScreenMultiStepState();
}

class _TaskScreenMultiStepState extends State<TaskScreenMultiStep> {
  String question = "";
  List<Map<String, dynamic>> steps = [];

  List<TextEditingController> left = [];
  List<TextEditingController> right = [];
  List<TextEditingController> answer = [];

  bool loading = true;
  String errorMessage = "";
  List<Offset?> _fullScreenPoints = [];

  @override
  void initState() {
    super.initState();
    loadTask();
  }

  Future<void> loadTask() async {
    final db = UserDatabase();
    final task = await db.getTaskById(widget.taskId);

    final parsedSteps = List<Map<String, dynamic>>.from(
      jsonDecode(task['correct_answer']),
    );

    setState(() {
      question = task['question'];
      steps = parsedSteps;

      for (int i = 0; i < steps.length; i++) {
        left.add(TextEditingController());
        right.add(TextEditingController());
        answer.add(TextEditingController());
      }

      loading = false;
    });
  }

  String _symbolForType(String type) {
    if (type == "sum") return "+";
    if (type == "subtract") return "-";
    if (type == "multiply") return "×";
    if (type == "divide") return "÷";
    return "?";
  }

  Future<void> _submit() async {
    setState(() => errorMessage = "");

    for (int i = 0; i < steps.length; i++) {
      final type = steps[i]['step_type'];
      final expected = steps[i]['expected_result'];

      final int? l = int.tryParse(left[i].text);
      final int? r = int.tryParse(right[i].text);
      final int? res = int.tryParse(answer[i].text);

      if (l == null || r == null || res == null) {
        setState(() => errorMessage = "Fill all fields");
        return;
      }

      int calc;
      switch (type) {
        case "sum":
          calc = l + r;
          break;
        case "subtract":
          calc = l - r;
          break;
        case "multiply":
          calc = l * r;
          break;
        case "divide":
          if (r == 0) {
            setState(() => errorMessage = "Division by zero");
            return;
          }
          calc = l ~/ r;
          break;
        default:
          setState(() => errorMessage = "Unknown operation type");
          return;
      }

      if (calc != expected || res != expected) {
        setState(() => errorMessage = "Wrong answer in step ${i + 1}");
        return;
      }
    }

    final db = UserDatabase();
    final progress = await db.getUserProgress(widget.userId);
    final taskCompleted = progress.any(
      (entry) => entry['task_id'] == widget.taskId && entry['completed'] == 1,
    );

    if (!taskCompleted) {
      await db.markTaskCompleted(widget.userId, widget.taskId);
      await db.addStarsToUser(widget.userId, 100);
    }

    _showSuccessSheet();
  }

  void _showSuccessSheet() {
    final screenHeight = MediaQuery.of(context).size.height;
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          height: screenHeight * 0.55,
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Lottie animation
              Lottie.asset('assets/Success.json', height: 180, repeat: false),
              const SizedBox(height: 20),
              const Text(
                "Great job!",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Ubuntu",
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                "You answered correctly\nand earned 100 stars 🌟",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  height: 1.3,
                  color: Colors.black87,
                  fontFamily: "Ubuntu",
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(255, 219, 219, 1),
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 32,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    "Continue",
                    style: TextStyle(
                      fontFamily: 'Ubuntu',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ).then((value) {
      Navigator.pop(context, true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final backgroundColor = const Color.fromRGBO(255, 219, 219, 1);
    final circlesColor = const Color.fromARGB(
      255,
      255,
      255,
      255,
    ).withOpacity(0.25);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [backgroundColor, Colors.white],
            stops: const [0.0, 0.99],
          ),
        ),
        child: Stack(
          children: [
            FloatingAnimation(
              maxShapes: 30,
              speedMultiplier: 0.3,
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

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📊 Task ${widget.taskId.toString().substring(1)}',
                      style: const TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Ubuntu',
                        color: Color.fromRGBO(248, 186, 186, 1),
                        shadows: [
                          Shadow(
                            offset: Offset(2, 2),
                            blurRadius: 4,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromRGBO(248, 186, 186, 1),
                            Color.fromRGBO(248, 186, 186, 1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Text(
                        question,
                        style: const TextStyle(
                          fontSize: 40,
                          height: 1.4,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Ubuntu',
                          color: Color.fromRGBO(52, 51, 46, 0.867),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    if (errorMessage.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          errorMessage,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 18,
                            fontFamily: 'Ubuntu',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                    const SizedBox(height: 10),
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
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount: steps.length,
                        itemBuilder: (context, i) {
                          final symbol = _symbolForType(steps[i]['step_type']);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 18),
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 14,
                            ),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(248, 186, 186, 1),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _numField(left[i]),
                                const SizedBox(width: 10),

                                Text(
                                  symbol,
                                  style: const TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.redAccent,
                                  ),
                                ),

                                const SizedBox(width: 10),
                                _numField(right[i]),

                                const SizedBox(width: 20),
                                const Text(
                                  "=",
                                  style: TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),

                                const SizedBox(width: 20),
                                _numField(answer[i]),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 65,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(
                            32,
                            189,
                            172,
                            1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 6,
                          shadowColor: const Color.fromARGB(
                            255,
                            248,
                            120,
                            120,
                          ).withOpacity(0.4),
                        ),
                        onPressed: _submit,
                        child: const Text(
                          "CHECK",
                          style: TextStyle(
                            fontFamily: 'Ubuntu',
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _numField(TextEditingController c) {
    return SizedBox(
      width: 75,
      child: TextField(
        controller: c,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'Ubuntu',
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
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
              backgroundColor: const Color.fromRGBO(255, 219, 219, 1),
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

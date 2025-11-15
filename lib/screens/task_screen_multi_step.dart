import 'package:flutter/material.dart';
import '../user_database.dart';
import 'dart:convert';

class TaskScreenMultiStep extends StatefulWidget {
  final int taskId;

  const TaskScreenMultiStep({super.key, required this.taskId});

  @override
  State<TaskScreenMultiStep> createState() => _TaskScreenMultiStepState();
}

class _TaskScreenMultiStepState extends State<TaskScreenMultiStep> {
  String question = "";
  List<Map<String, dynamic>> steps = [];
  final int userId = 1;

  List<TextEditingController> left = [];
  List<TextEditingController> right = [];
  List<TextEditingController> answer = [];

  bool loading = true;
  String errorMessage = "";

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
    if (type == "mul") return "×";
    if (type == "div") return "÷";
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
        case "mul":
          calc = l * r;
          break;
        case "div":
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
    final progress = await db.getUserProgress(userId);
    final taskCompleted = progress.any(
      (entry) => entry['task_id'] == widget.taskId && entry['completed'] == 1,
    );

    if (!taskCompleted) {
      await db.markTaskCompleted(userId, widget.taskId);
      await db.addStarsToUser(userId, 100);
    }

    _showSuccessSheet();
  }

  void _showSuccessSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 16),
              const Text(
                "Correct!",
                style: TextStyle(
                  fontFamily: "Ubuntu",
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    "CONTINUE",
                    style: TextStyle(
                      fontFamily: 'Ubuntu',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
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
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              question,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Ubuntu',
              ),
            ),

            const SizedBox(height: 20),

            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 18,
                  fontFamily: 'Ubuntu',
                  fontWeight: FontWeight.bold,
                ),
              ),

            const SizedBox(height: 8),

            Expanded(
              child: ListView.builder(
                itemCount: steps.length,
                itemBuilder: (context, i) {
                  final symbol = _symbolForType(steps[i]['step_type']);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 4),
                      ],
                    ),
                    child: Row(
                      children: [
                        _numField(left[i]),
                        const SizedBox(width: 8),

                        Text(
                          symbol,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(width: 8),
                        _numField(right[i]),

                        const SizedBox(width: 12),
                        const Text(
                          "=",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),

                        _numField(answer[i]),
                      ],
                    ),
                  );
                },
              ),
            ),

            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: _submit,
                child: const Text(
                  "CHECK",
                  style: TextStyle(
                    fontFamily: 'Ubuntu',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
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
      width: 70,
      child: TextField(
        controller: c,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

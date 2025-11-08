import 'dart:convert';
import 'package:flutter/material.dart';
import '../user_database.dart';

class TaskScreenMc extends StatefulWidget {
  final int taskId;

  const TaskScreenMc({super.key, required this.taskId});

  @override
  State<TaskScreenMc> createState() => _TaskScreenMcState();
}

class _TaskScreenMcState extends State<TaskScreenMc> {
  Map<String, dynamic>? task;
  String? _selectedOption;
  String? _result;
  final int userId = 1;
  @override
  void initState() {
    super.initState();
    _loadTask();
  }

  Future<void> _loadTask() async {
    final db = UserDatabase();
    final data = await db.getTaskById(widget.taskId);
    setState(() {
      task = data;
    });
  }

  void _checkAnswer() async {
    if (task == null || _selectedOption == null) return;

    final correctAnswer = task!['correct_answer'].toString().trim();
    final screenHeight = MediaQuery.of(context).size.height;

    if (_selectedOption!.trim().toLowerCase() == correctAnswer.toLowerCase()) {
      _result = "✅ Correct!";

      final db = UserDatabase();
      // Getting task progress for this user
      final progress = await db.getUserProgress(userId);
      final taskCompleted = progress.any(
        (entry) => entry['task_id'] == widget.taskId && entry['completed'] == 1,
      );

      if (!taskCompleted) {
        await db.markTaskCompleted(userId, widget.taskId);
        await db.addStarsToUser(userId, 100);
      }

      //  showing modal bottom sheet
      showModalBottomSheet(
        context: context,
        constraints: const BoxConstraints(maxWidth: double.infinity),
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) {
          return Container(
            height: screenHeight * 0.5,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.check_circle, color: Colors.green, size: 128),
                    SizedBox(width: 16),
                    Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text(
                        "Correct!",
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontFamily: 'Ubuntu',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  "Well done! You answered correctly.",
                  style: TextStyle(fontSize: 24, color: Colors.black87),
                ),
                const Spacer(),
                SizedBox(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); 
                      Navigator.pop(context, true); 
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Continue",
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      setState(() {
        _result = "❌ Incorrect. Try again.";
      });
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    if (task == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Decoding options from JSON
    final List<dynamic> options = jsonDecode(task!['options']);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 230, 240, 255),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: screenHeight * 0.08),

            Text(
              'Task ${task!['id'].toString().substring(1)}',
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                fontFamily: 'Ubuntu',
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: screenHeight * 0.05),

            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.6,
                child: Card(
                  elevation: 8,
                  shadowColor: Colors.black38,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: const Color.fromARGB(255, 255, 245, 200),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: screenHeight * 0.04),
                        Text(
                          task!['question'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Ubuntu',
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.04),

                        // List of options
                        Expanded(
                          child: ListView.builder(
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final option = options[index].toString();
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedOption = option;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: _selectedOption == option
                                          ? Colors.amber[400]
                                          : Colors.white,
                                      border: Border.all(
                                        color: Colors.amber,
                                        width: 3,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                      horizontal: 16,
                                    ),
                                    child: Center(
                                      child: Text(
                                        option,
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        ElevatedButton(
                          onPressed: _checkAnswer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 28,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Check",
                            style: TextStyle(fontSize: 28, color: Colors.white),
                          ),
                        ),

                        if (_result != null) ...[
                          const SizedBox(height: 20),
                          Text(
                            _result!,
                            style: TextStyle(
                              fontSize: 20,
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
      ),
    );
  }
}

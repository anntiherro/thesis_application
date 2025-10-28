import 'package:flutter/material.dart';
import '../user_database.dart';

class TaskScreenInput extends StatefulWidget {
  final int taskId;

  const TaskScreenInput({super.key, required this.taskId});

  @override
  State<TaskScreenInput> createState() => _TaskScreenInputState();
}

class _TaskScreenInputState extends State<TaskScreenInput> {
  Map<String, dynamic>? task;
  final TextEditingController _controller = TextEditingController();
  String? _result;

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
    if (task == null) return;
    final userAnswer = _controller.text.trim();
    final correctAnswer = task!['correct_answer'].toString().trim();
    final screenHeight = MediaQuery.of(context).size.height;

    if (userAnswer.toLowerCase() == correctAnswer.toLowerCase()) {
      _result = "✅ Correct!";

      final db = UserDatabase();
      await db.markTaskCompleted(1, widget.taskId);
      
      
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
                  children: [
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 128),
                    const SizedBox(width: 16),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: const Text(
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
                      Navigator.pop(context); // закрыть bottom sheet
                      Navigator.pop(context, true); // вернуться и обновить
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
      backgroundColor: const Color.fromARGB(255, 230, 240, 255), 
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: screenHeight * 0.08),

            // Header Task
            Text(
              'Task ${task!['id'].toString().substring(1)}',
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                fontFamily: 'Ubuntu',
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),

            // Card with question and answer input
            Center(
              child: SizedBox(
                width:
                    MediaQuery.of(context).size.width *
                    0.85, 
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
                      children: [
                        SizedBox(height: screenHeight * 0.04),
                        Text(
                          task!['question'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Ubuntu',
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.04),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          height: screenHeight * 0.1,
                          child: TextField(
                            controller: _controller,
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: "Answer",
                              hintStyle: const TextStyle(
                                fontSize: 42,
                                color: Colors.grey,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Colors.amber,
                                  width: 3,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Colors.blueGrey,
                                  width: 3,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),
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
                            style: TextStyle(fontSize: 32, color: Colors.white),
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


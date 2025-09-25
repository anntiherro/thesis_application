import 'package:flutter/material.dart';
import '../user_database.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TopicScreen extends StatefulWidget {
  final int topicId;
  final String topicTitle;

  const TopicScreen({
    super.key,
    required this.topicId,
    required this.topicTitle,
  });

  @override
  State<TopicScreen> createState() => _TopicScreenState();
}

class _TopicScreenState extends State<TopicScreen> {
  List<Map<String, dynamic>> tasks = [];

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    final db = UserDatabase();
    final data = await db.getTasksForTopic(
      widget.topicId,
    ); // берем только нужные задания
    setState(() {
      tasks = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 253, 138), // основной фон

      body: Stack(
        children: [
          // Фоновая SVG картинка
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SvgPicture.asset(
              'assets/characters.svg',
              width: MediaQuery.of(context).size.width,
              height:
                  screenHeight * 0.25, // чтобы занимала только верхнюю часть
              fit: BoxFit.cover,
            ),
          ),

          // Нижний слой с заданями
          Positioned(
            top: screenHeight * 0.25,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 245, 154, 70),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: tasks.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: SizedBox(
                            width: double.infinity,
                            height: screenHeight * 0.08,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  255,
                                  213,
                                  73,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () {
                                print('Tapped on task ${task['id']}');
                              },
                              child: Text(
                                'TASK ${index + 1}', // можно заменить на task['question']
                                style: TextStyle(
                                  fontFamily: 'Ubuntu',
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 80, 80, 80),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

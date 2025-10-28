import 'package:flutter/material.dart';
import '../user_database.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'task_screen_input.dart';
import 'task_screen_mc.dart';
import 'package:flutter/services.dart' show rootBundle; // NEW

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

  // NEW: поля для туториала
  bool _showTutorialOverlay = false; // NEW
  List<String> _tutorialImages = []; // NEW
  int _currentPage = 0; // NEW

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    final db = UserDatabase();

    // Получаем все задания для текущей темы
    final data = await db.getTasksForTopic(widget.topicId);

    // Получаем прогресс пользователя
    final userId = 1; // <-- заменить на текущего пользователя
    final progress = await db.getUserProgress(userId);

    // Создаём map taskId -> completed
    final Map<int, int> completedTasks = {};
    for (var entry in progress) {
      completedTasks[entry['task_id']] = entry['completed'];
    }

    // Копируем задания и добавляем поле completed, не трогаем ID
    List<Map<String, dynamic>> taskList = [];
    for (var t in data) {
      final taskCopy = Map<String, dynamic>.from(t);
      taskCopy['completed'] = completedTasks[taskCopy['id']] ?? 0;
      taskList.add(taskCopy);
    }

    // NEW: вставка туториалов с правильным tutorialOrder
    List<Map<String, dynamic>> finalTaskList = [];
    int tutorialOrder = 1; // первый туториал = 1
    int taskCounter = 0;

    for (int i = 0; i < taskList.length; i++) {
      if (i == 0) {
        // первый туториал перед всеми тасками
        finalTaskList.add({
          'type': 'tutorial',
          'topicId': widget.topicId,
          'tutorialOrder': tutorialOrder,
        });
        tutorialOrder++;
      }

      finalTaskList.add(taskList[i]); // сохраняем ID таска
      taskCounter++;

      // после каждых 4-х тасков вставляем новый туториал (только если не конец списка)
      if (taskCounter % 4 == 0 && i != taskList.length - 1) {
        finalTaskList.add({
          'type': 'tutorial',
          'topicId': widget.topicId,
          'tutorialOrder': tutorialOrder,
        });
        tutorialOrder++;
      }
    }

    setState(() {
      tasks = finalTaskList;
    });
  }

  void _openTask(Map<String, dynamic> task) async {
    final type = task['type'];

    if (type == 'input') {
      final completed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => TaskScreenInput(taskId: task['id']),
        ),
      );
      if (completed == true) {
        await loadTasks();
      }
    } else if (type == 'mp') {
      final completed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => TaskScreenMc(taskId: task['id']),
        ),
      );
      if (completed == true) {
        await loadTasks();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Экран для типа "$type" пока не реализован')),
      );
    }
  }

  // NEW: универсальная функция загрузки всех картинок для любого туториала
  Future<void> _loadTutorial(int topicId, int tutorialOrder) async {
    List<String> images = [];
    int i = 1;
    while (true) {
      String path =
          'assets/tutorials/tutorial_${topicId}_${tutorialOrder}_$i.svg';
      try {
        await rootBundle.load(path);
        images.add(path);
        i++;
      } catch (e) {
        break;
      }
    }

    if (images.isEmpty) return; // нет картинок

    setState(() {
      _tutorialImages = images;
      _currentPage = 0;
      _showTutorialOverlay = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    late Color backgroundColor;
    late Color containerColor;
    late String characterAsset;
    late String arrowAsset;

    switch (widget.topicId) {
      case 1:
        backgroundColor = const Color.fromARGB(255, 255, 243, 194);
        containerColor = const Color.fromARGB(255, 255, 235, 153);
        characterAsset = 'assets/character1.svg';
        arrowAsset = 'assets/yellowarrow.svg';
        break;
      case 2:
        backgroundColor = const Color.fromARGB(255, 194, 220, 255);
        containerColor = const Color.fromARGB(255, 138, 195, 239);
        characterAsset = 'assets/character2.svg';
        arrowAsset = 'assets/bluearrow.svg';
        break;
      case 3:
        backgroundColor = const Color.fromARGB(255, 255, 173, 173);
        containerColor = const Color.fromARGB(255, 248, 120, 120);
        characterAsset = 'assets/character3.svg';
        arrowAsset = 'assets/redarrow.svg';
        break;
      case 4:
        backgroundColor = const Color.fromARGB(255, 255, 194, 232);
        containerColor = const Color.fromARGB(255, 255, 153, 216);
        characterAsset = 'assets/character4.svg';
        arrowAsset = 'assets/pinkarrow.svg';
        break;
      default:
        backgroundColor = Colors.white;
        containerColor = Colors.grey[200]!;
        characterAsset = 'assets/character1.svg';
    }
    return Scaffold(
      backgroundColor: backgroundColor, // основной фон
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SvgPicture.asset(
              characterAsset,
              width: MediaQuery.of(context).size.width,
              height: screenHeight * 0.25,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: screenHeight * 0.25,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: containerColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(45)),
              ),
              padding: const EdgeInsets.all(16),
              child: tasks.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];

                        // NEW: кнопка туториала
                        if (task['type'] == 'tutorial') {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: SizedBox(
                              width: double.infinity,
                              height: screenHeight * 0.08,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                onPressed: () => _loadTutorial(
                                  task['topicId'],
                                  task['tutorialOrder'],
                                ),
                                child: const Text(
                                  'TUTORIAL',
                                  style: TextStyle(
                                    fontFamily: 'Ubuntu',
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }

                        // обычный таск
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: SizedBox(
                            width: double.infinity,
                            height: screenHeight * 0.08,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: task['completed'] == 1
                                    ? Colors.green
                                    : const Color.fromARGB(255, 255, 255, 255),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              onPressed: () {
                                _openTask(task);
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    child: SvgPicture.asset(
                                      task['icon'] ?? 'assets/plusminus.svg',
                                      width: screenHeight * 0.05,
                                      height: screenHeight * 0.05,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                              child: Text(
                                'TASK ${task['id'].toString().substring(1)}',
                                style: const TextStyle(
                                  fontFamily: 'Ubuntu',
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 80, 80, 80),
                                ),
                              ),
                            ),
                            SvgPicture.asset(
                                    arrowAsset,
                                    width: screenHeight * 0.04,
                                    height: screenHeight * 0.04,
                                  ),
                                ],
                              ),
                          ),
                        ),
                        );
                      },
                    ),
            ),
          ),

          // NEW: Overlay туториала для SVG
          if (_showTutorialOverlay)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.6),
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: MediaQuery.of(context).size.height * 0.8,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      children: [
                        PageView.builder(
                          itemCount: _tutorialImages.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return SvgPicture.asset(
                              _tutorialImages[index],
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.contain,
                            );
                          },
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: const Icon(
                              Icons.close,
                              size: 32,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              setState(() {
                                _showTutorialOverlay = false;
                              });
                            },
                          ),
                        ),
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
}

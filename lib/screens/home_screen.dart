import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/topic_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../user_database.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({super.key, required this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> topics = [];
  int userStars = 0;
  String _avatarName = "bronze";
  int? userId;
  @override
  void initState() {
    super.initState();
    loadTopics();
    loadStars(); // load stars on init
  }

  Future<void> loadTopics() async {
    final db = UserDatabase();
    final data = await db.getTopics();
    setState(() {
      topics = data;
    });
  }

  Future<void> loadStars() async {
    final db = UserDatabase();
    final user = await db.getUser(widget.username); // ищем по username
    if (user != null && user['stars'] != null) {
      setState(() {
        userStars = user['stars'];
        _avatarName = user['avatar'] ?? 'bronze';
        userId = user['id']; // сохраняем ID
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(249, 241, 220, 1),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(50),
                        splashColor: Colors.blue.withOpacity(0.2),
                        onTap: () async {
                          final user = await UserDatabase().getUser(
                            widget.username,
                          );
                          if (user != null) {
                            // Navigate to ProfileScreen and wait for avatar update
                            final updatedAvatar = await Navigator.push<String>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfileScreen(
                                  username: user['username'],
                                  createdAt: user['created_at'],
                                ),
                              ),
                            );

                            // Update avatar if returned
                            if (updatedAvatar != null &&
                                updatedAvatar.isNotEmpty) {
                              setState(() {
                                // Update local avatar
                                _avatarName = updatedAvatar;
                              });
                            }
                          }
                        },
                        child: CircleAvatar(
                          radius: 45,
                          backgroundColor: const Color(0xFF5C88FF),
                          child: _avatarName.isNotEmpty
                              ? Image.asset(
                                  'assets/avatar_$_avatarName.png',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                )
                              : Text(
                                  widget.username.isNotEmpty
                                      ? widget.username[0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    fontSize: 38,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutBack,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blueAccent,
                              const Color.fromARGB(255, 100, 153, 244),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromARGB(
                                255,
                                245,
                                234,
                                78,
                              ).withOpacity(0.7),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 32,
                              color: Color.fromARGB(255, 245, 234, 78),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$userStars',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                                color: Color.fromARGB(255, 245, 234, 78),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  Text(
                    'Welcome, ${widget.username}!',
                    style: const TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    height: 0.485 * size.width * 1.5,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: topics.length,
                      itemBuilder: (context, index) {
                        final topic = topics[index];
                        final topicId = topic['id'];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: SizedBox(
                            width: size.width * 0.3 * 1.5,
                            child: Card(
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                              clipBehavior: Clip.hardEdge,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TopicScreen(
                                        topicId: topicId,
                                        topicTitle: topic['title'],
                                        userId:
                                            userId!, // передаём ID, обязательное условие чтобы не было null
                                      ),
                                    ),
                                  ).then((_) => loadStars());
                                },
                                child: SvgPicture.asset(
                                  'assets/topic$topicId.svg',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 40),

                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 230, 196, 124),
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 32),
                    label: const Text(
                      "Logout",
                      style: TextStyle(fontSize: 32, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

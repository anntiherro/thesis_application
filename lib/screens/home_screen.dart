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
    final user = await db.getUser(widget.username);
    if (user != null && user['stars'] != null) {
      setState(() {
        userStars = user['stars'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(249, 241, 220, 1),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),

                // Clickable profile picture (avatar)
                InkWell(
                  onTap: () async {
                    final user = await UserDatabase().getUser(widget.username);
                    if (user != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(
                            username: user['username'],
                            createdAt: user['created_at'],
                          ),
                        ),
                      );
                    }
                  },
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blueAccent,
                    child: Text(
                      widget.username.isNotEmpty
                          ? widget.username[0].toUpperCase()
                          : 'U',
                      style: TextStyle(fontSize: 40, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                Text(
                  'Welcome, ${widget.username}!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),

                // horizontal topics slider
                SizedBox(
                  height: 0.485 * MediaQuery.of(context).size.width * 1.5,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: topics.length,
                    itemBuilder: (context, index) {
                      final topic = topics[index];
                      final topicId = topic['id'];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3 * 1.5,
                          child: Card(
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
                                      topicId: topic['id'],
                                      topicTitle: topic['title'],
                                    ),
                                  ),
                                ).then((_) {
                                  // Reload stars when returning from topic screen
                                  loadStars();
                                });
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
                SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context); // logout
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text('Logout', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),

          // Stars display at top right
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.star_rounded,
                    color: Colors.amber.shade700,
                    size: 32,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$userStars',
                    style: const TextStyle(
                      fontFamily: 'Ubuntu',
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
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

import 'package:flutter/material.dart';
import '../user_database.dart';
import 'achievements_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String username;
  final String createdAt;

  const ProfileScreen({
    super.key,
    required this.username,
    required this.createdAt,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int solvedTasks = 0;
  int totalTasks = 0;
  int completedTopics = 0;
  double overallPercent = 0;
  bool loading = true;
  String avatar = "bronze";

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final db = UserDatabase();

    final user = await db.getUser(widget.username);
    if (user == null) return;
    final int userId = user["id"];
    avatar = user["avatar"] ?? "bronze";

    final allTasks = await db.database.then((dbObj) => dbObj.query("tasks"));
    totalTasks = allTasks.length;

    final progress = await db.getUserProgress(userId);
    solvedTasks = progress.where((e) => e["completed"] == 1).length;

    final topics = await db.getTopics();
    completedTopics = 0;

    for (var topic in topics) {
      final topicId = topic["id"];

      final tasksForTopic = allTasks
          .where((t) => t["topic_id"] == topicId)
          .toList();
      if (tasksForTopic.isEmpty) continue;

      final solvedInTopic = progress
          .where(
            (p) => tasksForTopic.any(
              (t) => t["id"] == p["task_id"] && p["completed"] == 1,
            ),
          )
          .length;

      if (solvedInTopic == tasksForTopic.length) {
        completedTopics++;
      }
    }

    overallPercent = totalTasks == 0 ? 0 : (solvedTasks / totalTasks) * 100;

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(249, 241, 220, 1),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : SizedBox(
              height: screenHeight * 0.66,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(75),
                        onTap: () async {
                          final selectedAvatar = await Navigator.push<String>(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AchievementsScreen(username: widget.username),
                            ),
                          );

                          if (selectedAvatar != null &&
                              selectedAvatar.isNotEmpty) {
                            setState(() {
                              avatar = selectedAvatar;
                            });
                          }
                        },
                        child: CircleAvatar(
                          radius: 75,
                          backgroundColor: Colors.blueAccent,
                          child: ClipOval(
                            child: Image.asset(
                              "assets/avatar_$avatar.png",
                              width: 140,
                              height: 140,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: IconButton(
                          icon: Icon(
                            Icons.emoji_events_rounded,
                            color: Colors.amber,
                            size: 38,
                          ),
                          onPressed: () async {
                            final selectedAvatar = await Navigator.push<String>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AchievementsScreen(
                                  username: widget.username,
                                ),
                              ),
                            );

                            if (selectedAvatar != null &&
                                selectedAvatar.isNotEmpty) {
                              setState(() {
                                avatar = selectedAvatar;
                              });

                              Navigator.pop(context, selectedAvatar);
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24),
                  Text(
                    'User: ${widget.username}',
                    style: TextStyle(fontSize: 42, fontFamily: 'Ubuntu'),
                  ),
                  SizedBox(height: 12),

                  Text(
                    'Created at: ${widget.createdAt.substring(0, 7)}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),

                  SizedBox(height: 40),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatCard(
                          title: "Solved Tasks",
                          value: "$solvedTasks / $totalTasks",
                        ),
                        _buildStatCard(
                          title: "Completed Topics",
                          value: "$completedTopics",
                        ),
                        _buildStatCard(
                          title: "Overall %",
                          value: "${overallPercent.toStringAsFixed(0)}%",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard({required String title, required String value}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(1, 2)),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 28,
              color: const Color.fromARGB(255, 255, 255, 255),
              fontFamily: 'Ubuntu',
            ),
          ),
          SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'Ubuntu',
              color: const Color.fromARGB(255, 255, 255, 255),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../user_database.dart';

class AchievementsScreen extends StatefulWidget {
  final String username;

  const AchievementsScreen({super.key, required this.username});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  int userStars = 0;
  String selectedAvatar = "bronze";

  late AnimationController _shakeController;

  final avatars = [
    {"name": "bronze", "stars": 0},
    {"name": "silver", "stars": 200},
    {"name": "gold", "stars": 500},
    {"name": "diamond", "stars": 1200},
    {"name": "galaxy", "stars": 2500},
  ];
  final Map<String, String> avatarPaths = {
    "bronze": "assets/avatar_bronze.png",
    "silver": "assets/avatar_silver.png",
    "gold": "assets/avatar_gold.png",
    "diamond": "assets/avatar_diamond.png",
    "galaxy": "assets/avatar_galaxy.png",
  };

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _loadData();
  }

  Future<void> _loadData() async {
    final db = UserDatabase();
    final user = await db.getUser(widget.username);

    setState(() {
      userStars = user?["stars"] ?? 0;
      selectedAvatar = user?["avatar"] ?? "bronze";
    });
  }

  Future<void> _selectAvatar(String avatarName) async {
    final db = UserDatabase();
    await db.updateUserAvatar(widget.username, avatarName);
    setState(() => selectedAvatar = avatarName);
    Navigator.pop(context, avatarName);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Achievements"),
        backgroundColor: Colors.greenAccent,
      ),
      backgroundColor: Colors.grey[200],
      body: GridView.builder(
        padding: EdgeInsets.all(20),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: avatars.length,
        itemBuilder: (context, index) {
          final item = avatars[index];
          final String name = item["name"] as String;
          final int requiredStars = item["stars"] as int;
          final bool unlocked = userStars >= requiredStars;

          return GestureDetector(
            onTap: () {
              if (!unlocked) {
                _shakeController.forward(from: 0);
                return;
              }
              // Update avatar in DB
              _selectAvatar(name);
              // Return selected avatar immediately
              Navigator.pop(context, name);
            },
            child: AnimatedBuilder(
              animation: _shakeController,
              builder: (context, child) {
                final shake = 4 * (1 - _shakeController.value);
                return Transform.translate(
                  offset: !unlocked ? Offset(shake, 0) : Offset.zero,
                  child: child,
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: unlocked ? Colors.white : Colors.grey[400],
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(2, 2),
                    ),
                  ],
                  border: selectedAvatar == name
                      ? Border.all(color: Colors.greenAccent, width: 4)
                      : null,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(avatarPaths[name]!, fit: BoxFit.contain),

                    if (!unlocked)
                      Container(color: Colors.black.withOpacity(0.4)),

                    if (!unlocked)
                      const Icon(
                        Icons.lock_rounded,
                        size: 50,
                        color: Colors.white,
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

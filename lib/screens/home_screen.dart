import 'package:flutter/material.dart';
import '../user_database.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  final String username;

  const HomeScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // фон можно поменять
      appBar: AppBar(
        title: Text('Home'),
        centerTitle: true,
        automaticallyImplyLeading: false, // убираем стрелку назад
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.1), // чуть сверху
            // Нажимаемый аватар
            InkWell(
              onTap: () async {
                final user = await UserDatabase().getUser(username);
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
                  username.isNotEmpty ? username[0].toUpperCase() : 'U',
                  style: TextStyle(fontSize: 40, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Welcome, $username!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('Start Lesson', style: TextStyle(fontSize: 18)),
            ),
            SizedBox(height: 16),
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
    );
  }
}

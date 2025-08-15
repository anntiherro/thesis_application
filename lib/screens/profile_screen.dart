import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final String username;
  final String createdAt;

  const ProfileScreen({super.key, required this.username, required this.createdAt});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
      ),
      body: SizedBox(
        height: screenHeight * 0.66, // колонка занимает 66% экрана
        width: double.infinity,       // растягиваем по всей ширине
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // по вертикали центр
          crossAxisAlignment: CrossAxisAlignment.center, // по горизонтали центр
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blueAccent,
              child: Text(
                username.isNotEmpty ? username[0].toUpperCase() : 'U',
                style: TextStyle(fontSize: 40, color: Colors.white),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Username: $username',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 16),
            Text(
              'Created at: ${createdAt.substring(0, 7)}',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}

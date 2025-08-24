import 'package:flutter/material.dart';
void main() {
  runApp(const MathKidsApp());
}

class MathKidsApp extends StatelessWidget {
  const MathKidsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  // Цвета
  final Color babyPink = const Color(0xFFFADAE2);
  final Color jungleTeal = const Color(0xFF1B766D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: babyPink,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Заголовок
            Text(
              "Math Kids",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: jungleTeal,
              ),
            ),

            const SizedBox(height: 40),

            // Поля ввода
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Username",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Password",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Ссылка "Forgot password?"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Forgot password?",
                  style: TextStyle(color: jungleTeal),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Кнопка логина
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: jungleTeal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 16),
              ),
              onPressed: () {},
              child: const Text(
                "LOG IN",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),

            const SizedBox(height: 20),

            // Регистрация
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don’t have an account? "),
                Text(
                  "Sign up",
                  style: TextStyle(
                    color: jungleTeal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Нижняя часть с иллюстрацией
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
color: jungleTeal,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(50),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Пример: ребёнок и символы математики
                  Icon(Icons.calculate, size: 64, color: babyPink),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(" +  ", style: TextStyle(fontSize: 30, color: babyPink)),
                      Text(" ×  ", style: TextStyle(fontSize: 30, color: babyPink)),
                      Text(" ÷  ", style: TextStyle(fontSize: 30, color: babyPink)),
                      Image.asset("assets/girl.png", height: 180),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
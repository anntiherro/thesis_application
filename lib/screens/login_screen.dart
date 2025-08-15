import 'package:flutter/material.dart';
import 'home_screen.dart';

import '../user_database.dart';

final dbHelper = UserDatabase();

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void clearFields() {
    usernameController.clear();
    passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.66, // делаем контейнер высотой экрана
          child: Center( // центрируем по вертикали и горизонтали
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min, // минимальный размер, чтобы не растягивать
                children: [
                  const CircleAvatar(
                    radius: 100,
                    backgroundColor: Colors.blueAccent,
                    backgroundImage: AssetImage('assets/monkey.png'),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: usernameController,
                            decoration: const InputDecoration(
                              labelText: 'Username',
                              prefixIcon: Icon(Icons.person),
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: passwordController,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock),
                            ),
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () async {
                              if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Fill all fields')),
                                );
                                return;
                              }

                              final user = await dbHelper.getUser(usernameController.text);

                              if (user != null && user['password'] == passwordController.text) {
                                // Логин успешен
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomeScreen(username: user['username']),
                                  ),
                                );
                              } else {
                                // Ошибка логина
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Invalid username or password')),
                                );
                              }
                            },
                            child: Text('Login'),
                          ),

                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () async {
                              if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Fill all fields')),
                                );
                                return;
                              }

                              try {
                                await dbHelper.insertUser(
                                  usernameController.text,
                                  passwordController.text,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('User registered!')),
                                );
                                usernameController.clear();
                                passwordController.clear();
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Username already exists')),
                                );
                              }
                            },
                            child: Text('Register'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

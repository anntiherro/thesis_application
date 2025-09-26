import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'seed_data.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // path to db
  String path = join(await getDatabasesPath(), 'app.db');

  // deleting old database(when developing changes of 1st version of db)
  await deleteDatabase(path);
  print('Old database deleted at $path');

  // Filling DB
  await SeedData.seedDatabase();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Math Learning App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(),
    );
  }
}

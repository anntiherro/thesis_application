import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class UserDatabase {
  // Creating singleton to have 1 db
  static final UserDatabase _instance = UserDatabase._internal();
  factory UserDatabase() => _instance;
  UserDatabase._internal();

  static Database? _database;

  // Getter for a DB, opened when first called
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // DB initialisation: creating file app.db
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'app.db'); // path to db file
    return await openDatabase(
      path,
      version: 1, // пока версия 1
      onCreate: _onCreate,
    );
  }

  // First run db creating
  Future<void> _onCreate(Database db, int version) async {
    //Creating users table
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,  
        username TEXT UNIQUE,                 
        password TEXT,                        
        created_at TEXT,
        stars INTEGER DEFAULT 0                       
      )
    ''');

    // Creating topics table
    await db.execute('''
      CREATE TABLE topics(
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        title TEXT,                           
        description TEXT                      
      )
    ''');

    // Creating tasks table
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY,       -- 11 = topic 1, task 1
        topic_id INTEGER NOT NULL,
        question TEXT NOT NULL,
        options TEXT,                 -- list of answers JSON
        correct_answer TEXT NOT NULL, -- correct answer
        type TEXT NOT NULL,           -- type of task (multiple_choice, input)
        icon TEXT,
        FOREIGN KEY (topic_id) REFERENCES topics(id) ON DELETE CASCADE
      )
    ''');

    // Creating user_tasks table to track progress
    await db.execute('''
      CREATE TABLE user_tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        task_id INTEGER NOT NULL,
        completed INTEGER DEFAULT 0, -- 0 = not done, 1 = done
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE
      )
    ''');

  }

  // Adding new user to db
  Future<int> insertUser(String username, String password) async {
    final db = await database; // getting a db object
    return await db.insert(
      'users',
      {
        'username': username,
        'password': password,
        'created_at': DateTime.now().toIso8601String(), // current date
      },
      conflictAlgorithm: ConflictAlgorithm.abort, // error if username exists
    );
  }

  // Getting user by username
  Future<Map<String, dynamic>?> getUser(String username) async {
    final db = await database;
    final res = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (res.isNotEmpty) return res.first; //return first entry
    return null; // if no user found
  }

  // Getting all topics
  Future<List<Map<String, dynamic>>> getTopics() async {
    final db = await database;
    return await db.query('topics'); // returns list of maps
  }

  // Getting tasks for a topic
  Future<List<Map<String, dynamic>>> getTasksForTopic(int topicId) async {
    final db = await database;
    return await db.query('tasks', where: 'topic_id = ?', whereArgs: [topicId]);
  }

  // Marking task as completed for a user
  Future<void> markTaskCompleted(int userId, int taskId) async {
    final db = await database;
    // Check if entry exists
    final res = await db.query(
      'user_tasks',
      where: 'user_id = ? AND task_id = ?',
      whereArgs: [userId, taskId],
    );

    if (res.isEmpty) {
      // Insert new record
      await db.insert('user_tasks', {
        'user_id': userId,
        'task_id': taskId,
        'completed': 1,
      });
    } else {
      // Update existing record
      await db.update(
        'user_tasks',
        {'completed': 1},
        where: 'user_id = ? AND task_id = ?',
        whereArgs: [userId, taskId],
      );
    }
  }

  // Getting progress for a user (completed tasks)
  Future<List<Map<String, dynamic>>> getUserProgress(int userId) async {
    final db = await database;
    return await db.query(
      'user_tasks',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<Map<String, dynamic>> getTaskById(int id) async {
    final db = await database;
    final res = await db.query('tasks', where: 'id = ?', whereArgs: [id]);
    return res.first;
  }

  Future<void> addStarsToUser(int userId, int starsToAdd) async {
    final db = await database;
    await db.rawUpdate('''
    UPDATE users
    SET stars = stars + ?
    WHERE id = ?
    ''', [starsToAdd, userId],
    );
  }

}



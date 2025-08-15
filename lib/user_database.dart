import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class UserDatabase {
  // Создаём синглтон, чтобы в приложении была одна база
  static final UserDatabase _instance = UserDatabase._internal();
  factory UserDatabase() => _instance;
  UserDatabase._internal();

  static Database? _database;

  // Геттер для базы данных, открывает её при первом обращении
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Инициализация базы: создаём файл app.db и таблицу users
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'app.db'); // путь к файлу базы
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Создание таблицы при первом запуске
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,  -- уникальный ключ
        username TEXT UNIQUE,                 -- логин, не повторяется
        password TEXT,                        -- пароль
        created_at TEXT                       -- дата создания пользователя
      )
    ''');
  }

  // Добавление нового пользователя
  Future<int> insertUser(String username, String password) async {
    final db = await database;  // получаем объект базы
    return await db.insert(
      'users', 
      {
        'username': username,
        'password': password,
        'created_at': DateTime.now().toIso8601String(), // текущая дата
      },
      conflictAlgorithm: ConflictAlgorithm.abort, // если username уже есть, выдаёт ошибку
    );
  }

  // Получение пользователя по username
  Future<Map<String, dynamic>?> getUser(String username) async {
    final db = await database;
    final res = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (res.isNotEmpty) return res.first; // возвращаем первую запись
    return null; // если пользователя нет
  }
}

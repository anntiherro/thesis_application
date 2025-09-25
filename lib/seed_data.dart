import 'user_database.dart';

class SeedData {
  static Future<void> seedDatabase() async {
    final db = await UserDatabase().database;

    // --- Insert topics ---
    await db.insert('topics', {'title': 'Arithmetics'});
    await db.insert('topics', {'title': 'Measurement'});
    await db.insert('topics', {'title': 'Word Problems'});
    await db.insert('topics', {'title': 'Logic'});

    // --- Insert tasks ---
    await db.insert('tasks', {
      'id': 11,
      'topic_id': 1,
      'question': 'Example question 1',
      'options': null,
      'correct_answer': 'Answer 1',
      'type': 'input',
    });
    await db.insert('tasks', {
      'id': 12,
      'topic_id': 1,
      'question': 'Example question 2',
      'options': null,
      'correct_answer': 'Answer 2',
      'type': 'input',
    });
    await db.insert('tasks', {
      'id': 13,
      'topic_id': 1,
      'question': 'Example question 3',
      'options': null,
      'correct_answer': 'Answer 3',
      'type': 'input',
    });
  }
}

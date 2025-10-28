import 'user_database.dart';
import 'dart:convert';

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
      'question': '8 + 5 =',
      'options': null,
      'correct_answer': '13',
      'type': 'input',
      'icon': 'assets/plusminus.svg',
    });
    await db.insert('tasks', {
      'id': 12,
      'topic_id': 1,
      'question': '37 - 18 =',
      'options': jsonEncode(["29", "18", "19", "9"]),
      'correct_answer': '19',
      'type': 'mp',
      'icon': 'assets/plusminus.svg',
    });
    await db.insert('tasks', {
      'id': 13,
      'topic_id': 1,
      'question': '246 + 389 =',
      'options': null,
      'correct_answer': '635',
      'type': 'input',
      'icon': 'assets/plusminus.svg',
    });
    await db.insert('tasks', {
      'id': 14,
      'topic_id': 1,
      'question': '804 - 297 =',
      'options': jsonEncode(["407", "508", "408", "507"]),
      'correct_answer': '507',
      'type': 'mp',
      'icon': 'assets/plusminus.svg',
    });
    await db.insert('tasks', {
      'id': 15,
      'topic_id': 1,
      'question': '3 x 4 =',
      'options': null,
      'correct_answer': '12',
      'type': 'input',
      'icon': 'assets/multdiv.svg',
    });
    await db.insert('tasks', {
      'id': 16,
      'topic_id': 1,
      'question': '56 \\ 7 =',
      'options': null,
      'correct_answer': '8',
      'type': 'input',
      'icon': 'assets/multdiv.svg',
    });
    await db.insert('tasks', {
      'id': 17,
      'topic_id': 1,
      'question': '125 x 4 =',
      'options': null,
      'correct_answer': '500',
      'type': 'input',
      'icon': 'assets/multdiv.svg',
    });
    await db.insert('tasks', {
      'id': 18,
      'topic_id': 1,
      'question': '936 \\ 12 =',
      'options': jsonEncode(["73", "63", "72", "78"]),
      'correct_answer': '78',
      'type': 'mp',
      'icon': 'assets/multdiv.svg',
    });
    await db.insert('tasks', {
      'id': 19,
      'topic_id': 1,
      'question': '2 + 3 x 4 =',
      'options': null,
      'correct_answer': '14',
      'type': 'input',
      'icon': 'assets/order.svg',
    });
    await db.insert('tasks', {
      'id': 110,
      'topic_id': 1,
      'question': '(18 - 6) \\ 3 = ',
      'options': null,
      'correct_answer': '4',
      'type': 'input',
      'icon': 'assets/order.svg',
    });
    await db.insert('tasks', {
      'id': 111,
      'topic_id': 1,
      'question': '25 + (12 \\ 4) x 3 = ',
      'options': jsonEncode(["84", "36", "34", "41"]),
      'correct_answer': '34',
      'type': 'mp',
      'icon': 'assets/order.svg',
    });
    await db.insert('tasks', {
      'id': 112,
      'topic_id': 1,
      'question': '(48 \\ 8 + 5) x (7 - 3) =',
      'options': null,
      'correct_answer': '44',
      'type': 'input',
      'icon': 'assets/order.svg',
    });
    await db.insert('tasks', {
      'id': 21,
      'topic_id': 2,
      'question': 'How many centimeters are in 1 decimeter?',
      'options': jsonEncode(["100", "10", "1", "1000"]),
      'correct_answer': '10',
      'type': 'mp',
      'icon': 'assets/cmdm.svg',
    });
    await db.insert('tasks', {
      'id': 22,
      'topic_id': 2,
      'question': 'Convert 35 cm into decimeters.',
      'options': null,
      'correct_answer': '3.5',
      'type': 'input',
      'icon': 'assets/cmdm.svg',
    });

    await db.insert('tasks', {
      'id': 23,
      'topic_id': 2,
      'question': 'A rope is 2 m 45 cm long. How many centimeters long is it?',
      'options': jsonEncode(["245", "205", "145", "340"]),
      'correct_answer': '245',
      'type': 'mp',
      'icon': 'assets/cmdm.svg',
    });

    await db.insert('tasks', {
      'id': 24,
      'topic_id': 2,
      'question':
          'A table is 180 cm long, and a bench is 95 cm long. How much longer (in cm) is the table?',
      'options': null,
      'correct_answer': '85',
      'type': 'input',
      'icon': 'assets/cmdm.svg',
    });

    await db.insert('tasks', {
      'id': 25,
      'topic_id': 2,
      'question': 'How many grams are in 1 kilogram?',
      'options': jsonEncode(["10", "100", "1000", "10000"]),
      'correct_answer': '1000',
      'type': 'mp',
      'icon': 'assets/kg.svg',
    });

    await db.insert('tasks', {
      'id': 26,
      'topic_id': 2,
      'question': 'Convert 2,500 g into kilograms.',
      'options': null,
      'correct_answer': '2.5',
      'type': 'input',
      'icon': 'assets/kg.svg',
    });

    await db.insert('tasks', {
      'id': 27,
      'topic_id': 2,
      'question':
          'A watermelon weighs 3.7 kg, and a melon weighs 2.85 kg. What is their total mass (in g)?',
      'options': null,
      'correct_answer': '6550',
      'type': 'input',
      'icon': 'assets/kg.svg',
    });

    await db.insert('tasks', {
      'id': 28,
      'topic_id': 2,
      'question':
          'A box weighs 12 kg. With 4 identical books inside, it weighs 15.2 kg. What is the mass of one book (in g)?',
      'options': null,
      'correct_answer': '800',
      'type': 'input',
      'icon': 'assets/kg.svg',
    });

    await db.insert('tasks', {
      'id': 29,
      'topic_id': 2,
      'question': 'How many minutes are in 1 hour?',
      'options': jsonEncode(["60", "30", "100", "120"]),
      'correct_answer': '60',
      'type': 'mp',
      'icon': 'assets/time.svg',
    });

    await db.insert('tasks', {
      'id': 210,
      'topic_id': 2,
      'question': 'Convert 3 hours 25 minutes into minutes.',
      'options': null,
      'correct_answer': '205',
      'type': 'input',
      'icon': 'assets/time.svg',
    });

    await db.insert('tasks', {
      'id': 211,
      'topic_id': 2,
      'question':
          'A train departs at 14:35 and arrives at 17:10. How long does the trip take?',
      'options': jsonEncode([
        "2 h 35 min",
        "3 h 35 min",
        "2 h 15 min",
        "1 h 55 min",
      ]),
      'correct_answer': '2 h 35 min',
      'type': 'mp',
      'icon': 'assets/time.svg',
    });

    await db.insert('tasks', {
      'id': 212,
      'topic_id': 2,
      'question':
          'A lesson starts at 8:15 and ends at 8:55. After a 20-minute break, when does the next lesson start?',
      'options': null,
      'correct_answer': '9:15',
      'type': 'input',
      'icon': 'assets/time.svg',
    });
    await db.insert('tasks', {
      'id': 31,
      'topic_id': 3,
      'question':
          'Tom has 5 apples. He buys 3 more apples. Then he gives 2 apples to his friend. Write all calculation steps.',
      'options': null,
      'correct_answer': jsonEncode([
        {'step_type': 'sum', 'expected_result': 8},
        {'step_type': 'subtract', 'expected_result': 6},
      ]),
      'type': 'multi-step',
      'icon': 'assets/ms1.svg',
    });

    await db.insert('tasks', {
      'id': 32,
      'topic_id': 3,
      'question':
          'Anna has 12 candies. She eats 4 candies. Then her friend gives her 7 more candies. Show all steps.',
      'options': null,
      'correct_answer': jsonEncode([
        {"step_type": "subtract", "expected_result": 8},
        {"step_type": "sum", "expected_result": 15},
      ]),
      'type': 'multi-step',
      'icon': 'assets/ms1.svg',
    });

    await db.insert('tasks', {
      'id': 33,
      'topic_id': 3,
      'question':
          'A basket has 20 oranges. 5 are taken out, then 8 more are added. Show your calculations step by step.',
      'options': null,
      'correct_answer': jsonEncode([
        {"step_type": "subtract", "expected_result": 15},
        {"step_type": "sum", "expected_result": 23},
      ]),
      'type': 'multi-step',
      'icon': 'assets/ms1.svg',
    });

    await db.insert('tasks', {
      'id': 34,
      'topic_id': 3,
      'question':
          'Lily has 30 pencils. She gives 10 to her friend and buys 12 more. Write each calculation step.',
      'options': null,
      'correct_answer': jsonEncode([
        {"step_type": "subtract", "expected_result": 20},
        {"step_type": "sum", "expected_result": 32},
      ]),
      'type': 'multi-step',
      'icon': 'assets/ms1.svg',
    });

    await db.insert('tasks', {
      'id': 35,
      'topic_id': 3,
      'question':
          'Max has 3 boxes. Each box has 4 toys. How many toys in total? Then he gives 5 toys to his friend. Show all steps.',
      'options': null,
      'correct_answer': jsonEncode([
        {"step_type": "multiply", "expected_result": 12},
        {"step_type": "subtract", "expected_result": 7},
      ]),
      'type': 'multi-step',
      'icon': 'assets/ms2.svg',
    });

    await db.insert('tasks', {
      'id': 36,
      'topic_id': 3,
      'question':
          'A baker makes 6 cakes every day. How many cakes in 5 days? Then he sells 8 cakes. Show your calculations.',
      'options': null,
      'correct_answer': jsonEncode([
        {"step_type": "multiply", "expected_result": 30},
        {"step_type": "subtract", "expected_result": 22},
      ]),
      'type': 'multi-step',
      'icon': 'assets/ms2.svg',
    });

    await db.insert('tasks', {
      'id': 37,
      'topic_id': 3,
      'question':
          'There are 24 candies. They are shared equally among 6 children. Then 2 candies are added to each child. Write each step.',
      'options': null,
      'correct_answer': jsonEncode([
        {"step_type": "divide", "expected_result": 4},
        {"step_type": "sum", "expected_result": 6},
      ]),
      'type': 'multi-step',
      'icon': 'assets/ms2.svg',
    });

    await db.insert('tasks', {
      'id': 38,
      'topic_id': 3,
      'question':
          'A farmer has 8 rows of trees. Each row has 5 trees. Then 6 more trees are planted. Show all calculation steps.',
      'options': null,
      'correct_answer': jsonEncode([
        {"step_type": "multiply", "expected_result": 40},
        {"step_type": "sum", "expected_result": 46},
      ]),
      'type': 'multi-step',
      'icon': 'assets/ms2.svg',
    });

    await db.insert('tasks', {
      'id': 39,
      'topic_id': 3,
      'question':
          'A train travels 60 km in 1 hour. How far will it travel in 3 hours? Then it stops for 1 hour. Calculate the total distance.',
      'options': null,
      'correct_answer': jsonEncode([
        {"step_type": "multiply", "expected_result": 180},
        {"step_type": "subtract", "expected_result": 180},
      ]),
      'type': 'multi-step',
      'icon': 'assets/ms3.svg',
    });

    await db.insert('tasks', {
      'id': 310,
      'topic_id': 3,
      'question':
          'A car drives 50 km per hour. It drives for 2 hours, then increases speed to 60 km per hour for 1 hour. How far did it go? Show each step.',
      'options': null,
      'correct_answer': jsonEncode([
        {"step_type": "multiply", "expected_result": 100},
        {"step_type": "multiply", "expected_result": 60},
        {"step_type": "sum", "expected_result": 160},
      ]),
      'type': 'multi-step',
      'icon': 'assets/ms3.svg',
    });

    await db.insert('tasks', {
      'id': 311,
      'topic_id': 3,
      'question':
          'A pool is filled with 200 liters of water per hour. After 3 hours, another 150 liters are added. Calculate the total amount of water.',
      'options': null,
      'correct_answer': jsonEncode([
        {"step_type": "multiply", "expected_result": 600},
        {"step_type": "sum", "expected_result": 750},
      ]),
      'type': 'multi-step',
      'icon': 'assets/ms3.svg',
    });

    await db.insert('tasks', {
      'id': 312,
      'topic_id': 3,
      'question':
          'John runs 4 km every day for 5 days. Then he rests 1 day. What is the total distance he ran? Show each calculation step.',
      'options': null,
      'correct_answer': jsonEncode([
        {"step_type": "multiply", "expected_result": 20},
        {"step_type": "sum", "expected_result": 20},
      ]),
      'type': 'multi-step',
      'icon': 'assets/ms3.svg',
    });

    await db.insert('tasks', {
      'id': 41,
      'topic_id': 4,
      'question': 'Which group does the triangle belong to?',
      'options': jsonEncode(["Squares", "Circles", "Triangles", "Rectangles"]),
      'correct_answer': 'Triangles',
      'type': 'mp',
      'icon': 'assets/logic1.svg',
    });
    await db.insert('tasks', {
      'id': 42,
      'topic_id': 4,
      'question': 'Write the name of the group: {2, 4, 6, 8}.',
      'options': null,
      'correct_answer': 'Even numbers',
      'type': 'input',
      'icon': 'assets/logic1.svg',
    });
    await db.insert('tasks', {
      'id': 43,
      'topic_id': 4,
      'question': 'Which object does NOT belong in the group?',
      'options': jsonEncode(["Apple", "Banana", "Carrot", "Pear"]),
      'correct_answer': 'Carrot',
      'type': 'mp',
      'icon': 'assets/logic1.svg',
    });
    await db.insert('tasks', {
      'id': 44,
      'topic_id': 4,
      'question':
          'Classify the shapes {cube, sphere, cylinder}. Are these 2D or 3D shapes?',
      'options': null,
      'correct_answer': '3D shapes',
      'type': 'input',
      'icon': 'assets/logic1.svg',
    });
    await db.insert('tasks', {
      'id': 45,
      'topic_id': 4,
      'question': 'Which number is greater?',
      'options': jsonEncode(["27", "19"]),
      'correct_answer': '27',
      'type': 'mp',
      'icon': 'assets/logic2.svg',
    });
    await db.insert('tasks', {
      'id': 46,
      'topic_id': 4,
      'question': 'Compare: 345 ___ 354',
      'options': null,
      'correct_answer': '<',
      'type': 'input',
      'icon': 'assets/logic2.svg',
    });
    await db.insert('tasks', {
      'id': 47,
      'topic_id': 4,
      'question': 'Which number is greater than 1234?',
      'options': jsonEncode(["546", "999", "1212", "2678"]),
      'correct_answer': '2678',
      'type': 'mp',
      'icon': 'assets/logic2.svg',
    });
    await db.insert('tasks', {
      'id': 48,
      'topic_id': 4,
      'question': 'Arrange the numbers in ascending order: 85, 92, 74, 101.',
      'options': null,
      'correct_answer': '74, 85, 92, 101',
      'type': 'input',
      'icon': 'assets/logic2.svg',
    });
    await db.insert('tasks', {
      'id': 49,
      'topic_id': 4,
      'question': 'All cats are animals. Max is a cat. What can we conclude?',
      'options': jsonEncode([
        "Max is an animal",
        "Max is a dog",
        "Max is a fish",
        "Max is not an animal",
      ]),
      'correct_answer': 'Max is an animal',
      'type': 'mp',
      'icon': 'assets/logic3.svg',
    });
    await db.insert('tasks', {
      'id': 410,
      'topic_id': 4,
      'question': 'Fill in: If today is Monday, tomorrow will be',
      'options': null,
      'correct_answer': 'Tuesday',
      'type': 'input',
      'icon': 'assets/logic3.svg',
    });
    await db.insert('tasks', {
      'id': 411,
      'topic_id': 4,
      'question': 'Which statement is true?',
      'options': jsonEncode([
        "12 is divisible by 5",
        "12 is divisible by 3",
        "12 is divisible by 7",
        "12 is divisible by 11",
      ]),
      'correct_answer': '12 is divisible by 3',
      'type': 'mp',
      'icon': 'assets/logic3.svg',
    });
    await db.insert('tasks', {
      'id': 412,
      'topic_id': 4,
      'question': 'If 2 × N = 18, what is N?',
      'options': null,
      'correct_answer': '9',
      'type': 'input',
      'icon': 'assets/logic3.svg',
    });
  }
}

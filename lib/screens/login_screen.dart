import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../user_database.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final db = UserDatabase();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(95, 161, 159, 1),
      body: Stack(
        children: [
          /// TOP WAVE BACKGROUND
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: TopWaveClipper(),
              child: Container(
                height: size.height * 0.70,
                color: const Color.fromRGBO(249, 241, 220, 1),
              ),
            ),
          ),

          /// ---------- CONTENT ----------
          Column(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      reverse: true, // поднимает поле вверх
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            children: [
                              SizedBox(height: size.height * 0.08),

                              /// --- FIXED SVG ---
                              SvgPicture.asset(
                                "assets/app_name-cropped.svg",
                                width: size.width * 0.9,
                                height: size.height * 0.18,
                                fit: BoxFit.contain,
                              ),

                              const SizedBox(height: 10),

                              SvgPicture.asset(
                                "assets/characters.svg",
                                width: size.width * 0.50,
                                height: size.height * 0.16,
                                fit: BoxFit.contain,
                              ),

                              /// --- Spacer that collapses when keyboard appears ---
                              const Spacer(),

                              /// --- INPUTS (move up with keyboard) ---
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24.0,
                                ),
                                child: Column(
                                  children: [
                                    _inputField(
                                      controller: usernameController,
                                      hint: "USERNAME",
                                    ),
                                    const SizedBox(height: 16),
                                    _inputField(
                                      controller: passwordController,
                                      hint: "PASSWORD",
                                      obscure: true,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),



              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 45,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// REGISTER BUTTON - Bottom Left
                    TextButton(
                      onPressed: _register,
                      child: const Text(
                        "REGISTER",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(249, 241, 220, 1),
                          fontFamily: "Ubuntu",
                        ),
                      ),
                    ),

                    /// LOG IN BUTTON - Bottom Right
                    SizedBox(
                      width: size.width * 0.20,
                      height: 58,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(
                            19,
                            189,
                            171,
                            1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _login,
                        child: const Text(
                          "LOG IN",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(249, 241, 220, 1),
                            fontFamily: "Ubuntu",
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  // ------------------- LOGIN LOGIC -------------------

  void _login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showMsg("Fill all fields");
      return;
    }

    final user = await db.getUser(username);

    if (user == null) {
      _showMsg("No such account. Please register first.");
      return;
    }

    if (user["password"] != password) {
      _showMsg("Wrong password");
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen(username: username)),
    );
  }

  // ------------------- REGISTER LOGIC -------------------

  void _register() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showMsg("Fill all fields");
      return;
    }

    try {
      await db.insertUser(username, password);
      _showMsg("Account created successfully!");
    } catch (e) {
      _showMsg("Username already exists");
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ------------------- INPUT FIELD -------------------

 Widget _inputField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
  }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.4,
      child: TextField(
        controller: controller,
        obscureText: obscure,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 26, fontFamily: "Ubuntu"),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color.fromRGBO(249, 241, 220, 1), 
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 24,
            color: Colors.grey,
            fontFamily: "Ubuntu",
            fontWeight: FontWeight.bold,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color.fromRGBO(19, 189, 171, 1), 
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color.fromRGBO(
                19,
                189,
                171,
                1,
              ), 
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color.fromRGBO(0, 150, 136, 1), 
              width: 2.5,
            ),
          ),
        ),
      ),
    );
  }
}

/// ------------------- WAVE CLIPPER -------------------

class TopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.75);

    final firstControlPoint = Offset(size.width * 0.25, size.height);
    final firstEndPoint = Offset(size.width * 0.5, size.height * 0.85);

    final secondControlPoint = Offset(size.width * 0.75, size.height * 0.7);
    final secondEndPoint = Offset(size.width, size.height * 0.8);

    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

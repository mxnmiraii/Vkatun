import 'package:flutter/material.dart';
import 'package:vkatun/pages/register_page.dart';
import 'package:vkatun/pages/resumes_page.dart';
import 'package:vkatun/pages/start_page.dart';

import '../design/colors.dart';
import '../design/dimensions.dart';
import '../design/images.dart';

class EntryPage extends StatefulWidget {
  const EntryPage({super.key});

  @override
  State<EntryPage> createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    // очистка после закрытия страницы (обязательно!)
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void _handleLogin() {
      final login = _loginController.text;
      final password = _passwordController.text;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ResumesPage()),
      );

      // реализация авторизации
    }

    final _textStyle = TextStyle(
      color: midnightPurple,
      fontFamily: 'Playfair',
      // letterSpacing: -1.1,
      height: 1.5,
    );

    final _inputDecoration = InputDecoration(
      filled: true,
      fillColor: Colors.white,
      labelStyle: TextStyle(color: lightGrayText),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(width: 2, color: vividPeriwinkleBlue),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(width: 2, color: vividPeriwinkleBlue),
      ),
      border: OutlineInputBorder( // Общее fallback-значение
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(width: 2, color: vividPeriwinkleBlue),
      ),
    );

    final screenHeight = MediaQuery.of(context).size.height;
    final backgroundHeight = screenHeight * 0.6;
    final backgroundColorWater = waterBackground.withOpacity(0.21);

    return Scaffold(
      resizeToAvoidBottomInset: false,

      body: Stack(
        children: [
          ClipPath(
            clipper: BottomCurveClipper(),
            child: Container(
              height: backgroundHeight, // Высота изогнутого фона
              color: backgroundColorWater, // Цвет фона (как на твоем макете)
            ),
          ),

          SafeArea(child: Column(
            children: [
              Expanded(
                flex: 4,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 20,),
                      Text(
                        'Вход',
                        style: _textStyle.copyWith(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          color: blue,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      Text(
                        'С возвращением!',
                        style: _textStyle.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                flex: 3,
                child: Padding(
                  padding: buttonPadding,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextField(
                        controller: _loginController,
                        textAlign: TextAlign.start,
                        decoration: _inputDecoration.copyWith(
                          labelText: 'Имя пользователя',
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: _inputDecoration.copyWith(labelText: 'Пароль'),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 40,),

              Expanded(
                flex: 4,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: buttonPaddingHorizontal,
                    ),
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mediumSlateBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(17),
                            ),
                            minimumSize: const Size(double.infinity, 50),
                            elevation: 0,
                          ),
                          child: Text(
                            'Войти',
                            style: _textStyle.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        SizedBox(height: 10),

                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => RegisterPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(borderRadius),
                            ),
                            minimumSize: const Size(double.infinity, 50),
                            elevation: 0,
                          ),
                          child: Text(
                            'Зарегистрироваться',
                            style: _textStyle.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ))
        ],
      )
    );
  }
}

class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 250);

    path.quadraticBezierTo(
      size.width * 0.6, size.height,
      size.width, size.height - 70,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

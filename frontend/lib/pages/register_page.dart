import 'package:flutter/material.dart';
import 'package:vkatun/pages/resumes_page.dart';
import 'package:vkatun/pages/start_page.dart';

import '../design/colors.dart';
import '../design/dimensions.dart';
import '../design/images.dart';
import 'entry_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _emailNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordRepeatController = TextEditingController();

  @override
  void dispose() {
    // очистка после закрытия страницы (обязательно!)
    _loginController.dispose();
    _emailNumberController.dispose();
    _passwordController.dispose();
    _passwordRepeatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void _handleLogin() {
      final login = _loginController.text;
      final emailNumber = _emailNumberController.text;
      final password = _passwordController.text;
      final passwordRepeat = _passwordRepeatController.text;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ResumesPage()),
      );

      // реализация регистрации
    }

    final _textStyle = TextStyle(
      color: midnightPurple,
      fontFamily: 'Playfair',
      // letterSpacing: -1.1,
      height: 1.5,
    );

    final _inputDecoration = InputDecoration(
      filled: true,
      fillColor: veryPaleBlue,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide.none,
      ),
    );

    const borderButtonColor = royalPurple;
    const backgroundButtonColor = lightLavender;

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final appBarHeight = screenHeight * 0.10;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: appBarHeight,
        title: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: arrowBackIcon,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EntryPage()),
                  );
                },
              ),
            ),
            Center(child: logoFullIcon),
          ],
        ),
        centerTitle: true,
        elevation: 0,
      ),

      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                'Регистрация',
                style: _textStyle.copyWith(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          Expanded(
            flex: 1,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Создайте свою учетную запись,',
                    style: _textStyle.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'чтобы продолжить',
                    style: _textStyle.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
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
                    decoration: _inputDecoration.copyWith(
                      labelText: 'Имя пользователя',
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: _emailNumberController,
                    decoration: _inputDecoration.copyWith(
                        labelText: 'Телефон или адрес эл.почты'
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: _inputDecoration.copyWith(
                        labelText: 'Пароль'
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: _passwordRepeatController,
                    obscureText: true,
                    decoration: _inputDecoration.copyWith(
                        labelText: 'Подтверждение пароля'
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            flex: 1,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: buttonPaddingHorizontal,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => ResumesPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        side: BorderSide(
                            color: borderButtonColor,
                            width: widthBorderRadius
                        ),
                        backgroundColor: backgroundButtonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(borderRadius),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                        elevation: 0,
                      ),
                      child: Text(
                        'Создать аккаунт',
                        style: _textStyle.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
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
      ),
    );
  }
}

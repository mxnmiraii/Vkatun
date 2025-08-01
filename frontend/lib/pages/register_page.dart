import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vkatun/account/account_main_page.dart';
import 'package:vkatun/pages/resumes_page.dart';
import 'package:vkatun/pages/start_page.dart';

import '../account/account_page.dart';
import '../api_service.dart';
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
  final TextEditingController _passwordRepeatController =
      TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  final Map<String, String> _fieldErrors = {};
  final Map<String, bool> _fieldErrorStates = {
    'login': false,
    'email': false,
    'password': false,
    'passwordRepeat': false,
  };

  void _showFieldError(String field, String message) {
    setState(() {
      _fieldErrors[field] = message;
      _fieldErrorStates[field] = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _fieldErrors.remove(field);
        _fieldErrorStates[field] = false;
      });
    });
  }

  @override
  void dispose() {
    // очистка после закрытия страницы (обязательно!)
    _loginController.dispose();
    _emailNumberController.dispose();
    _passwordController.dispose();
    _passwordRepeatController.dispose();
    super.dispose();
  }

  Future<void> logRegisterEvent() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final profile = await apiService.getProfile();

      AppMetrica.setUserProfileID(profile['id'].toString());
      await AppMetrica.reportEvent('registration_success');
    } catch (e) {
      print('Ошибка при логине: $e');
    }
  }

  Future<Map<String, dynamic>> _getProfileData() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final response = await apiService.getProfile();
      return response;
    } catch (e) {
      print('Ошибка при анализе $e');
      return {"id": null, "email": null};
    }
  }

  @override
  Widget build(BuildContext context) {
    Future<void> _performRegistration(String login, String emailNumber, String password) async {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        final apiService = Provider.of<ApiService>(context, listen: false);

        // 1. Выполняем регистрацию
        await apiService.register(
          username: login,
          emailOrPhone: emailNumber,
          password: password,
        );

        // 2. После успешной регистрации выполняем вход
        await apiService.login(
          emailOrPhone: emailNumber,
          password: password,
        );

        logRegisterEvent();

        // 3. Успешная регистрация и вход
        Map<String, dynamic> profileData = await _getProfileData();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AccountPage(profileData: profileData,)),
        );
      } catch (e) {
        // Обработка ошибок
        final errorMessage = e.toString().contains('User registered successfully')
            ? 'Регистрация успешна! Выполняется вход...'
            : 'Ошибка регистрации: ${e.toString().replaceAll('Exception: ', '')}';

        setState(() => _errorMessage = errorMessage);

        // Если регистрация успешна, но возникла проблема с входом
        if (e.toString().contains('User registered successfully')) {
          try {
            // Пробуем войти еще раз
            final apiService = Provider.of<ApiService>(context, listen: false);
            await apiService.login(
              emailOrPhone: emailNumber,
              password: password,
            );

            Map<String, dynamic> profileData = await _getProfileData();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AccountPage(profileData: profileData,)),
            );
          } catch (loginError) {
            setState(() => _errorMessage = 'Регистрация успешна, но вход не удался. Пожалуйста, войдите вручную.');
          }
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }

    bool _isValidPassword(String password) {
      final lengthValid = password.length >= 8 && password.length <= 25;
      final hasDigit = password.contains(RegExp(r'\d'));
      final hasSpecialChar = password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
      return lengthValid && hasDigit && hasSpecialChar;
    }

    void _handleRegister() {
      final login = _loginController.text.trim();
      final emailNumber = _emailNumberController.text.trim();
      final password = _passwordController.text;
      final passwordRepeat = _passwordRepeatController.text;

      if (login.isEmpty || login.length < 3 || login.length > 30) {
        _showFieldError('login', 'Имя: 3–30 символов');
        return;
      }

      if (emailNumber.isEmpty || emailNumber.length < 3 || emailNumber.length > 100) {
        _showFieldError('email', 'Email: 3–100 символов');
        return;
      }

      if (password.isEmpty || !_isValidPassword(password)) {
        _showFieldError('password', 'Пароль: 8–25 символов, цифра и символ');
        return;
      }

      if (password != passwordRepeat) {
        _showFieldError('passwordRepeat', 'Пароли не совпадают');
        return;
      }

      _performRegistration(login, emailNumber, password);
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
      border: OutlineInputBorder(
        // Общее fallback-значение
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(width: 2, color: vividPeriwinkleBlue),
      ),
    );

    const borderButtonColor = royalPurple;
    const backgroundButtonColor = lightLavender;

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

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  flex: 4,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 20),
                        Text(
                          'Создать аккаунт',
                          style: _textStyle.copyWith(
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            color: blue,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        Text(
                          'Добро пожаловать!',
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
                  flex: 4,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: buttonPadding,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextField(
                            controller: _loginController,
                            decoration: _inputDecoration.copyWith(
                              labelText: 'Имя пользователя',
                              errorText: _fieldErrorStates['login']! ? _fieldErrors['login'] : null,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(
                                  width: 2,
                                  color: _fieldErrorStates['login']! ? Colors.red : vividPeriwinkleBlue,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(
                                  width: 2,
                                  color: _fieldErrorStates['login']! ? Colors.red : vividPeriwinkleBlue,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          TextField(
                            controller: _emailNumberController,
                            decoration: _inputDecoration.copyWith(
                              labelText: 'Адрес электронной почты',
                              errorText: _fieldErrorStates['email']! ? _fieldErrors['email'] : null,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(
                                  width: 2,
                                  color: _fieldErrorStates['email']! ? Colors.red : vividPeriwinkleBlue,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(
                                  width: 2,
                                  color: _fieldErrorStates['email']! ? Colors.red : vividPeriwinkleBlue,
                                ),
                              ),
                            ),
                          ),


                          const SizedBox(height: 10),

                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: _inputDecoration.copyWith(
                              labelText: 'Пароль',
                              errorText: _fieldErrorStates['password']! ? _fieldErrors['password'] : null,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(
                                  width: 2,
                                  color: _fieldErrorStates['password']! ? Colors.red : vividPeriwinkleBlue,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(
                                  width: 2,
                                  color: _fieldErrorStates['password']! ? Colors.red : vividPeriwinkleBlue,
                                ),
                              ),
                            ),
                          ),


                          const SizedBox(height: 10),

                          TextField(
                            controller: _passwordRepeatController,
                            obscureText: true,
                            decoration: _inputDecoration.copyWith(
                              labelText: 'Подтверждение пароля',
                              errorText: _fieldErrorStates['passwordRepeat']! ? _fieldErrors['passwordRepeat'] : null,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(
                                  width: 2,
                                  color: _fieldErrorStates['passwordRepeat']! ? Colors.red : vividPeriwinkleBlue,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(
                                  width: 2,
                                  color: _fieldErrorStates['passwordRepeat']! ? Colors.red : vividPeriwinkleBlue,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ),

                SizedBox(height: 40),

                Expanded(
                  flex: 2,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: buttonPaddingHorizontal,
                      ),
                      child: Column(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: mediumSlateBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(17),
                              ),
                              minimumSize: const Size(double.infinity, 50),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                              'Создать аккаунт',
                              style: _textStyle.copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          // Кнопка входа:
                          ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => EntryPage()),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(borderRadius),
                              ),
                              minimumSize: const Size(double.infinity, 50),
                              elevation: 0,
                            ),
                            child: Text(
                              'Уже есть аккаунт',
                              style: _textStyle.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 250);

    path.quadraticBezierTo(
      size.width * 0.6,
      size.height,
      size.width,
      size.height - 70,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}



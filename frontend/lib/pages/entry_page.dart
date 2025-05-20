import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vkatun/api_service.dart';
import 'package:vkatun/pages/register_page.dart';
import 'package:vkatun/pages/resumes_page.dart';
import '../design/colors.dart';
import '../design/dimensions.dart';

class EntryPage extends StatefulWidget {
  const EntryPage({super.key});

  @override
  State<EntryPage> createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  final Map<String, String> _fieldErrors = {};
  final Map<String, bool> _fieldErrorStates = {
    'login': false,
    'password': false,
  };

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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

  void _handleLogin() {
    final emailNumber = _loginController.text.trim();
    final password = _passwordController.text;

    if (emailNumber.isEmpty) {
      _showFieldError('login', 'Введите email');
      return;
    }

    if (password.isEmpty) {
      _showFieldError('password', 'Введите пароль');
      return;
    }

    _performLogin(emailNumber, password);
  }

  Future<void> _performLogin(String emailNumber, String password) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      await apiService.login(
        emailOrPhone: emailNumber,
        password: password,
      );

      await AppMetrica.reportEvent('login_success');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ResumesPage()),
      );
    } catch (e) {
      _showFieldError('password', 'Неверный логин или пароль');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final _textStyle = TextStyle(
      color: midnightPurple,
      fontFamily: 'Playfair',
      height: 1.5,
    );

    final _inputDecoration = InputDecoration(
      filled: true,
      fillColor: Colors.white,
      labelStyle: TextStyle(color: lightGrayText),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(width: 2),
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
              height: backgroundHeight,
              color: backgroundColorWater,
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
                        const SizedBox(height: 20),
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
                          decoration: _inputDecoration.copyWith(
                            labelText: 'Email',
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
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Expanded(
                  flex: 4,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: buttonPaddingHorizontal),
                      child: Column(
                        children: [
                          ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: mediumSlateBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(17),
                              ),
                              minimumSize: const Size(double.infinity, 50),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(
                              'Войти',
                              style: _textStyle.copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const RegisterPage()),
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

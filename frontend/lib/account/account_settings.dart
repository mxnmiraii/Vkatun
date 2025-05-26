import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vkatun/design/colors.dart';
import 'package:vkatun/design/dimensions.dart';
import 'package:vkatun/design/images.dart';

import '../api_service.dart';

import '../pages/start_page.dart';

class AccountSettingsPage extends StatefulWidget {
  final Map<String, dynamic> profileData;
  const AccountSettingsPage({super.key, required this.profileData});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  late TextEditingController _usernameController = TextEditingController();
  late TextEditingController _oldPassController = TextEditingController();
  late TextEditingController _newPassController = TextEditingController();

  bool _oldPassError = false;
  bool _newPassError = false;
  String? _errorMessage;

  bool _isValidPassword(String password) {
    final lengthValid = password.length >= 8 && password.length <= 25;
    final hasDigit = password.contains(RegExp(r'\d'));
    final hasSpecialChar = password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
    return lengthValid && hasDigit && hasSpecialChar;
  }


  @override
  void dispose() {
    _usernameController.dispose();
    _oldPassController.dispose();
    _newPassController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.profileData['username']);
    _oldPassController = TextEditingController(text: '');
    _newPassController = TextEditingController(text: '');
  }

  Future<void> _setUsername(String newUsername) async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final response = await apiService.updateProfileName(newUsername);

      return response;
    } catch (e) {
      print('Ошибка $e');
    }
  }

  Future<bool> _setPassword(String oldPass, String newPass) async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      await apiService.updatePassword(
        currentPassword: oldPass,
        newPassword: newPass,
      );
      return true;
    } catch (e) {
      print('Ошибка при смене пароля: $e');
      return false;
    }
  }

  void _clearErrorAfterDelay() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _oldPassError = false;
          _newPassError = false;
          _errorMessage = null;
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = screenHeight * 0.1;
    final screenWidth = MediaQuery.of(context).size.width;
    final space = screenWidth * 0.05;

    return Scaffold(
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          toolbarHeight: appBarHeight,
          centerTitle: false,
          systemOverlayStyle: SystemUiOverlayStyle.dark, // ← важная строка
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: lightArrowBackIcon,
              ),
              Text(
                'Аккаунт',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 32,
                  fontFamily: 'Playfair',
                  color: purpleBlue,
                ),
              ),
              IconButton(
                onPressed: () async {
                  final apiService = Provider.of<ApiService>(context, listen: false);
                  await apiService.clearToken();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => StartPage()),
                        (Route<dynamic> route) => false,
                  );
                },
                icon: logOutIcon,
                tooltip: 'Выйти из аккаунта',
              ),
            ],
          ),
        ),
      ),

      body: Stack(
        children: [
          // Градиент на фоне
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.8, -0.1), // правый край, чуть выше центра
                radius: 1.6,
                colors: [
                  Color(0xFFD8D7FF), // начало
                  Color(0xFFE9F7FA), // середина
                  Color(0xFFFFFFFF), // конец
                ],
                stops: [0.0, 0.75, 0.95],
              ),
            ),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.only(top: 24),
            child: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: vividPeriwinkleBlue.withOpacity(0.8), // прозрачность
                  width: 1.6,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.30),
                    blurRadius: 2,
                    spreadRadius: 0.2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Column(children: [
                _buildTextField(
                  label: 'Имя пользователя',
                  controller: _usernameController,
                  isError: false,
                ),

                const SizedBox(height: 30),

                _buildTextField(
                  label: 'Старый пароль',
                  controller: _oldPassController,
                  isError: _oldPassError,
                  errorText: _errorMessage,
                ),

                const SizedBox(height: 30),

                _buildTextField(
                  label: 'Новый пароль',
                  controller: _newPassController,
                  isError: _newPassError,
                  errorText: _errorMessage,
                ),

              ]),
            ),
          ),
        ],
      ),

      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: bottom35),
        child: IconButton(
          icon: doneIcon,
          onPressed: () async {
            final oldInput = _oldPassController.text.trim();
            final newInput = _newPassController.text.trim();

            setState(() {
              _oldPassError = false;
              _newPassError = false;
              _errorMessage = null;
            });

            if (widget.profileData['username'] != _usernameController.text.trim()) {
              await _setUsername(_usernameController.text.trim());
            }

            if (oldInput.isEmpty || newInput.isEmpty) {
              setState(() {
                _oldPassError = oldInput.isEmpty;
                _newPassError = newInput.isEmpty;
                _errorMessage = 'Заполните оба поля';
              });
              _clearErrorAfterDelay();
              return;
            }

            if (!_isValidPassword(newInput)) {
              setState(() {
                _newPassError = true;
                _errorMessage = 'Пароль должен быть от 8 до 25 символов и содержать цифру и спецсимвол';
              });
              _clearErrorAfterDelay();
              return;
            }

            final success = await _setPassword(oldInput, newInput);

            if (success) {
              Navigator.pop(context);
            } else {
              setState(() {
                _oldPassError = true;
                _errorMessage = 'Старый пароль неверный';
              });
              _clearErrorAfterDelay();
            }
          },
          iconSize: 36, // Можно настроить размер иконки
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required bool isError,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Playfair',
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: darkImperialBlue,
          ),
        ),
        const SizedBox(height: 10),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isError ? Colors.red : lightVioletDivider.withOpacity(0.5),
                width: 1.5,
              ),
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: label.contains("пароль"), // скрываем для паролей
            style: const TextStyle(
              fontFamily: "NotoSans",
              fontSize: 14,
              fontWeight: FontWeight.w300,
              color: black,
            ),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.only(top: 7, bottom: 14),
              border: InputBorder.none,
            ),
          ),
        ),
        if (isError && errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              errorText,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.red,
              ),
            ),
          ),
      ],
    );
  }

}



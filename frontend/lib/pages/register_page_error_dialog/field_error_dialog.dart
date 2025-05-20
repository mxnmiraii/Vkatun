import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../design/colors.dart';
import '../../design/dimensions.dart';
import '../../design/images.dart';

enum FieldErrorType {
  emptyFields,
  invalidUsername,
  invalidEmail,
  invalidPassword,
  passwordsDoNotMatch,
}

class FieldErrorDialog extends StatelessWidget {
  final FieldErrorType errorType;

  const FieldErrorDialog({super.key, required this.errorType});

  String _getTitle() {
    switch (errorType) {
      case FieldErrorType.emptyFields:
        return 'Пустые поля';
      case FieldErrorType.invalidUsername:
        return 'Некорректное имя';
      case FieldErrorType.invalidEmail:
        return 'Некорректный Email';
      case FieldErrorType.invalidPassword:
        return 'Слабый пароль';
      case FieldErrorType.passwordsDoNotMatch:
        return 'Пароли не совпадают';
    }
  }

  String _getMessage() {
    switch (errorType) {
      case FieldErrorType.emptyFields:
        return 'Пожалуйста, заполните все поля перед регистрацией.';
      case FieldErrorType.invalidUsername:
        return 'Имя пользователя должно быть от 3 до 30 символов.';
      case FieldErrorType.invalidEmail:
        return 'Email должен быть от 3 до 100 символов и быть уникальным.';
      case FieldErrorType.invalidPassword:
        return 'Пароль должен быть от 8 до 25 символов и содержать хотя бы одну цифру и один спецсимвол.';
      case FieldErrorType.passwordsDoNotMatch:
        return 'Пожалуйста, убедитесь, что оба пароля совпадают.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              spreadRadius: 1,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Center(child: errorIcon),
            ),
            const SizedBox(height: 16),
            Text(
              _getTitle(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                fontFamily: 'Playfair',
                color: vibrantViolet,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _getMessage(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                fontFamily: 'Playfair',
                color: electricLavender,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: cancelIcon2,
              iconSize: 40,
            ),
          ],
        ),
      ),
    );
  }
}

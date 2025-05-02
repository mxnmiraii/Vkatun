import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../design/colors.dart'; // vibrantViolet, electricLavender
import '../design/images.dart';

class ErrorDialog extends StatelessWidget {
  const ErrorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final dialogHeight = screenSize.height / 3;
    final dialogWidth = screenSize.width * 4 / 6;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Лёгкое затемнение фона
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            color: Colors.black.withOpacity(0.1),
            width: double.infinity,
            height: double.infinity,
          ),
        ),

        // Диалог
        Positioned(
          top: screenSize.height / 3.5,
          child: Material(
            color: Colors.transparent,
            child: Container(
              height: dialogHeight,
              width: dialogWidth,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/errorIcon.svg',
                    height: 60,
                    width: 60,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Ошибка загрузки',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: vibrantViolet,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Извините!\nЧто-то пошло не так:(',
                    style: TextStyle(
                      fontSize: 14,
                      color: electricLavender,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),

        // Кнопка "закрыть"
        Positioned(
          bottom: 40,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: vibrantViolet,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: cancelIcon2, // ← твоя иконка
              ),
            ),
          ),
        ),
      ],
    );
  }
}

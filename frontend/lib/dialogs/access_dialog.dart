import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../design/colors.dart'; // vibrantViolet, electricLavender
import '../design/dimensions.dart';
import '../design/images.dart';

class AccessDialog extends StatelessWidget {
  const AccessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final dialogHeight = screenSize.height / 3;
    final dialogWidth = screenSize.width * 4 / 6;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Container(
              color: const Color(0xFFEFEFEF).withOpacity(0.6), // Серый полупрозрачный
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
                      spreadRadius: 1,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: Center(child: accessIcon),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Ошибка загрузки',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Playfair',
                        color: vibrantViolet,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Извините!\nЧто-то пошло не так:(',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Playfair',
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
            bottom: 28,
            child: AnimatedBuilder(
              animation: AlwaysStoppedAnimation(0),
              builder: (context, child) {
                return Transform.rotate(
                  angle: 0,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 100,
                      height: 100,
                      child: Center(
                        child: cancelIcon2,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

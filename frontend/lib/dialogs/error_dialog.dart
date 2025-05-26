import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../design/colors.dart';
import '../design/dimensions.dart';
import '../design/images.dart';

class ErrorDialog extends StatelessWidget {
  const ErrorDialog({super.key});

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
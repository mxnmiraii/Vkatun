import 'package:flutter/material.dart';
import 'package:vkatun/design/colors.dart';
import 'package:vkatun/design/dimensions.dart';
import 'package:vkatun/design/images.dart';

import 'check_widget.dart';
import 'indicator.dart';

class Scan extends StatelessWidget {
  final VoidCallback onBackPressed;
  final VoidCallback onClose;
  final Map<String, dynamic> resume;
  final String title;
  final List<Issue> issues;
  final bool isLoading;
  const Scan({
    super.key,
    required this.onBackPressed,
    required this.onClose,
    required this.resume,
    required this.title,
    required this.issues,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    const borderWindowColor = royalPurple;
    const padding = 12.0;
    const buttonColor = cosmicBlue;

    final textStyle = TextStyle(
      color: buttonColor,
      fontFamily: 'Playfair',
      height: 1.0,
    );

    return isLoading
        ? Center(
      child: GradientCircularProgressIndicator(
        size: 70.0, // Размер индикатора
        strokeWidth: 5.0, // Толщина линии
      ),
    )
        : Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Контейнер с текстом по центру
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: padding / 2 * 1.5,
                    horizontal: padding * 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(borderRadius),
                    border: Border.all(
                      color: borderWindowColor.withOpacity(0.47),
                      width: widthBorderRadius,
                    ),
                  ),
                  child: Text(
                    title,
                    style: textStyle.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // Иконка слева (выровнена по началу строки)
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: onBackPressed,
                    icon: backCircleIcon,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child:
                  issues.isEmpty
                      ? Center(
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          padding: EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            color: Colors.white,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              accessVioletIcon,
                              SizedBox(height: 16),
                              Text(
                                'Ошибок не обнаружено',
                                style: TextStyle(
                                  fontSize: 24,
                                  color: vividPeriwinkleBlue,
                                  fontFamily: 'Playfair',
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                      : LayoutBuilder(
                        builder: (context, constraints) {
                          return CheckWidget(
                            availableHeight: constraints.maxHeight - 114,
                            onClose: onClose,
                            resume: resume,
                            issues: issues,
                          );
                        },
                      ),
            ),
          ],
        );
  }
}

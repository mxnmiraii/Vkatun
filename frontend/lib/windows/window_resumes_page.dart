import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:vkatun/design/colors.dart';
import 'package:vkatun/design/dimensions.dart';

import '../design/images.dart';
import '../pages/resume_view_page.dart';

class WindowResumesPage extends StatelessWidget {
  final VoidCallback onClose;
  final AnimationController rotationController;

  const WindowResumesPage({
    super.key,
    required this.onClose,
    required this.rotationController,
  });

  @override
  Widget build(BuildContext context) {
    const borderWindowColor = royalPurple;
    const windowColor = lightLavender;
    const padding = 20.0;
    const buttonColor = cosmicBlue;

    final textStyle = TextStyle(
      color: buttonColor,
      fontFamily: 'Playfair',
      height: 1.0,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Диалоговое окно, которое будет анимироваться
          Center(
            child: Dialog(
              insetPadding: const EdgeInsets.all(30),
              child: Container(
                padding: const EdgeInsets.all(padding),
                decoration: BoxDecoration(
                  color: windowColor,
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(
                    color: borderWindowColor,
                    width: widthBorderRadius,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: padding / 2, horizontal: padding),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(borderRadius),
                        border: Border.all(
                          color: borderWindowColor,
                          width: widthBorderRadius,
                        ),
                      ),
                      child: Text(
                        'Резюме',
                        style: textStyle.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        onClose();
                        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => ResumeViewPage(
                              resume: {
                                'id': 0,
                                'title': 'Петров Иван Иванович',
                                'contacts': 'Телефон: +7 (912) 345-67-89\nEmail: ivan.petrov@email.com',
                                'job': null,
                                'experience': 'ООО "Атом Майвинг"\nGolang backend developer\n2 года и 2 месяца',
                                'education': 'Воронежский Государственный Университет (ВГУ)\nФакультет: компьютерных наук\nПрограммная инженерная\nБакалавр 2023',
                                'skills': 'Git, SQL, Kafka, Golang, PostgreSQL',
                                'about': 'Мужчина, 23 года, родился 8 февраля 2022 года\nГражданство России\nЕсть разрешение на работу в России\nПроживает: Воронеж\nГотов к переезду, готов к командировкам',
                              },
                            ),
                          ),
                              (Route<dynamic> route) => false, // удаляет всё из стека
                        );
                      },
                      style: _buttonStyle(borderWindowColor),
                      child: Text(
                        'Редактировать резюме',
                        style: textStyle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {},
                      style: _buttonStyle(borderWindowColor),
                      child: Text(
                        'Экспорт резюме',
                        style: textStyle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {},
                      style: _buttonStyle(borderWindowColor),
                      child: Text(
                        'Удалить резюме',
                        style: textStyle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
    );
  }

  ButtonStyle _buttonStyle(Color borderColor) {
    return ElevatedButton.styleFrom(
      side: BorderSide(
        color: borderColor,
        width: widthBorderRadius,
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      minimumSize: const Size(double.infinity, 50),
      elevation: 0,
    );
  }
}



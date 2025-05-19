import 'dart:math' as math;

import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vkatun/design/colors.dart';
import 'package:vkatun/design/dimensions.dart';

import '../api_service.dart';
import '../design/images.dart';
import '../dialogs/warning_dialog.dart';
import '../pages/resume_view_page.dart';

class WindowResumesPage extends StatelessWidget {
  final VoidCallback onClose;
  final AnimationController rotationController;
  final Map<String, dynamic> resume;
  final VoidCallback onDelete;

  const WindowResumesPage({
    super.key,
    required this.onClose,
    required this.rotationController,
    required this.resume,
    required this.onDelete,
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
          Center(
            child: Dialog(
              insetPadding: const EdgeInsets.all(30),
              child: Container(
                padding: const EdgeInsets.all(padding),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      upColorGradient, // Верхний цвет (#E2E5FF)
                      downColorGradient.withOpacity(
                        0.6,
                      ), // Нижний цвет (#B2B1FF99 с 60% прозрачностью)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(
                    color: darkViolet.withOpacity(0.64),
                    width: widthBorderRadius,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: padding / 2,
                        horizontal: padding,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
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
                    _buildButton(
                      icon: miniPenIcon,
                      text: 'Редактировать резюме',
                      onPressed: () {
                        onClose();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ResumeViewPage(
                                  resume: resume,
                                  onDelete: onDelete,
                                ),
                          ),
                        );
                      },
                      textStyle: textStyle,
                      borderColor: borderWindowColor,
                    ),
                    const SizedBox(height: 10),
                    _buildButton(
                      icon: miniDownloadIcon,
                      text: 'Экспорт резюме',
                      onPressed: () {},
                      textStyle: textStyle,
                      borderColor: borderWindowColor,
                    ),
                    const SizedBox(height: 10),
                    _buildButton(
                      icon: miniDeleteIcon,
                      text: 'Удалить резюме',
                      onPressed: () async {
                        try {
                          final apiService = Provider.of<ApiService>(
                            context,
                            listen: false,
                          );
                          await apiService.deleteResume(resume['id'] as int);
                          await AppMetrica.reportEvent(
                            'delete_resume',
                          );
                          onDelete();
                          onClose();
                        } catch (e) {
                          _showWarningDialog(context);
                        }
                      },
                      textStyle: textStyle,
                      borderColor: borderWindowColor,
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

  void _showWarningDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => WarningDialog(), // Ваш кастомный диалог
      barrierDismissible: true,
    );
  }

  Widget _buildButton({
    required Widget icon,
    required String text,
    required VoidCallback onPressed,
    required TextStyle textStyle,
    required Color borderColor,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        minimumSize: const Size(double.infinity, 60),
        elevation: 0,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(alignment: Alignment.centerLeft, child: icon),
          Align(
            alignment: Alignment.center,
            child: Text(
              text,
              style: textStyle.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

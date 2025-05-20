import 'dart:async';
import 'dart:io';
import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vkatun/design/colors.dart';
import 'package:vkatun/design/dimensions.dart';
import '../api_service.dart';
import '../design/images.dart';
import '../dialogs/warning_dialog.dart';
import '../pages/resume_view_page.dart';
import '../pdf_service.dart';

class WindowResumesPage extends StatefulWidget {
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
  State<WindowResumesPage> createState() => _WindowResumesPageState();
}

class _WindowResumesPageState extends State<WindowResumesPage> {
  bool _isExporting = false;
  bool _isReadyToDownload = false;
  File? _pdfFile;
  int _loadingDots = 0;
  Timer? _dotsTimer;
  DateTime? _exportStartTime;

  @override
  void initState() {
    super.initState();
    _startDotsAnimation();
  }

  @override
  void dispose() {
    _dotsTimer?.cancel();
    super.dispose();
  }

  void _startDotsAnimation() {
    _dotsTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_isExporting) {
        setState(() {
          _loadingDots = (_loadingDots + 1) % 4;
        });
      }
    });
  }

  String get _loadingText {
    return 'Подготавливаем файл${'.' * _loadingDots}';
  }

  void _resetToInitialState() {
    setState(() {
      _isExporting = false;
      _isReadyToDownload = false;
      _pdfFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    const borderWindowColor = royalPurple;
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
          // Основное окно с кнопками
          if (!_isExporting) Center(
            child: Dialog(
              insetPadding: const EdgeInsets.all(30),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      upColorGradient,
                      downColorGradient.withOpacity(0.6),
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
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
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
                    if (!_isReadyToDownload) ...[
                      _buildButton(
                        icon: miniPenIcon,
                        text: 'Редактировать резюме',
                        onPressed: () {
                          widget.onClose();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ResumeViewPage(
                                resume: widget.resume,
                                onDelete: widget.onDelete,
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
                        onPressed: _exportResume,
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
                            await apiService.deleteResume(widget.resume['id'] as int);
                            widget.onDelete();
                            widget.onClose();
                          } catch (e) {
                            _showWarningDialog(context);
                          }
                        },
                        textStyle: textStyle,
                        borderColor: borderWindowColor,
                      ),
                    ] else ...[
                      SizedBox(
                        height: 180,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Резюме готово к скачиванию',
                              style: textStyle.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildButton(
                              icon: miniDownloadIcon,
                              text: 'Скачать PDF',
                              onPressed: () async {
                                if (_pdfFile != null) {
                                  PdfService.openFile(_pdfFile!);
                                  await AppMetrica.reportEvent(
                                    'login_success',
                                  );
                                }
                                widget.onClose();
                              },
                              textStyle: textStyle,
                              borderColor: borderWindowColor,
                            ),
                            const SizedBox(height: 10),
                            _buildButton(
                              icon: Icon(Icons.close),
                              text: 'Закрыть',
                              onPressed: _resetToInitialState,
                              textStyle: textStyle,
                              borderColor: borderWindowColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Полноэкранное белое окно подготовки (25% прозрачности)
          if (_isExporting) Container(
            color: Colors.white.withOpacity(0.25), // 25% прозрачности (75% непрозрачности)
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    _loadingText,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: midnightPurple,
                      fontFamily: 'Playfair'
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportResume() async {
    setState(() {
      _isExporting = true;
      _isReadyToDownload = false;
      _loadingDots = 0;
      _exportStartTime = DateTime.now();
    });

    try {
      final localResume = await getLocalResume(widget.resume['id'], context);
      final pdfFile = await PdfService.generateResumePdf(localResume);

      final elapsed = DateTime.now().difference(_exportStartTime!);
      if (elapsed < const Duration(seconds: 3)) {
        await Future.delayed(const Duration(seconds: 3) - elapsed);
      }

      setState(() {
        _isExporting = false;
        _isReadyToDownload = true;
        _pdfFile = pdfFile;
      });
    } catch (e) {
      setState(() {
        _isExporting = false;
      });
      _showWarningDialog(context);
    }
  }

  static Future<Map<String, dynamic>> getLocalResume(int resumeId, BuildContext context) async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final List<Map<String, dynamic>> allResumes = apiService.getLocalResumes();

      // Приводим ID к int для корректного сравнения
      final resume = allResumes.firstWhere(
            (r) => (r['id'] as num).toInt() == resumeId,  // <-- Важно!
        orElse: () => throw Exception('Резюме с ID $resumeId не найдено'),
      );

      if (resume.isEmpty) throw Exception('Резюме пустое');
      print(resume);
      return resume;
    } catch (e) {
      print('Ошибка в getLocalResume: $e');
      rethrow;
    }
  }

  void _showWarningDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => WarningDialog(),
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
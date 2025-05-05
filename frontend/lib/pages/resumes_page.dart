import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vkatun/design/images.dart';
import 'package:vkatun/design/dimensions.dart';
import 'package:vkatun/dialogs/error_dialog.dart';
import 'package:vkatun/pages/resume_view_page.dart';
import 'package:vkatun/windows/window_resumes_page.dart';
import 'package:vkatun/api_service.dart';

import '../account/account_main_page.dart';
import '../design/colors.dart';
import '../dialogs/warning_dialog.dart';
import '../windows/scan_windows/indicator.dart';

class ResumesPage extends StatefulWidget {
  const ResumesPage({super.key});

  @override
  State<StatefulWidget> createState() => _ResumesPageState();
}

class _ResumesPageState extends State<ResumesPage> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  bool _isDialogOpen = false;
  List<Map<String, dynamic>> _resumes = [];
  final List<Color> resumeCardColors = [
    babyBlue,
    lightLavender,
    lavenderMist,
    veryPalePink,
  ];

  Color _getColorByResumeId(int id) {
    return resumeCardColors[id % resumeCardColors.length];
  }

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: timeShowAnimation),
      upperBound: 0.125,
    );
    _loadResumes();
  }

  Future<void> _loadResumes() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final resumes = await apiService.getResumes();

      setState(() {
        _resumes = resumes;
        _resumes.sort((a, b) => (b['updated_at'] ?? b['created_at']).compareTo(a['updated_at'] ?? a['created_at']));
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки резюме: $e')),
      );
    }
  }

  Future<Map<String, dynamic>> _getResumeById(int id) async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      return await apiService.getResumeById(id);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки резюме: $e')),
      );
      return {};
    }
  }

  void _openDialog(int resumeId) async {
    final resume = await _getResumeById(resumeId);

    _rotationController.forward();
    setState(() {
      _isDialogOpen = true;
    });

    late OverlayEntry buttonOverlayEntry;

    buttonOverlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: bottom35,
        left: 0,
        right: 0,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: AnimatedBuilder(
              animation: _rotationController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationController.value * 2 * math.pi,
                  child: IconButton(
                    icon: addIcon,
                    onPressed: () {
                      buttonOverlayEntry.remove();
                      _closeDialog();
                    },
                    iconSize: 36,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(buttonOverlayEntry);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: white75,
      barrierLabel: 'Close',
      transitionDuration: const Duration(milliseconds: timeShowAnimation),
      transitionBuilder: (ctx, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, -1), end: const Offset(0, 0)).animate(anim1),
          child: child,
        );
      },
      pageBuilder: (ctx, anim1, anim2) {
        return WindowResumesPage(
          onClose: () {
            _closeDialog();
          },
          rotationController: _rotationController,
          resume: resume,
          onDelete: () {
            setState(() {
              _resumes.removeWhere((r) => r['id'] == resume['id']);
            });
          },
          // onSave: (updatedResume) async {
          //   await _updateResume(updatedResume);
          // },
        );
      },
    ).then((_) {
      if (buttonOverlayEntry.mounted) {
        buttonOverlayEntry.remove();
      }
      if (_isDialogOpen) {
        _closeDialog();
      }
    });
  }

  Future<void> _updateResume(Map<String, dynamic> updatedResume) async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final prefs = await SharedPreferences.getInstance();

      // Обновляем локально сразу
      final index = _resumes.indexWhere((r) => r['id'] == updatedResume['id']);
      if (index != -1) {
        setState(() {
          _resumes[index] = {
            ..._resumes[index],
            ...updatedResume,
            'updated_at': DateTime.now().toIso8601String(),
            'is_modified': true,
          };
        });

        // Сохраняем локально
        await prefs.setString('local_resumes', json.encode(_resumes));

        // Пытаемся синхронизировать с сервером
        if (apiService.authToken != 'guest_token') {
          await apiService.editResume(updatedResume['id'], updatedResume);
          // Если успешно, снимаем флаг изменения
          _resumes[index].remove('is_modified');
          await prefs.setString('local_resumes', json.encode(_resumes));
        }
      }
    } catch (e) {
      print('Ошибка при обновлении резюме: $e');
    }
  }

  void _closeDialog() {
    _rotationController.reverse();
    setState(() {
      _isDialogOpen = false;
    });
    Navigator.of(context).pop();
  }

  void _onAddIconPressed() {
    _pickPdfFile(context);
  }

  Future<void> _pickPdfFile(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;

        if (file.extension?.toLowerCase() == 'pdf') {
          await _uploadResume(File(file.path!));
        } else {
          _showWarningDialog(context);
        }
      }
    } catch (e) {
      _showWarningDialog(context);
    }
  }

  Future<void> _uploadResume(File file) async {
    // Показываем ваш кастомный индикатор загрузки
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: GradientCircularProgressIndicator(
          // Ваши параметры индикатора
          size: 70,
          strokeWidth: 5,
        ),
      ),
    );

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final serverResponse = await apiService.uploadResume(file);
      final resumeId = serverResponse['resume_id'];
      final resume = await _getResumeById(resumeId);

      // Закрываем индикатор
      Navigator.of(context).pop();

      // Обновляем список и переходим к просмотру
      setState(() => _resumes.insert(0, resume));

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResumeViewPage(
            resume: resume,
            onDelete: () => setState(() => _resumes.removeWhere((r) => r['id'] == resume['id'])),
            isLoadResume: true,
          ),
        ),
      );

    } catch (e) {
      // Закрываем индикатор
      _showWarningDialog(context);
    }
  }

  void _showWarningDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => WarningDialog(), // Ваш кастомный диалог
      barrierDismissible: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = screenHeight * 0.15;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: appBarHeight,
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15), // Отступ слева 30
                  child: IconButton(
                    icon: accountIcon,
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AccountMainPage())
                      );
                    },
                  ),
                ),
                Flexible(
                  child: Transform.translate(
                    offset: Offset(0, -appBarHeight * 0.09),
                    child: logoFullIcon,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 15), // Отступ справа 30
                  child: IconButton(
                    icon: parametersIcon,
                    onPressed: () {},
                  ),
                ),
              ],
            ),

            SizedBox(height: 8,),

            Row(
              mainAxisAlignment: MainAxisAlignment.center, // Центрируем всю строку
              crossAxisAlignment: CrossAxisAlignment.center, // Выравниваем по вертикали
              children: [
                SizedBox( // Левая линия (занимает всё доступное пространство слева)
                  width: MediaQuery.of(context).size.width * 0.05,
                  child: Divider(
                    thickness: 3,
                    color: lightLavender.withOpacity(0.5),
                    height: 1,
                  ),
                ),
                Padding( // Текст "Сегодня" с отступами
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'Сегодня',
                    style: TextStyle(
                      color: royalBlue, // Можно настроить цвет текста
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Playfair',
                      fontSize: 20,// Жирность
                    ),
                  ),
                ),
                Expanded( // Правая линия (занимает всё доступное пространство справа)
                  child: Divider(
                    thickness: 3,
                    color: lightLavender.withOpacity(0.5),
                    height: 1,
                  ),
                ),
              ],
            ),
          ],
        ),

        centerTitle: true,
        elevation: 0,
      ),

      body: _resumes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 32,
            childAspectRatio: 1.4,
          ),
          itemCount: _resumes.length,
          itemBuilder: (context, index) {
            // Определяем порядок отображения (зигзаг)
            final itemIndex = _getZigzagIndex(index, _resumes.length);
            final resume = _resumes[itemIndex];

            return GestureDetector(
              onTap: () async {
                // Показываем индикатор загрузки
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => Center(child: CircularProgressIndicator()),
                );

                try {
                  final loadedResume = await _getResumeById(resume['id']);
                  Navigator.pop(context); // Закрываем индикатор
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResumeViewPage(resume: loadedResume, onDelete: () {},),
                    ),
                  );
                } catch (e) {
                  Navigator.pop(context); // Закрываем индикатор
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ошибка загрузки резюме: $e')),
                  );
                }
              },
              onLongPress: () {
                // Долгое нажатие - открываем диалог как раньше
                _openDialog(resume['id']);
              },
              child: Card(
                color: _getColorByResumeId(resume['id']),
                elevation: 0,
                margin: EdgeInsets.zero, // Убираем внешние отступы карточки
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                  side: BorderSide(
                    color: royalPurple,
                    width: widthBorderRadius,
                  ),
                ),
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: 0, // Убираем минимальную высоту
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8, // Минимальные внутренние отступы
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: royalPurple,
                            width: widthBorderRadius,
                          ),
                          color: Colors.white,
                        ),
                        child: Text(
                          'Резюме',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Playfair',
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            color: royalPurple,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          resume['title'],
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Playfair',
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: royalPurple,
                          ),
                        ),
                      ),
                      if (resume['is_modified'] == true || resume['is_local'] == true)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Icon(
                            Icons.cloud_off,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),

      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: bottom35),
        child: AnimatedBuilder(
          animation: _rotationController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationController.value * 2 * math.pi,
              child: IconButton(
                icon: addIcon,
                onPressed: _onAddIconPressed,
                iconSize: 36,
              ),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  int _getZigzagIndex(int displayIndex, int totalItems) {
    final row = displayIndex ~/ 2;
    if (row % 2 == 0) {
      return displayIndex;
    } else {
      final start = row * 2;
      final end = math.min(start + 1, totalItems - 1);
      return end - (displayIndex - start);
    }
  }
}

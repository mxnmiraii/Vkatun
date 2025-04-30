import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:vkatun/design/dimensions.dart';
import 'package:vkatun/design/images.dart';
import 'package:vkatun/pages/resumes_page.dart';
import 'package:vkatun/windows/window_fix_mistakes.dart';

import '../design/colors.dart';

import 'package:vkatun/windows_edit_resume/about_me_page.dart';
import 'package:vkatun/windows_edit_resume/contact_info_page.dart';
import 'package:vkatun/windows_edit_resume/desired_position_page.dart';
import 'package:vkatun/windows_edit_resume/education_page.dart';
import 'package:vkatun/windows_edit_resume/full_name_page.dart';
import 'package:vkatun/windows_edit_resume/key_skills_page.dart';
import 'package:vkatun/windows_edit_resume/language_skills_page.dart';
import 'package:vkatun/windows_edit_resume/work_experience_page.dart';


class ResumeViewPage extends StatefulWidget {
  final Map<String, dynamic> resume;

  const ResumeViewPage({super.key, required this.resume});

  @override
  State<StatefulWidget> createState() => _ResumeViewPageState();
}

class _ResumeViewPageState extends State<ResumeViewPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  bool _isDialogOpen = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: timeShowAnimation),
      upperBound: 0.125, // 45 градусов (0.125 * 2 * pi)
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _openDialog() {
    _rotationController.forward();
    setState(() {
      _isDialogOpen = true;
    });

    late OverlayEntry buttonOverlayEntry;

    buttonOverlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
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
          position: Tween(
            begin: const Offset(0, -1),
            end: const Offset(0, 0),
          ).animate(anim1),
          child: child,
        );
      },
      pageBuilder: (ctx, anim1, anim2) {
        return WindowFixMistakes(
          onClose: () {
            // buttonOverlayEntry.remove();
            _closeDialog();
          },
          rotationController: _rotationController,
          resume: widget.resume,
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

  void _closeDialog() {
    _rotationController.reverse();
    setState(() {
      _isDialogOpen = false;
    });
    Navigator.of(context).pop();
  }

  void _onAddIconPressed() {
    //
  }

  @override
  Widget build(BuildContext context) {
    final _textStyle = TextStyle(
      color: midnightPurple,
      fontFamily: 'Playfair',
      // letterSpacing: -1.1,
      height: 1.0,
    );

    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = screenHeight * 0.15 / 2;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: veryPaleBlue,
        toolbarHeight: appBarHeight,
        automaticallyImplyLeading: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ResumesPage()),
                );
              },
              icon: backIconWBg,
            ),

            Text(
              'Резюме',
              style: _textStyle.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 24,
              ),
              textAlign: TextAlign.center,
            ),

            Opacity(opacity: 0, child: backIconWBg),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(buttonPaddingVertical),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ФИО
            _buildSection(
              title: 'ФИО',
              content: widget.resume['title'] ?? 'Не указано',
              hasCheck: true,
              targetPage: FullNamePage(
                  data: widget.resume['title'] == null || widget.resume['title'] == ''
                  ? ['', '', ''] : widget.resume['title'].split(' ')),
            ),

            // Желаемая должность
            _buildSection(
              title: 'Желаемая должность',
              content: widget.resume['job'] ?? 'Не указано',
              hasCheck: true,
              targetPage: const DesiredPositionPage(),
            ),

            // Контактные данные
            _buildSection(
              title: 'Контактные данные',
              content: widget.resume['contacts'] ?? 'Не указано',
              hasCheck: true,
              targetPage: const ContactInfoPage(),
            ),

            // Опыт работы
            _buildSection(
              title: 'Опыт работы',
              content: widget.resume['experience'] ?? 'Не указано',
              hasCheck: false,
            ),

            // Кнопка добавления опыта
            if (widget.resume['experience'] == null ||
                widget.resume['experience'].isEmpty)
              TextButton(
                onPressed: () {
                  // Добавление опыта работы
                },
                child: const Text('Добавить опыт работы'),
              ),

            // Образование
            _buildSection(
              title: 'Образование',
              content: widget.resume['education'] ?? 'Не указано',
              hasCheck: false,
            ),

            // Знание языков
            _buildSection(
              title: 'Знание языков',
              content: 'Русский — Родной\nАнглийский — B1',
              hasCheck: true,
            ),

            // Ключевые навыки
            _buildSection(
              title: 'Ключевые навыки',
              content: widget.resume['skills'] ?? 'Не указано',
              hasCheck: true,
            ),

            // О себе
            _buildSection(
              title: 'О себе',
              content: widget.resume['about'] ?? 'Не указано',
              hasCheck: false,
            ),
          ],
        ),
      ),

      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: bottom35),
        child: IconButton(
          icon: magicIcon,
          onPressed: () {
            _openDialog();
          },
          iconSize: 36, // Можно настроить размер иконки
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required bool hasCheck,
    Widget? targetPage,
    // сюда добавляешь еще одну переменную, которая отвечает за то на какое окно будет переходить
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'PlayFair',
                      color: Colors.black,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'PlayFair',
                      color: Colors.black,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 13),
                ],
              ),
            ),

            Expanded(
              flex: 1,
              child: IconButton(
                onPressed: targetPage != null
                    ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => targetPage),
                  );
                }
                    : null, // если targetPage не задан — кнопка будет неактивной
                icon: forwardIconWBg,
              ),
            ),
          ],
        ),

        const Divider(color: lightGray),
      ],
    );
  }
}

// IconButton(onPressed: () {}, icon: Transform.rotate(angle: math.pi, child: backIconWBg,)),

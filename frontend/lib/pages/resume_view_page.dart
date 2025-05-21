import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vkatun/design/dimensions.dart';
import 'package:vkatun/design/images.dart';
import 'package:vkatun/pages/resumes_page.dart';
import 'package:vkatun/windows/window_fix_mistakes.dart';

import '../api_service.dart';
import '../design/colors.dart';

import 'package:vkatun/windows_edit_resume/about_me_page.dart';
import 'package:vkatun/windows_edit_resume/contact_info_page.dart';
import 'package:vkatun/windows_edit_resume/desired_position_page.dart';
import 'package:vkatun/windows_edit_resume/education_page.dart';
import 'package:vkatun/windows_edit_resume/full_name_page.dart';
import 'package:vkatun/windows_edit_resume/key_skills_page.dart';
import 'package:vkatun/windows_edit_resume/work_experience_page.dart';

import '../dialogs/warning_dialog.dart';
import 'onboarding_content.dart';

class ResumeViewPage extends StatefulWidget {
  final Map<String, dynamic> resume;
  final bool isLoadResume;
  final VoidCallback onDelete;
  final bool isSecondBigStep;
  final bool showOnboarding;
  final VoidCallback? onCloseOnboarding;
  final GlobalKey? iconKey;

  const ResumeViewPage({
    super.key,
    required this.resume,
    required this.onDelete,
    this.isLoadResume = false,
    this.isSecondBigStep = false,
    this.showOnboarding = false,
    this.onCloseOnboarding,
    this.iconKey,
  });

  @override
  State<StatefulWidget> createState() => _ResumeViewPageState();
}

class _ResumeViewPageState extends State<ResumeViewPage>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  bool _isDialogOpen = false;
  final GlobalKey magicIconKey = GlobalKey();

  bool _isSecondStep = true;
  bool _isFourthStep = false;

  final GlobalKey forwardIconWBgKey = GlobalKey();

  late final _pulseCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );
  late final _pulseAnim = _pulseCtrl.drive(
    Tween(begin: 0.95, end: 1.05).chain(CurveTween(curve: Curves.easeInOut)),
  );

  late final _namePulseCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );
  late final _namePulseAnim = _namePulseCtrl.drive(
    Tween(begin: 0.95, end: 1.2).chain(CurveTween(curve: Curves.easeInOut)),
  );

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: timeShowAnimation),
      upperBound: 0.125, // 45 градусов (0.125 * 2 * pi)
    );
    widget.showOnboarding
        ? WidgetsBinding.instance.addPostFrameCallback((_) {
          _showFullScreenOnboarding(false, _isSecondStep, _isFourthStep);
        })
        : null;
  }

  void _switchOnboardingSteps() {
    setState(() {
      _isSecondStep = !_isSecondStep;
      _isFourthStep = !_isFourthStep;
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _namePulseCtrl.dispose();
    _pulseCtrl.dispose();
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

  void _showFullScreenOnboarding(bool isFirst, bool isSecond, bool isFourth) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.82),
      transitionDuration: const Duration(milliseconds: timeShowAnimation),
      pageBuilder: (context, _, __) {
        return OnboardingContent(
          hideOnboarding: () {
            Navigator.pop(context);
            if (_isSecondStep) {
              _namePulseCtrl.repeat(reverse: true);
            } else if (_isFourthStep) {
              _pulseCtrl.repeat(reverse: true);
            }
          },
          iconKey: isFourth ? widget.iconKey ?? GlobalKey() : forwardIconWBgKey,
          isFirstBigStep: isFirst,
          isSecondBigStep: isSecond,
          isFourthBigStep: isFourth,
        );
      },
    );
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
              onPressed:
                  widget.showOnboarding
                      ? null
                      : widget.isLoadResume
                      ? () async {
                        try {
                          final apiService = Provider.of<ApiService>(
                            context,
                            listen: false,
                          );
                          await apiService.deleteResume(
                            widget.resume['id'] as int,
                          );
                          widget.onDelete();

                          Navigator.pop(context);
                        } catch (e) {
                          _showWarningDialog(context);
                        }
                      }
                      : () {
                        Navigator.pop(context);
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

            IgnorePointer(
              ignoring: true,
              child: Opacity(
                opacity: 0,
                child: IconButton(
                  onPressed: () {},
                  icon: backIconWBg,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(buttonPaddingVertical),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ФИО с улучшенным отображением
            _buildSection(
              title: 'ФИО',
              content: widget.resume['title']?.trim() ?? 'Не указано',
              hasCheck: true,
              targetPage: FullNamePage(
                data:
                    widget.resume['title'] == null ||
                            widget.resume['title'].isEmpty
                        ? ['', '', '']
                        : widget.resume['title'].split(' '),
                showOnboarding: widget.showOnboarding,
                doneIconKey: widget.iconKey,
                onReturnFromOnboarding:
                    widget.showOnboarding
                        ? () {
                          _switchOnboardingSteps();
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _showFullScreenOnboarding(
                              false,
                              _isSecondStep,
                              _isFourthStep,
                            );
                          });
                        }
                        : null,
              ),
            ),

            // Желаемая должность с улучшенным форматированием
            _buildSection(
              title: 'Желаемая должность',
              content:
                  (widget.resume['job']?.trim() ?? 'Не указано').isNotEmpty
                      ? widget.resume['job']!.trim()
                      : 'Не указано',
              hasCheck: true,
              targetPage: DesiredPositionPage(
                data: [widget.resume['job']?.trim() ?? ''],
              ),
            ),

            // Контактные данные с красивым форматированием
            _buildSection(
              title: 'Контактные данные',
              content: _formatContacts(widget.resume['contacts']),
              hasCheck: true,
              targetPage: ContactInfoPage(
                data: _parseContacts(widget.resume['contacts'] ?? ''),
              ),
            ),

            // Опыт работы с улучшенным отображением
            _buildExperienceSection(),

            // Образование с лучшей структурой
            _buildSection(
              title: 'Образование',
              content: _formatEducation(widget.resume['education']),
              hasCheck: true,
              targetPage: EducationPage(
                data: _parseEducation(widget.resume['education']),
              ),
            ),

            // Ключевые навыки с лучшим форматированием
            _buildSection(
              title: 'Ключевые навыки',
              content: _formatSkills(widget.resume['skills']),
              hasCheck: true,
              targetPage: KeySkillsPage(data: widget.resume['skills'] ?? ''),
            ),

            // О себе с улучшенным отображением
            _buildSection(
              title: 'О себе',
              content: _formatAboutMe(widget.resume['about']),
              hasCheck: true,
              targetPage: AboutMePage(data: widget.resume['about'] ?? ''),
            ),
          ],
        ),
      ),

      floatingActionButton: widget.isLoadResume
          ? Padding(
        padding: EdgeInsets.only(bottom: bottom35),
        child: widget.showOnboarding && _isFourthStep
            ? ScaleTransition(
          scale: _pulseAnim,
          child: IconButton(
            onPressed: () {
              _pulseCtrl.stop();
              Navigator.pop(context, true);
            },
            icon: doneIcon,
          ),
        )
            : IconButton(
          onPressed: widget.showOnboarding
              ? _isFourthStep
              ? () {
            _pulseCtrl.stop();
            Navigator.pop(context, true);
          }
              : null
              : () {
            Navigator.pop(context, true);
          },
          icon: doneIcon,
        ),
      )
          : Padding(
        padding: EdgeInsets.only(bottom: bottom35),
        child: IconButton(
          key: magicIconKey,
          icon: magicIcon,
          onPressed: _openDialog,
          iconSize: 36,
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
              child: widget.showOnboarding && title.contains('ФИО') && _isSecondStep
                  ? ScaleTransition(
                scale: _namePulseAnim,
                child: IconButton(
                  key: forwardIconWBgKey,
                  onPressed: () {
                    _namePulseCtrl.stop();
                    if (targetPage != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => targetPage),
                      );
                    }
                  },
                  icon: forwardIconWBg,
                ),
              )
                  : IconButton(
                onPressed: targetPage != null
                    ? () {
                  if (!widget.showOnboarding ||
                      (title.contains('ФИО') && _isSecondStep)) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => targetPage),
                    );
                  }
                }
                    : null,
                icon: forwardIconWBg,
              ),
            ),
          ],
        ),

        const Divider(color: lightGray),
      ],
    );
  }

  void _showWarningDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => WarningDialog(), // Ваш кастомный диалог
      barrierDismissible: true,
    );
  }

  Widget _buildExperienceSection() {
    final hasExperience = widget.resume['experience']?.isNotEmpty == true;
    final experienceContent =
        hasExperience
            ? _parseExperienceShort(widget.resume['experience'])
            : 'Не указано';

    return Column(
      children: [
        _buildSection(
          title: 'Опыт работы',
          content: experienceContent,
          hasCheck: true,
          targetPage: WorkExperiencePage(
            data: _parseExperienceData(widget.resume['experience']),
          ),
        ),
        if (!hasExperience)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8),
            child: Text(
              'Добавить опыт работы',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w300,
                fontFamily: 'PlayFair',
                color: Colors.blue,
                height: 1.0,
              ),
            ),
          ),
      ],
    );
  }

  String _formatContacts(String? contacts) {
    if (contacts == null || contacts.trim().isEmpty) return 'Не указано';

    final parsed = _parseContacts(contacts);
    final phone = parsed[0];
    final email = parsed[1];

    return [
      if (phone.isNotEmpty) phone,
      if (email.isNotEmpty) email,
    ].join('\n');
  }

  String _formatSkills(String? skills) {
    if (skills == null || skills.trim().isEmpty) return 'Не указано';

    return skills
        .split('\n')
        .where((s) => s.trim().isNotEmpty)
        .map((s) => '• ${s.trim()}')
        .join('\n');
  }

  String _formatAboutMe(String? about) {
    if (about == null || about.trim().isEmpty) return 'Не указано';

    return about.split('\n').where((s) => s.trim().isNotEmpty).join('\n\n');
  }
}

// IconButton(onPressed: () {}, icon: Transform.rotate(angle: math.pi, child: backIconWBg,)),

List<String> _parseExperienceData(String? raw) {
  if (raw == null || raw.trim().isEmpty) return ['', '', '', '', '', 'false'];

  final lines =
      raw.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  String start = lines.isNotEmpty && _isDate(lines[0]) ? lines[0] : '';
  String end = lines.length > 1 && _isDate(lines[1]) ? lines[1] : '';
  int index = (start.isNotEmpty ? 1 : 0) + (end.isNotEmpty ? 1 : 0);

  final company = lines.length > index ? lines[index] : '';
  final position = lines.length > index + 1 ? lines[index + 1] : '';
  final duties = lines.length > index + 2 ? lines[index + 2] : '';
  final isCurrent = 'false'; // всегда по умолчанию false

  return [start, end, company, position, duties, isCurrent];
}

String _parseExperienceShort(String? raw) {
  final data = _parseExperienceData(raw);
  final start = data[0];
  final end = data[1];
  final company = data[2];
  final position = data[3];
  return '$company\n$position\n${start.isNotEmpty ? start : ''}${end.isNotEmpty ? ' — $end' : ' — настоящее время'}';
}

bool _isDate(String str) {
  final regex = RegExp(r'^\d{1,2}\.\d{1,2}\.\d{4}$');
  return regex.hasMatch(str);
}

List<String> _parseContacts(String contacts) {
  String phone = '';
  String email = '';

  // Парсим "сырой" телефон (только цифры)
  final phoneRegex = RegExp(
    r'(\+7|7|8)[\s\-]?[\(\s\-]?\d{3}[\)\s\-]?\s?\d{3}[\s\-]?\d{2}[\s\-]?\d{2}',
  );
  final phoneMatch = phoneRegex.firstMatch(contacts);
  if (phoneMatch != null) {
    String rawPhone = phoneMatch.group(0)!.replaceAll(RegExp(r'[^\d]'), '');

    // Приводим к формату +7...
    if (rawPhone.startsWith('8')) {
      rawPhone = '7${rawPhone.substring(1)}';
    } else if (!rawPhone.startsWith('7')) {
      rawPhone = '7$rawPhone';
    }

    // Форматируем в красивый вид
    phone = _formatPhone(rawPhone);
  }

  // Парсинг email (остаётся без изменений)
  final emailRegex = RegExp(r'[\w\.-]+@[\w\.-]+\.\w+');
  final emailMatch = emailRegex.firstMatch(contacts);
  if (emailMatch != null) {
    email = emailMatch.group(0)!;
  }

  return [phone, email];
}

String _formatPhone(String rawPhone) {
  if (rawPhone.length < 11) return rawPhone; // На всякий случай

  // +7 (XXX) XXX-XX-XX
  return '+7 (${rawPhone.substring(1, 4)}) ${rawPhone.substring(4, 7)}-${rawPhone.substring(7, 9)}-${rawPhone.substring(9)}';
}

String _formatEducation(String? raw) {
  if (raw == null || raw.trim().isEmpty) return 'Не указано';
  final lines =
      raw.split('\n').where((line) => line.trim().isNotEmpty).toList();

  String institution = lines.isNotEmpty ? lines[0] : '';
  String specialization = lines.length > 2 ? lines[2] : '';
  String degree = lines.length > 3 ? lines[3] : '';
  String year = lines.length > 4 ? _extractYear(lines[4]) : '';

  return [
    institution,
    specialization,
    degree,
    year,
  ].where((s) => s.trim().isNotEmpty).join(', ');
}

List<String> _parseEducation(String? raw) {
  if (raw == null || raw.trim().isEmpty) return List.filled(5, '');

  final lines = raw.split('\n').map((s) => s.trim()).toList();
  while (lines.length < 5) {
    lines.add('');
  }

  return [
    lines[0], // institution
    lines[1], // faculty
    lines[2], // specialization
    lines[4], // graduation year (original line — для контроллера будет парситься)
    lines[3], // degree
  ];
}

String _extractYear(String input) {
  final match = RegExp(r'\b(19|20)\d{2}\b').firstMatch(input);
  return match?.group(0) ?? '';
}

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
  final VoidCallback? onReturnFromOnboarding;
  final bool isSixthBigStep;

  const ResumeViewPage({
    super.key,
    required this.resume,
    required this.onDelete,
    this.isLoadResume = false,
    this.isSecondBigStep = false,
    this.showOnboarding = false,
    this.onCloseOnboarding,
    this.iconKey,
    this.onReturnFromOnboarding,
    this.isSixthBigStep = false,
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
  bool _showOverlay = true;

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

  void _hideOverlay() {
    setState(() => _showOverlay = false);
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

    if (_showOverlay) {
      Overlay.of(context).insert(buttonOverlayEntry);
    }

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
            _closeDialog();
          },
          rotationController: _rotationController,
          resume: widget.resume,
          showOnboarding: widget.showOnboarding,
          isSeventhBigStep: true,
          onResumeChange: _updateResumeData,
        );
      },
    ).then((result) {
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
        return widget.isSixthBigStep
            ? OnboardingContent(
              hideOnboarding: () {
                Navigator.pop(context);
                _pulseCtrl.repeat(reverse: true);
              },
              iconKey: widget.iconKey ?? GlobalKey(),
              isFirstBigStep: false,
              isSixthBigStep: true,
            )
            : OnboardingContent(
              hideOnboarding: () {
                Navigator.pop(context);
                if (_isSecondStep) {
                  _namePulseCtrl.repeat(reverse: true);
                } else if (_isFourthStep) {
                  _pulseCtrl.repeat(reverse: true);
                }
              },
              iconKey:
                  isFourth ? widget.iconKey ?? GlobalKey() : forwardIconWBgKey,
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
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.5),
        scrolledUnderElevation: 0, // Убираем тень при скролле
        surfaceTintColor: Colors.transparent,
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
                child: IconButton(onPressed: () {}, icon: backIconWBg),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(buttonPaddingVertical + 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [


            // ФИО с улучшенным отображением
            _buildSection(
              title: 'ФИО',
              content: _extractFullName(widget.resume['title']),
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
                resumeId: widget.resume['id'],
                onResumeChange: _updateResumeData,
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
            _buildEducationSection(),

            // Ключевые навыки с лучшим форматированием
            _buildSkillsSection(),

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

      floatingActionButton:
          widget.isLoadResume
              ? Padding(
                padding: EdgeInsets.only(bottom: bottom35),
                child:
                    widget.showOnboarding && _isFourthStep
                        ? ScaleTransition(
                          scale: _pulseAnim,
                          child: IconButton(
                            onPressed: () {
                              _pulseCtrl.stop();
                              Navigator.pop(context, true);
                              widget.onReturnFromOnboarding!();
                            },
                            icon: doneIcon,
                          ),
                        )
                        : IconButton(
                          onPressed:
                              widget.showOnboarding
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
                child:
                    widget.showOnboarding && widget.isSixthBigStep
                        ? ScaleTransition(
                          scale: _pulseAnim,
                          child: IconButton(
                            icon: magicIcon,
                            onPressed: () {
                              _pulseCtrl.stop();
                              _hideOverlay();
                              _openDialog();
                            },
                            iconSize: 36,
                          ),
                        )
                        : IconButton(
                          icon: magicIcon,
                          onPressed: _openDialog,
                          iconSize: 36,
                        ),
              ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Future<void> _updateResumeData() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);

      // Для гостей - только локальное хранилище
      if (apiService.isGuest) {
        final localResumes = apiService.getLocalResumes();
        final updatedResume = localResumes.firstWhere(
              (r) => r['id'] == widget.resume['id'],
          orElse: () => widget.resume,
        );

        if (mounted) {
          setState(() {
            widget.resume.clear();
            widget.resume.addAll(updatedResume);
          });
        }
        return;
      }

      // Для авторизованных пользователей - пробуем обновить с сервера,
      // но при ошибке используем локальные данные
      try {
        final updatedResume = await apiService.getResumeById(widget.resume['id'] as int);
        if (mounted) {
          setState(() {
            widget.resume.clear();
            widget.resume.addAll(updatedResume);
          });
        }
      } catch (e) {
        // Если ошибка сервера - используем локальные данные
        final localResumes = apiService.getLocalResumes();
        final updatedResume = localResumes.firstWhere(
              (r) => r['id'] == widget.resume['id'],
          orElse: () => widget.resume,
        );

        if (mounted) {
          setState(() {
            widget.resume.clear();
            widget.resume.addAll(updatedResume);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось обновить резюме: ${e.toString()}')),
        );
      }
    }
  }


  String _extractFullName(String? raw) {
    if (raw == null || raw.trim().isEmpty) return 'Не указано';

    final parts = raw.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return parts.take(3).join(' ');
    } else {
      return raw.trim();
    }
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
                  const SizedBox(height: 16),
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'NotoSans',
                      color: Colors.black,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

            Expanded(
              flex: 1,
              child:
                  widget.showOnboarding &&
                          title.contains('ФИО') &&
                          _isSecondStep
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
                        onPressed:
                            targetPage != null
                                ? () {
                                  if (!widget.showOnboarding ||
                                      (title.contains('ФИО') &&
                                          _isSecondStep)) { // тут с условием хуйня с 6 шагом
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => targetPage,
                                      ),
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
    final experienceData = _parseExperience(widget.resume['experience'] ?? '');
    final totalExperience = _calculateTotalExperience(experienceData);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок с общим стажем
        Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Опыт работы${totalExperience.isNotEmpty ? ' • $totalExperience' : ''}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'PlayFair',
                    color: Colors.black,
                    height: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Карточки опыта работы
        if (experienceData.isNotEmpty)
          ...experienceData.map((exp) => _buildExperienceCard(exp)).toList(),

        // Кнопка добавления
        Padding(
          padding: const EdgeInsets.only(left: 0, top: 0, bottom: 0),
          child: TextButton.icon(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                  builder: (_) => WorkExperiencePage(data: List.filled(6, '')),
              ));
            },
            icon: addIconCircle,
            label: Text(
              'Добавить опыт работы',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w300,
                fontFamily: 'NotoSans',
                color: midnightPurple,
                height: 1.0,
              ),
            ),
          ),
        ),

        const Divider(color: lightGray),
      ],
    );
  }

  Widget _buildExperienceCard(Map<String, String> experience) {
    final company = experience['company'] ?? '';
    final position = experience['position'] ?? '';
    final period = _formatPeriod(experience['startDate'], experience['endDate']);
    final duration = _calculateDuration(experience['startDate'], experience['endDate']);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // Always show all 4 lines, even if some fields are empty
                  Text(
                    company.isNotEmpty ? company : 'Название компании',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'NotoSans',
                      color: company.isNotEmpty ? Colors.black : mediumGray,
                      height: 1.0,
                      fontStyle: company.isEmpty ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    position.isNotEmpty ? position : 'Название должности',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'NotoSans',
                      color: position.isNotEmpty ? Colors.black : mediumGray,
                      height: 1.0,
                      fontStyle: position.isEmpty ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    period.isNotEmpty ? period : 'Период работы не указан',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'NotoSans',
                      color: period.isNotEmpty ? mediumGray : lightGray,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    duration.isNotEmpty ? duration : 'Срок не указан',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'NotoSans',
                      color: duration.isNotEmpty ? mediumGray : lightGray,
                      height: 1.0,
                    ),
                  ),
                  SizedBox(height: 10,),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WorkExperiencePage(
                        data: [
                          experience['startDate'] ?? '',
                          experience['endDate'] ?? '',
                          experience['company'] ?? '',
                          experience['position'] ?? '',
                          experience['duties'] ?? '',
                          (experience['isCurrent'] ?? 'false') == 'true' ? 'true' : 'false',
                        ],
                      ),
                    ),
                  );
                },
                icon: forwardIconWBg,
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Map<String, String>> _parseExperience(String raw) {
    if (raw.trim().isEmpty) return [];

    final List<Map<String, String>> result = [];
    final entries = raw.split('\n\n'); // Разделяем по пустым строкам

    for (var entry in entries) {
      final lines = entry.split('\n').where((line) => line.trim().isNotEmpty).toList();
      if (lines.isEmpty) continue;

      final experience = <String, String>{};

      // Парсим даты (первые две строки могут быть датами)
      int index = 0;
      if (lines.length > index && _isDate(lines[index])) {
        experience['startDate'] = lines[index];
        index++;
      }
      if (lines.length > index && _isDate(lines[index])) {
        experience['endDate'] = lines[index];
        index++;
      } else if (index > 0) {
        experience['endDate'] = '';
        experience['isCurrent'] = 'true';
      }

      // Остальные данные
      if (lines.length > index) experience['company'] = lines[index++];
      if (lines.length > index) experience['position'] = lines[index++];
      if (lines.length > index) experience['duties'] = lines.skip(index).join('\n');

      result.add(experience);
    }

    return result;
  }

  String _calculateTotalExperience(List<Map<String, String>> experiences) {
    if (experiences.isEmpty) return '';

    int totalMonths = 0;
    final now = DateTime.now();

    for (var exp in experiences) {
      final startDate = _parseDate(exp['startDate'] ?? '');
      if (startDate == null) continue;

      DateTime? endDate;
      if (exp['isCurrent'] == 'true') {
        endDate = now;
      } else {
        endDate = _parseDate(exp['endDate'] ?? '');
      }

      if (endDate == null) continue;

      final months = (endDate.year - startDate.year) * 12 + endDate.month - startDate.month;
      totalMonths += months;
    }

    if (totalMonths == 0) return '';

    final years = totalMonths ~/ 12;
    final months = totalMonths % 12;

    if (years > 0 && months > 0) {
      return '$years ${_getYearWord(years)} $months ${_getMonthWord(months)}';
    } else if (years > 0) {
      return '$years ${_getYearWord(years)}';
    } else {
      return '$months ${_getMonthWord(months)}';
    }
  }

  String _formatPeriod(String? start, String? end) {
    if (start == null || start.isEmpty) return '';

    final startDate = _parseDate(start);
    if (startDate == null) return '';

    final formattedStart = '${_getMonthName(startDate.month)} ${startDate.year}';

    if (end == null || end.isEmpty) {
      return 'с $formattedStart по настоящее время';
    }

    final endDate = _parseDate(end);
    if (endDate == null) return 'с $formattedStart';

    return 'с $formattedStart по ${_getMonthName(endDate.month)} ${endDate.year}';
  }

  String _calculateDuration(String? start, String? end) {
    if (start == null || start.isEmpty) return '';

    final startDate = _parseDate(start);
    if (startDate == null) return '';

    final endDate = end?.isEmpty ?? true ? DateTime.now() : _parseDate(end!);
    if (endDate == null) return '';

    final months = (endDate.year - startDate.year) * 12 + endDate.month - startDate.month;
    if (months <= 0) return '';

    final years = months ~/ 12;
    final remainingMonths = months % 12;

    if (years > 0 && remainingMonths > 0) {
      return '$years ${_getYearWord(years)} $remainingMonths ${_getMonthWord(remainingMonths)}';
    } else if (years > 0) {
      return '$years ${_getYearWord(years)}';
    } else {
      return '$remainingMonths ${_getMonthWord(remainingMonths)}';
    }
  }

  DateTime? _parseDate(String dateStr) {
    final parts = dateStr.split('.');
    if (parts.length != 3) return null;

    try {
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
      'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'
    ];
    return months[month - 1];
  }

  String _getYearWord(int years) {
    if (years % 100 >= 11 && years % 100 <= 14) return 'лет';

    switch (years % 10) {
      case 1: return 'год';
      case 2:
      case 3:
      case 4: return 'года';
      default: return 'лет';
    }
  }

  String _getMonthWord(int months) {
    if (months % 100 >= 11 && months % 100 <= 14) return 'месяцев';

    switch (months % 10) {
      case 1: return 'месяц';
      case 2:
      case 3:
      case 4: return 'месяца';
      default: return 'месяцев';
    }
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

  Widget _buildSkillsSection() {
    final rawSkills = widget.resume['skills'];
    final skills = _parseSkills(rawSkills);

    return Column(
      children: [
        const Divider(color: lightGray), // верхняя линия
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    'Ключевые навыки',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'PlayFair',
                      color: Colors.black,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (skills.isEmpty)
                    Text(
                      'Не указано',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        fontFamily: 'NotoSans',
                        color: Colors.black,
                        height: 1.0,
                      ),
                    )
                  else
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: skills
                          .map((s) => Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                          color: lightGray,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          s,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'NotoSans',
                            height: 1.0,
                          ),
                        ),
                      ))
                          .toList(),
                    ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          KeySkillsPage(data: rawSkills ?? ''),
                    ),
                  );
                },
                icon: forwardIconWBg,
              ),
            ),
          ],
        ),
        const Divider(color: lightGray), // нижняя линия
      ],
    );
  }



  List<String> _parseSkills(String? raw) {
    if (raw == null || raw.trim().isEmpty) return [];

    final List<String> skills = [];

    final lines = raw.split('\n');

    for (var line in lines) {
      var trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue;

      final lower = trimmedLine.toLowerCase();

      // Игнорируем заголовки или вводные фразы
      if (lower.startsWith('ключевые навыки') ||
          lower.startsWith('языки:') ||
          lower.startsWith('знание языков') ||
          lower.startsWith('навыки')) {
        continue;
      }

      // Разделяем по запятой или точке с запятой
      if (trimmedLine.contains(',') || trimmedLine.contains(';')) {
        skills.addAll(trimmedLine
            .split(RegExp(r'[;,]'))
            .map((e) => e.trim().replaceAll(RegExp(r'\.$'), '')) // удаление точки на конце
            .where((e) => e.isNotEmpty));
      } else {
        // Один навык без разделителей
        skills.add(trimmedLine.replaceAll(RegExp(r'\.$'), ''));
      }
    }

    return skills;
  }




  String _formatAboutMe(String? about) {
    if (about == null || about.trim().isEmpty) return 'Не указано';

    return about.split('\n').where((s) => s.trim().isNotEmpty).join('\n\n');
  }

  Widget _buildEducationSection() {
    final educationData = _parseEducation(widget.resume['education'] ?? '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок
        Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 16),
          child: Text(
            'Образование',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              fontFamily: 'PlayFair',
              color: Colors.black,
              height: 1.0,
            ),
          ),
        ),

        // Карточки образования
        if (educationData.isNotEmpty)
          ...educationData.map((edu) => _buildEducationCard(edu)).toList(),

        // Кнопка добавления
        Padding(
          padding: const EdgeInsets.only(left: 0, top: 0, bottom: 0),
          child: TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EducationPage(data: List.filled(5, '')),
                ),
              );
            },
            icon: addIconCircle,
            label: Text(
              'Добавить учебное заведение',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w300,
                fontFamily: 'NotoSans',
                color: midnightPurple,
                height: 1.0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEducationCard(List<String> education) {
    final institution = education.length > 0 ? education[0] : '';
    final specialization = education.length > 1 ? education[1] : '';
    final yearsRaw = education.length > 2 ? education[2] : '';

    // Парсим год окончания
    String formattedYears = 'Годы обучения не указаны';
    final yearMatches = RegExp(r'\b(19|20)\d{2}\b')
        .allMatches(yearsRaw)
        .map((m) => int.tryParse(m.group(0)!))
        .whereType<int>()
        .toList();

    if (yearMatches.length >= 2) {
      yearMatches.sort();
      formattedYears = '${yearMatches.first}–${yearMatches.last}';
    } else if (yearMatches.length == 1) {
      final end = yearMatches.first;
      final start = end - 4;
      formattedYears = '$start–$end';
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // Название ВУЗа
                  Text(
                    institution.isNotEmpty ? institution : 'Название учебного заведения',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'NotoSans',
                      color: Colors.black,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Специализация
                  Text(
                    specialization.isNotEmpty ? specialization : 'Специализация не указана',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'NotoSans',
                      color: Colors.black,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Годы обучения
                  Text(
                    formattedYears,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'NotoSans',
                      color: Colors.black,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),

            // Кнопка перехода к редактированию
            Expanded(
              flex: 1,
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EducationPage(data: education),
                    ),
                  );
                },

                icon: forwardIconWBg,
              ),
            ),
          ],
        ),
      ],
    );
  }


  List<List<String>> _parseEducation(String raw) {
    if (raw.trim().isEmpty) return [];

    final result = <List<String>>[];

    final entries = raw
        .split(RegExp(r'(\n{2,}|;+|\|{2,})'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    for (final entry in entries) {
      print('\n=== Новый блок ===');
      print(entry);

      final lines = entry
          .split(RegExp(r'[\n;|,]+'))
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();

      print('→ Все строки внутри блока:');
      for (var i = 0; i < lines.length; i++) {
        print('  [$i]: ${lines[i]}');
      }

      String? institution;
      String? specialization;
      final years = <int>[];

      for (final line in lines) {
        final lower = line.toLowerCase();

        // Годы
        final yearMatches = RegExp(r'\b(19|20)\d{2}\b').allMatches(line);
        for (final match in yearMatches) {
          years.add(int.parse(match.group(0)!));
        }

        // ВУЗ
        if (institution == null &&
            RegExp(r'(университет|институт|академ|колледж)').hasMatch(lower)) {
          institution = _cleanInstitution(line);
          continue;
        }

        // Специализация — без цифр и без упоминания вуза или города
        if (specialization == null &&
            !RegExp(r'\d').hasMatch(line) &&
            !RegExp(r'(университет|институт|академ|колледж|петербург|москва|новосибирск|россия)').hasMatch(lower)) {
          specialization = line;
          continue;
        }
      }

      // Формат годов
      String yearsFormatted = 'Не указано';
      if (years.length >= 2) {
        years.sort();
        yearsFormatted = '${years.first}–${years.last}';
      } else if (years.length == 1) {
        final end = years.first;
        final start = end - 4;
        yearsFormatted = '$start–$end';
      }

      result.add([
        institution ?? 'Не указано',
        specialization ?? 'Не указано',
        yearsFormatted,
      ]);
    }

    return result;
  }
  String _cleanInstitution(String raw) {
    return raw
        .replaceAll(RegExp(r'образование', caseSensitive: false), '')
        .replaceAll(RegExp(r'высшее', caseSensitive: false), '')
        .replaceAll(RegExp(r'среднее', caseSensitive: false), '')
        .replaceAll(RegExp(r'незаконченное', caseSensitive: false), '')
        .replaceAll(RegExp(r'(19|20)\d{2}'), '')
        .replaceAll(RegExp(r'[^а-яА-ЯёЁa-zA-Z0-9 ,\.\-()]'), '')
        .trim();
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

// List<String> _parseEducation(String? raw) {
//   if (raw == null || raw.trim().isEmpty) return List.filled(5, '');
//
//   final lines = raw.split('\n').map((s) => s.trim()).toList();
//   while (lines.length < 5) {
//     lines.add('');
//   }
//
//   return [
//     lines[0], // institution
//     lines[1], // faculty
//     lines[2], // specialization
//     lines[4], // graduation year (original line — для контроллера будет парситься)
//     lines[3], // degree
//   ];
// }

String _extractYear(String input) {
  final match = RegExp(r'\b(19|20)\d{2}\b').firstMatch(input);
  return match?.group(0) ?? '';
}


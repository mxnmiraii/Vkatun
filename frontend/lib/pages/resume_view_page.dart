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
  final ValueChanged<Map<String, dynamic>> onUpdateResumeChange;

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
    required this.onUpdateResumeChange,
  });

  @override
  State<StatefulWidget> createState() => _ResumeViewPageState();
}

class _ResumeViewPageState extends State<ResumeViewPage>
    with TickerProviderStateMixin {

  String? experienceSummary;

  late AnimationController _rotationController;
  bool _isDialogOpen = false;
  final GlobalKey magicIconKey = GlobalKey();

  bool _isSecondStep = true;
  bool _isFourthStep = false;
  bool _showOverlay = true;
  bool _hasResumeChanged = false;

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


    // Здесь он ищет по первой строчке слово опыт работы и обрабатывает
    final expRaw = widget.resume['experience'];
    if (expRaw != null && expRaw.toString().trim().isNotEmpty) {
      final firstLine = expRaw.toString().trim().split('\n').firstWhere(
            (line) => line.toLowerCase().startsWith('опыт работы'),
        orElse: () => '',
      );
      final match = RegExp(r'[-—–]?\s*(.+)$').firstMatch(firstLine);
      if (match != null) {
        experienceSummary = match.group(1)?.trim();
      }
    }
    //

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
          onResumeChange: () {
            _updateResumeData();
            setState(() {
              _hasResumeChanged = true;
            });
          },
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
                        if (_hasResumeChanged) {
                          widget.onUpdateResumeChange(widget.resume);
                        }
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
                onResumeChange: () {
                  _updateResumeData();
                  setState(() {
                    _hasResumeChanged = true;
                  });
                },
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
                resumeId: widget.resume['id'],
                onResumeChange: () {
                  _updateResumeData();
                  setState(() {
                    _hasResumeChanged = true;
                  });
                },
              ),
            ),

            // Контактные данные с красивым форматированием
            _buildSection(
              title: 'Контактные данные',
              contentWidget: _buildContactsRichText(widget.resume['contacts']),
              hasCheck: true,
              targetPage: ContactInfoPage(
                data: _parseContacts(widget.resume['contacts'] ?? ''),
                resumeId: widget.resume['id'],
                onResumeChange: () {
                  _updateResumeData();
                  setState(() {
                    _hasResumeChanged = true;
                  });
                },
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
              targetPage: AboutMePage(
                data: widget.resume['about'] ?? '',
                resumeId: widget.resume['id'],
                onResumeChange: () {
                  _updateResumeData();
                  setState(() {
                    _hasResumeChanged = true;
                  });
                },
              ),
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

      // Получаем актуальные данные из локального хранилища
      final localResumes = apiService.getLocalResumes();
      final index = localResumes.indexWhere((r) => r['id'] == widget.resume['id']);

      if (index != -1) {
        // Сохраняем изменения в виджете
        if (mounted) {
          setState(() {
            widget.resume.clear();
            widget.resume.addAll(localResumes[index]);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось обновить данные: ${e.toString()}')),
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
    // required String content,
    String? content,
    Widget? contentWidget,

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
                  contentWidget ??
                      Text(
                        content ?? 'Не указано',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          fontFamily: 'NotoSansVariable',
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
                                          _isSecondStep)) {
                                    // тут с условием хуйня с 6 шагом
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
    // final totalExperience = _calculateTotalExperience(experienceData);

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
                  experienceSummary != null
                      ? '$experienceSummary'
                      : 'Опыт работы',
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
            onPressed:
                widget.showOnboarding
                    ? () {}
                    : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) =>
                                  WorkExperiencePage(data: List.filled(6, '')),
                        ),
                      );
                    },
            icon: addIconCircle,
            label: Text(
              'Добавить опыт работы',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w300,
                fontFamily: 'NotoSansBengali',
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

  Widget _buildContactsRichText(String? contacts) {
    if (contacts == null || contacts.trim().isEmpty) {
      return const Text('Не указано');
    }

    final parsed = _parseContacts(contacts);
    final phone = parsed[0];
    final email = parsed[1];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (phone.isNotEmpty)
          Text(
            '· Телефон: $phone',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w300,
              fontFamily: 'NotoSansVariable',
              color: Colors.black,
              height: 1.0,
            ),
          ),
        if (phone.isNotEmpty && email.isNotEmpty)
          const SizedBox(height: 4), // ← вот тут интервал между ними
        if (email.isNotEmpty)
          RichText(
            text: TextSpan(
              text: '· Email: ',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w300,
                fontFamily: 'NotoSansVariable',
                color: Colors.black,
                height: 1.0,
              ),
              children: [
                TextSpan(
                  text: email,
                  style: const TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }



  Widget _buildExperienceCard(Map<String, String> experience) {
    final company = experience['company'] ?? '';
    final position = experience['position'] ?? '';
    // final period = _formatPeriod(experience['startDate'], experience['endDate']);
    // final duration = _calculateDuration(experience['startDate'], experience['endDate']);
    final period = experience['period'] ?? '';
    final duration = experience['duration'] ?? '';

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

                  Text(
                    company.isNotEmpty ? company : 'Название компании',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'NotoSansBengali',
                      color: company.isNotEmpty ? Colors.black : mediumGray,
                      height: 1.0,
                      fontStyle:
                          company.isEmpty ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                  const SizedBox(height: 4),

                  Text(
                    position.isNotEmpty ? position : 'Название должности',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'NotoSansBengali',
                      color: position.isNotEmpty ? Colors.black : mediumGray,
                      height: 1.0,
                      fontStyle:
                          position.isEmpty
                              ? FontStyle.italic
                              : FontStyle.normal,
                    ),
                  ),
                  const SizedBox(height: 4),

                  Text(
                    period.isNotEmpty ? period : 'Период работы не указан',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'NotoSansBengali',
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
                      fontFamily: 'NotoSansBengali',
                      color: duration.isNotEmpty ? mediumGray : lightGray,
                      height: 1.0,
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: IconButton(
                onPressed:
                    widget.showOnboarding
                        ? () {}
                        : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => WorkExperiencePage(
                                    data: [
                                      experience['startDate'] ?? '',
                                      experience['endDate'] ?? '',
                                      experience['company'] ?? '',
                                      experience['position'] ?? '',
                                      experience['duties'] ?? '',
                                      (experience['endDate']
                                                  ?.toLowerCase()
                                                  .contains('настоящее') ??
                                              false)
                                          .toString(),
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
    final lines = raw.split('\n').map((e) => e.trim()).toList();

    final List<Map<String, String>> result = [];
    final dateRegex = RegExp(
      r'^[А-Яа-я]+\s\d{4}\s[—-]\s(настоящее время|[А-Яа-я]+\s\d{4})$',
    );
    final durationRegex = RegExp(
      r'^\d+\s(год|года|лет|\d+\sмесяц|месяца|месяцев)$',
    );
    final skipMetaRegex = RegExp(
      r'(Санкт-Петербург|\.ru|интеграция|интернет|технологии|отрасль)',
      caseSensitive: false,
    );

    Map<String, String> current = {};
    List<String> dutiesBuffer = [];
    int i = 0;

    while (i < lines.length) {
      final line = lines[i];

      // Начало нового блока
      if (dateRegex.hasMatch(line)) {
        if (current.isNotEmpty && (current['company']?.isNotEmpty ?? false)) {
          current['duties'] = dutiesBuffer.join('\n').trim();
          result.add(current);
          current = {};
          dutiesBuffer = [];
        }

        final parts = line.split(RegExp(r'\s[—-]\s'));
        current['startDate'] = parts[0];
        current['endDate'] = parts[1];
        current['period'] = line;
        i++;
        continue;
      }

      // Пропустить строку с длительностью
      if (durationRegex.hasMatch(line) ||
          RegExp(r'\d+\sгод.*').hasMatch(line)) {
        current['duration'] = line;
        i++;
        continue;
      }

      // Название компании
      if (current['company'] == null && line.isNotEmpty) {
        current['company'] = line;
        i++;
        continue;
      }

      // Пропустить мета-описание (город, сайт, отрасль)
      if (skipMetaRegex.hasMatch(line)) {
        i++;
        continue;
      }

      // Должность — пропускаем строки, начинающиеся с маркера "•"
      if (current['position'] == null &&
          line.isNotEmpty &&
          !line.startsWith('•')) {
        current['position'] = line;
        i++;
        continue;
      } else if (current['position'] == null && line.startsWith('•')) {
        // если сразу пошли обязанности — оставим должность пустой, но начнем копить duties
        dutiesBuffer.add(line);
        i++;
        continue;
      }

      // Остальное — обязанности
      dutiesBuffer.add(line);
      i++;
    }

    if (current.isNotEmpty) {
      current['duties'] = dutiesBuffer.join('\n').trim();
      result.add(current);
    }

    return result;
  }

  // String _calculateTotalExperience(List<Map<String, String>> experiences) {
  //   if (experiences.isEmpty) return '';
  //
  //   int totalMonths = 0;
  //   final now = DateTime.now();
  //
  //   for (var exp in experiences) {
  //     final startDate = _parseDate(exp['startDate'] ?? '');
  //     if (startDate == null) continue;
  //
  //     DateTime? endDate;
  //     if (exp['isCurrent'] == 'true') {
  //       endDate = now;
  //     } else {
  //       endDate = _parseDate(exp['endDate'] ?? '');
  //     }
  //
  //     if (endDate == null) continue;
  //
  //     final months = (endDate.year - startDate.year) * 12 + endDate.month - startDate.month;
  //     totalMonths += months;
  //   }
  //
  //   if (totalMonths == 0) return '';
  //
  //   final years = totalMonths ~/ 12;
  //   final months = totalMonths % 12;
  //
  //   if (years > 0 && months > 0) {
  //     return '$years ${_getYearWord(years)} $months ${_getMonthWord(months)}';
  //   } else if (years > 0) {
  //     return '$years ${_getYearWord(years)}';
  //   } else {
  //     return '$months ${_getMonthWord(months)}';
  //   }
  // }

  // String _formatPeriod(String? start, String? end) {
  //   if (start == null || start.isEmpty) return '';
  //
  //   final startDate = _parseDate(start);
  //   if (startDate == null) return '';
  //
  //   final formattedStart = '${_getMonthName(startDate.month)} ${startDate.year}';
  //
  //   if (end == null || end.isEmpty) {
  //     return 'с $formattedStart по настоящее время';
  //   }
  //
  //   final endDate = _parseDate(end);
  //   if (endDate == null) return 'с $formattedStart';
  //
  //   return 'с $formattedStart по ${_getMonthName(endDate.month)} ${endDate.year}';
  // }
  String _formatPeriod(String? start, String? end) {
    if (start == null || start.isEmpty) return '';
    if (end == null || end.isEmpty || end.toLowerCase().contains('настоящее')) {
      return 'с $start по настоящее время';
    }
    return 'с $start по $end';
  }

  // String _calculateDuration(String? start, String? end) {
  //   if (start == null || start.isEmpty) return '';
  //
  //   final startDate = _parseDate(start);
  //   if (startDate == null) return '';
  //
  //   final endDate = end?.isEmpty ?? true ? DateTime.now() : _parseDate(end!);
  //   if (endDate == null) return '';
  //
  //   final months = (endDate.year - startDate.year) * 12 + endDate.month - startDate.month;
  //   if (months <= 0) return '';
  //
  //   final years = months ~/ 12;
  //   final remainingMonths = months % 12;
  //
  //   if (years > 0 && remainingMonths > 0) {
  //     return '$years ${_getYearWord(years)} $remainingMonths ${_getMonthWord(remainingMonths)}';
  //   } else if (years > 0) {
  //     return '$years ${_getYearWord(years)}';
  //   } else {
  //     return '$remainingMonths ${_getMonthWord(remainingMonths)}';
  //   }
  // }

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
      'Январь',
      'Февраль',
      'Март',
      'Апрель',
      'Май',
      'Июнь',
      'Июль',
      'Август',
      'Сентябрь',
      'Октябрь',
      'Ноябрь',
      'Декабрь',
    ];
    return months[month - 1];
  }

  // String _getYearWord(int years) {
  //   if (years % 100 >= 11 && years % 100 <= 14) return 'лет';
  //
  //   switch (years % 10) {
  //     case 1: return 'год';
  //     case 2:
  //     case 3:
  //     case 4: return 'года';
  //     default: return 'лет';
  //   }
  // }

  // String _getMonthWord(int months) {
  //   if (months % 100 >= 11 && months % 100 <= 14) return 'месяцев';
  //
  //   switch (months % 10) {
  //     case 1: return 'месяц';
  //     case 2:
  //     case 3:
  //     case 4: return 'месяца';
  //     default: return 'месяцев';
  //   }
  // }

  String _formatContacts(String? contacts) {
    if (contacts == null || contacts.trim().isEmpty) return 'Не указано';

    final parsed = _parseContacts(contacts);
    final phone = parsed[0];
    final email = parsed[1];

    final List<String> parts = [];

    if (phone.isNotEmpty) {
      parts.add('· Телефон: $phone');
    }

    if (email.isNotEmpty) {
      parts.add('· Email: $email');
    }

    return parts.join('\n');
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
                        fontFamily: 'NotoSansBengali',
                        color: Colors.black,
                        height: 1.0,
                      ),
                    )
                  else
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children:
                          skills
                              .map(
                                (s) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: lightGray,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    s,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'NotoSansBengali',
                                      height: 1.0,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: IconButton(
                onPressed:
                    widget.showOnboarding
                        ? () {}
                        : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => KeySkillsPage(
                                    data: rawSkills ?? '',
                                    resumeId: widget.resume['id'],
                                    onResumeChange: () {
                                      _updateResumeData();
                                      setState(() {
                                        _hasResumeChanged = true;
                                      });
                                    },
                                  ),
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

      // Заменяем 3+ пробела на запятую
      trimmedLine = trimmedLine.replaceAll(RegExp(r'\s{3,}'), ',');

      // Разделяем по запятой или точке с запятой
      if (trimmedLine.contains(',') || trimmedLine.contains(';')) {
        skills.addAll(
          trimmedLine
              .split(RegExp(r'[;,]'))
              .map((e) => e.trim().replaceAll(RegExp(r'\.$'), ''))
              .where((e) => e.isNotEmpty),
        );
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
            onPressed:
                widget.showOnboarding
                    ? () {}
                    : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EducationPage(
                            data: List.filled(3, ''),
                            resumeId: widget.resume['id'],
                            onResumeChange: _updateResumeData,
                          ),
                        ),
                      );
                    },
            icon: addIconCircle,
            label: Text(
              'Добавить учебное заведение',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w300,
                fontFamily: 'NotoSansBengali',
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
    final years = education.length > 2 ? education[2] : '';

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
                  Text(
                    institution.isNotEmpty
                        ? institution
                        : 'Название учебного заведения',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'NotoSansBengali',
                      color: institution.isNotEmpty ? Colors.black : mediumGray,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    specialization.isNotEmpty
                        ? specialization
                        : 'Специализация не указана',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'NotoSansBengali',
                      color:
                          specialization.isNotEmpty ? Colors.black : mediumGray,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    years.isNotEmpty ? years : 'Годы обучения не указаны',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'NotoSansBengali',
                      color: years.isNotEmpty ? Colors.black : mediumGray,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: IconButton(
                onPressed:
                    widget.showOnboarding
                        ? () {}
                        : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EducationPage(
                                data: education.isEmpty ? List.filled(3, '') : education,
                                resumeId: widget.resume['id'],
                                onResumeChange: _updateResumeData,
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

  List<List<String>> _parseEducation(String raw) {
    if (raw.trim().isEmpty) return [];

    final result = <List<String>>[];

    // Разбиваем на блоки по двойному переводу строки (если несколько образований)
    final blocks =
        raw
            .split(
              RegExp(r'\n{2,}'),
            ) // если будет несколько образований через \n\n
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

    for (final block in blocks) {
      final lines =
          block
              .split('\n')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();

      final institution = lines.length > 0 ? lines[0] : 'Не указано';
      final specialization = lines.length > 1 ? lines[1] : 'Не указано';
      final years = lines.length > 2 ? lines[2] : 'Не указано';

      result.add([institution, specialization, years]);
    }

    return result;
  }
}

// IconButton(onPressed: () {}, icon: Transform.rotate(angle: math.pi, child: backIconWBg,)),

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

String _extractYear(String input) {
  final match = RegExp(r'\b(19|20)\d{2}\b').firstMatch(input);
  return match?.group(0) ?? '';
}

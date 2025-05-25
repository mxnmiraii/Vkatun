import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vkatun/design/images.dart';
import 'package:vkatun/design/dimensions.dart';
import 'package:vkatun/dialogs/error_dialog.dart';
import 'package:vkatun/pages/resume_view_page.dart';
import 'package:vkatun/pages/start_page.dart';
import 'package:vkatun/windows/window_resumes_page.dart';
import 'package:vkatun/api_service.dart';

import '../account/account_main_page.dart';
import '../design/colors.dart';
import '../dialogs/warning_dialog.dart';
import '../windows/scan_windows/indicator.dart';
import 'entry_page.dart';
import 'onboarding_content.dart';

class ResumesPage extends StatefulWidget {
  const ResumesPage({super.key});

  @override
  State<StatefulWidget> createState() => _ResumesPageState();
}

class _ResumesPageState extends State<ResumesPage>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _sortAnimationController;
  bool _isDialogOpen = false;
  List<Map<String, dynamic>> _resumes = [];
  List<Map<String, dynamic>> _displayedResumes = [];
  bool _isSorting = false;
  bool _sortNewestFirst = true;

  bool _isLoading = false;
  bool _reachedLimit = false;

  bool _showOnboarding = true;
  final _onboardingKey = GlobalKey();

  bool _showOverlay = true;

  late final _pulseCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );
  late final _pulseAnim = _pulseCtrl.drive(
    Tween(begin: 0.95, end: 1.05).chain(CurveTween(curve: Curves.easeInOut)),
  );

  bool _isFirstBigStep = true;
  bool _isFifthBigStep = false;

  void _closeOnboarding() {
    setState(() {
      _showOnboarding = false;
    });
  }

  void _hideOverlay() {
    setState(() {
      _showOverlay = false;
    });
  }

  void _switchOnboardingSteps() {
    setState(() {
      _isFirstBigStep = !_isFirstBigStep;
      _isFifthBigStep = !_isFifthBigStep;
    });
  }

  final List<Color> resumeCardColors = [
    babyBlue,
    lightLavender,
    lavenderMist,
    veryPalePink,
  ];
  OverlayEntry? _sortOverlayEntry;
  final GlobalKey _parametersIconKey = GlobalKey();
  final GlobalKey addIconKey = GlobalKey();

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
    _sortAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showFullScreenOnboarding(_isFirstBigStep, _isFifthBigStep);
    });
    _syncResumes();
    _loadResumes();
  }

  void _showFullScreenOnboarding(isFirst, isFifth) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.82),
      transitionDuration: const Duration(milliseconds: timeShowAnimation),
      pageBuilder: (context, _, __) {
        return OnboardingContent(
          closeOnboarding: () {
            Navigator.pop(context); // Закрываем диалог
            _closeOnboarding(); // Обновляем состояние
          },
          hideOnboarding: () {
            Navigator.pop(context);
            if (_isFirstBigStep) {
              _pulseCtrl.repeat(reverse: true);
            }
          },
          iconKey: addIconKey,
          isFirstBigStep: isFirst,
          isFifthBigStep: isFifth,
        );
      },
    );
  }

  Future<void> _loadResumes() async {
    setState(() => _isLoading = true);
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final resumes = await apiService.getResumes();

      setState(() {
        _resumes = resumes;
        _resumes.sort(
          (a, b) => (b['updated_at'] ?? b['created_at']).compareTo(
            a['updated_at'] ?? a['created_at'],
          ),
        );
        _reachedLimit =
            apiService.isGuest ? _resumes.length >= 1 : _resumes.length >= 15;
      });
    } catch (e) {
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _syncResumes() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      if (!apiService.isGuest) {
        await apiService.syncData();
        print('Данные успешно синхронизированы');
      }
    } catch (e) {
      print('Ошибка синхронизации: $e');
    }
  }

  void _checkResumeLimit(ApiService apiService) {
    final isGuest = apiService.authToken == 'guest_token';
    setState(() {
      _reachedLimit = isGuest ? _resumes.length >= 1 : _resumes.length >= 15;
    });
  }

  Future<void> logLoadEvent() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final profile = await apiService.getProfile();

      AppMetrica.setUserProfileID(profile['id'].toString());
      await AppMetrica.reportEvent('load_resume_success');
    } catch (e) {
      print('Ошибка при логине: $e');
    }
  }

  Future<Map<String, dynamic>> _getResumeById(int id) async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      return await apiService.getResumeById(id);
    } catch (e) {
      return {};
    }
  }

  void _stopOnboarding() {
    setState(() {
      _showOnboarding = false;
      _showOverlay = true;
    });
  }

  void _openDialog(int resumeId) async {
    final resume = await _getResumeById(resumeId);

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

    if (_showOverlay) {Overlay.of(context).insert(buttonOverlayEntry);}

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
        return WindowResumesPage(
          onClose: () {
            _closeDialog();
          },
          rotationController: _rotationController,
          resume: resume,
          onDelete: () {
            setState(() {
              _resumes.removeWhere((r) => r['id'] == resume['id']);
              _reachedLimit = false;
            });
          },
          showOnboarding: _showOnboarding,
          stopOnboarding: _stopOnboarding,
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
    _pickPdfFile(context);
  }

  Future<void> _pickPdfFile(BuildContext context) async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    _checkResumeLimit(apiService);

    if (_reachedLimit) {
      _showLimitReachedDialog(context);
      return;
    }

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;

        if (file.extension?.toLowerCase() == 'pdf') {
          await _uploadResume(File(file.path!));

          logLoadEvent();
        } else {
          _showWarningDialog(context);
        }
      }
    } catch (e) {
      _showWarningDialog(context);
    }
  }

  void _showLimitReachedDialog(BuildContext context) {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final isGuest = apiService.authToken == 'guest_token';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(isGuest ? 'Лимит резюме' : 'Достигнут максимум'),
            content: Text(
              isGuest
                  ? 'Гостевой пользователь может хранить только 1 резюме. Авторизуйтесь для добавления большего количества.'
                  : 'Вы можете хранить не более 15 резюме. Удалите одно из существующих, чтобы добавить новое.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
              if (isGuest)
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AccountMainPage(),
                      ),
                    );
                  },
                  child: Text('Войти'),
                ),
            ],
          ),
    );
  }

  Future<void> _uploadResume(File file) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Center(
            child: GradientCircularProgressIndicator(size: 70, strokeWidth: 5),
          ),
    );

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final resume = await apiService.uploadResume(file);

      Navigator.pop(context);
      setState(() {
        _resumes.insert(0, resume);
        _reachedLimit =
            apiService.isGuest ? _resumes.length >= 1 : _resumes.length >= 15;
      });

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ResumeViewPage(
                resume: resume,
                onDelete: () {
                  setState(() {
                    _resumes.removeWhere((r) => r['id'] == resume['id']);
                    _reachedLimit = false;
                  });
                },
                isLoadResume: true,
                isSecondBigStep: _showOnboarding ? true : false,
                showOnboarding: _showOnboarding,
                iconKey: addIconKey,
                onReturnFromOnboarding:
                    _showOnboarding
                        ? () {
                          _switchOnboardingSteps();
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _showFullScreenOnboarding(false, _isFifthBigStep);
                          });
                        }
                        : null,
              ),
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      _showWarningDialog(context);
    }
  }

  void _showWarningDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => WarningDialog(),
      barrierDismissible: true,
    );
  }

  void _updateLimitStatus() {
    final apiService = Provider.of<ApiService>(context, listen: false);
    setState(() {
      _reachedLimit =
          apiService.authToken == 'guest_token'
              ? _resumes.length >= 1
              : _resumes.length >= 15;
    });
  }

  void _showSortMenu() {
    final renderBox =
        _parametersIconKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _sortOverlayEntry = OverlayEntry(
      builder:
          (context) => GestureDetector(
            onTap: () {
              _sortOverlayEntry?.remove();
              _sortOverlayEntry = null;
            },
            behavior: HitTestBehavior.translucent,
            child: Material(
              color: Colors.transparent,
              child: Stack(
                children: [
                  Positioned.fill(child: Container(color: Colors.transparent)),
                  Positioned(
                    right: 16,
                    top: offset.dy + size.height + 8,
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        width: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 20,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xFF7369FB),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Показать сначала',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  fontFamily: 'Playfair',
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            InkWell(
                              onTap: _sortResumesNewestFirst,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 20,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade200,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Новые',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    fontFamily: 'Playfair',
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: _sortResumesOldestFirst,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 20,
                                ),
                                child: Text(
                                  'Старые',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    fontFamily: 'Playfair',
                                  ),
                                  textAlign: TextAlign.center,
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
            ),
          ),
    );

    Overlay.of(_parametersIconKey.currentContext!).insert(_sortOverlayEntry!);
  }

  void _sortResumesNewestFirst() {
    if (_isSorting || _sortNewestFirst) return;
    _isSorting = true;
    _sortNewestFirst = true;

    setState(() {
      _displayedResumes.clear();
      _displayedResumes.addAll(_resumes);
      _resumes.sort(
        (a, b) => (b['created_at'] ?? '').compareTo(a['created_at'] ?? ''),
      );
    });

    _sortOverlayEntry?.remove();
    _sortOverlayEntry = null;
    _animateSort();
  }

  void _sortResumesOldestFirst() {
    if (_isSorting || !_sortNewestFirst) return;
    _isSorting = true;
    _sortNewestFirst = false;

    setState(() {
      _displayedResumes.clear();
      _displayedResumes.addAll(_resumes);
      _resumes.sort(
        (a, b) => (a['created_at'] ?? '').compareTo(b['created_at'] ?? ''),
      );
    });

    _sortOverlayEntry?.remove();
    _sortOverlayEntry = null;
    _animateSort();
  }

  void _animateSort() {
    _sortAnimationController.reset();
    _sortAnimationController.forward().then((_) {
      _isSorting = false;
      setState(() {
        _displayedResumes.clear();
      });
    });
  }

  Offset _calculatePosition(int index) {
    final crossAxisCount = 2;
    final row = index ~/ crossAxisCount;
    final column = index % crossAxisCount;

    return Offset(
      column * (MediaQuery.of(context).size.width / crossAxisCount),
      row * (MediaQuery.of(context).size.width / crossAxisCount / 1.4),
    );
  }

  Widget _buildResumeCard(Map<String, dynamic> resume) {
    return GestureDetector(
      onTap: () async {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(child: CircularProgressIndicator()),
        );

        try {
          final loadedResume = await _getResumeById(resume['id']);
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      _showOnboarding
                          ? ResumeViewPage(
                            resume: loadedResume,
                            onDelete: () {},
                            showOnboarding: true,
                            iconKey: addIconKey,
                            isSixthBigStep: true,
                          )
                          : ResumeViewPage(
                            resume: loadedResume,
                            onDelete: () {},
                          ),
            ),
          );
        } catch (e) {
          Navigator.pop(context);
          _showWarningDialog(context);
        }
      },
      onLongPress: () {
        if (_showOnboarding) {_hideOverlay();}
        _openDialog(resume['id']); // добавить
      },
      child: Card(
        color: _getColorByResumeId(resume['id']),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: royalPurple, width: widthBorderRadius),
        ),
        child: Container(
          constraints: BoxConstraints(minHeight: 0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  resume['title'] ?? '',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Playfair',
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    color: royalPurple,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  resume['experince']?.isNotEmpty == true
                      ? resume['experince']!
                      : 'Опыт не указан',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Playfair',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: royalPurple.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDateGroup(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final weekAgo = today.subtract(Duration(days: 7));
    final monthAgo = today.subtract(Duration(days: 30));

    final resumeDate = DateTime(date.year, date.month, date.day);

    if (resumeDate == today) {
      return 'Сегодня';
    } else if (resumeDate == yesterday) {
      return 'Вчера';
    } else if (resumeDate.isAfter(weekAgo)) {
      return 'На этой неделе';
    } else if (resumeDate.isAfter(monthAgo)) {
      return 'В этом месяце';
    } else {
      return 'Более 30 дней назад';
    }
  }

  List<Widget> _buildGroupedResumes() {
    if (_resumes.isEmpty) return [];

    // Группируем резюме по датам
    final groups = <String, List<Map<String, dynamic>>>{};
    for (final resume in _resumes) {
      final dateStr = resume['created_at'] ?? '';
      if (dateStr.isEmpty) continue;

      try {
        final date = DateTime.parse(dateStr);
        final group = _getDateGroup(date);
        groups.putIfAbsent(group, () => []).add(resume);
      } catch (e) {
        continue;
      }
    }

    // Сортируем группы в нужном порядке
    final groupOrder =
        _sortNewestFirst
            ? [
              'Сегодня',
              'Вчера',
              'На этой неделе',
              'В этом месяце',
              'Более 30 дней назад',
            ]
            : [
              'Более 30 дней назад',
              'В этом месяце',
              'На этой неделе',
              'Вчера',
              'Сегодня',
            ];

    final widgets = <Widget>[];

    bool isFirstGroup = true;

    for (final groupName in groupOrder) {
      final resumes = groups[groupName];
      if (resumes == null || resumes.isEmpty) continue;

      if (!isFirstGroup) {
        widgets.add(const SizedBox(height: 24));
      }
      isFirstGroup = false;

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.05,
                child: Divider(
                  thickness: 3,
                  color: lightLavender.withOpacity(0.5),
                  height: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  groupName,
                  style: TextStyle(
                    color: royalBlue,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Playfair',
                    fontSize: 20,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  thickness: 3,
                  color: lightLavender.withOpacity(0.5),
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      );

      widgets.add(
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 32,
            childAspectRatio: 1.4,
          ),
          itemCount: resumes.length,
          itemBuilder: (context, index) {
            final resume = resumes[index];

            if (_isSorting && _displayedResumes.isNotEmpty) {
              final oldIndex = _displayedResumes.indexWhere(
                (r) => r['id'] == resume['id'],
              );

              return AnimatedBuilder(
                animation: _sortAnimationController,
                builder: (context, child) {
                  final animationValue = Curves.easeInOut.transform(
                    _sortAnimationController.value,
                  );

                  double xOffset = 0;
                  double yOffset = 0;

                  if (oldIndex != -1) {
                    final oldPosition = _calculatePosition(oldIndex);
                    final newPosition = _calculatePosition(index);
                    xOffset =
                        (oldPosition.dx - newPosition.dx) *
                        (1 - animationValue);
                    yOffset =
                        (oldPosition.dy - newPosition.dy) *
                        (1 - animationValue);
                  }

                  return Transform.translate(
                    offset: Offset(xOffset, yOffset),
                    child: Opacity(
                      opacity: _isSorting ? 0.5 + 0.5 * animationValue : 1.0,
                      child: _buildResumeCard(resume),
                    ),
                  );
                },
              );
            } else {
              return _buildResumeCard(resume);
            }
          },
        ),
      );
    }

    return widgets;
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _sortAnimationController.dispose();
    _sortOverlayEntry?.remove();
    super.dispose();
    _pulseCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = screenHeight * 0.1;
    final apiService = Provider.of<ApiService>(context, listen: false);
    final isGuest = apiService.authToken == 'guest_token';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: appBarHeight,
        title: Transform.translate(
          offset: Offset(0, appBarHeight / 5),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: IconButton(
                      icon: accountIcon,
                      onPressed:
                          isGuest && !_showOnboarding
                              ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => StartPage(),
                                  ),
                                );
                              }
                              : _showOnboarding
                              ? null
                              : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AccountMainPage(),
                                  ),
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
                    padding: const EdgeInsets.only(right: 15),
                    child: IconButton(
                      key: _parametersIconKey,
                      icon: parametersIcon,
                      onPressed:
                          _showOnboarding
                              ? null
                              : () {
                                if (_sortOverlayEntry != null) {
                                  _sortOverlayEntry?.remove();
                                  _sortOverlayEntry = null;
                                } else {
                                  _showSortMenu();
                                }
                              },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),

      body:
          _isLoading
              ? Center(child: Container())
              : SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (_reachedLimit) SizedBox(height: 7),
                    if (_reachedLimit)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: lightVioletDivider.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: mediumSlateBlue,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: midnightPurple),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  isGuest
                                      ? 'Вы можете хранить только 1 резюме в гостевом режиме'
                                      : 'Достигнут лимит в 15 резюме',
                                  style: TextStyle(
                                    fontFamily: 'Playfair',
                                    color: midnightPurple,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (isGuest)
                                TextButton(
                                  onPressed:
                                      !_showOnboarding
                                          ? () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) => StartPage(),
                                              ),
                                            );
                                          }
                                          : null,
                                  child: Text(
                                    'Войти',
                                    style: TextStyle(
                                      fontFamily: 'Playfair',
                                      color: midnightPurple,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ..._buildGroupedResumes(),
                    if (_resumes.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 100),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.description_outlined,
                                size: 64,
                                color: Colors.grey.withOpacity(0.5),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'У вас пока нет резюме',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                  fontFamily: 'Playfair',
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                isGuest
                                    ? 'Добавьте свое первое резюме'
                                    : 'Нажмите "+" чтобы добавить резюме',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  fontFamily: 'Playfair',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: bottom35),
        child: AnimatedBuilder(
          animation: Listenable.merge([_rotationController, _pulseCtrl]),
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationController.value * 2 * math.pi,
              child: Transform.scale(
                scale: _showOnboarding ? _pulseAnim.value : 1.0,
                child: IconButton(
                  key: addIconKey,
                  icon: addIcon,
                  onPressed: () {
                    _pulseCtrl.stop();

                    if (_reachedLimit) {
                      null;
                    } else {
                      _onAddIconPressed();
                    }
                  },
                  iconSize: 36,
                  color: _reachedLimit ? Colors.grey[400] : null,
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vkatun/design/colors.dart';
import 'package:vkatun/design/dimensions.dart';
import 'package:vkatun/design/images.dart';
import 'package:vkatun/pages/resumes_page.dart';
import 'package:vkatun/windows/scan_windows/check_widget.dart';
import 'package:vkatun/windows/scan_windows/scan.dart';

import '../api_service.dart';
import '../pages/onboarding_content.dart';

class WindowFixMistakes extends StatefulWidget {
  final VoidCallback onClose;
  final AnimationController rotationController;
  final Map<String, dynamic> resume;
  final bool showOnboarding;
  final bool isSeventhBigStep;
  final VoidCallback? onResumeChange;

  const WindowFixMistakes({
    super.key,
    required this.onClose,
    required this.rotationController,
    required this.resume,
    this.showOnboarding = false,
    this.isSeventhBigStep = false,
    required this.onResumeChange,
  });

  @override
  State<WindowFixMistakes> createState() => _WindowFixMistakesState();
}

class _WindowFixMistakesState extends State<WindowFixMistakes> {
  int selectedIndex = 0;

  // 3 главных раздела
  bool isScanningFix = false;
  bool isScanningStructure = false;
  bool isScanningContent = false;

  // 3 выбора для содержимого
  bool isScanningSkills = false;
  bool isScanningAboutMe = false;
  bool isScanningExperience = false;

  // 4 выбора для исправления ошибок
  bool isScanningSpell = false;
  bool isScanningPunctuation = false;
  bool isScanningGrammar = false;
  bool isScanningStyle = false;

  bool isLoading = false;

  List<Issue> spellingIssues = [];
  List<Issue> punctuationIssues = [];
  List<Issue> grammarIssues = [];
  List<Issue> styleIssues = [];

  List<Issue> structureIssues = [];

  List<Issue> skillsIssues = [];
  List<Issue> aboutMeIssues = [];
  List<Issue> experienceIssues = [];

  final Color activeColor = Colors.white; // основной бэкграунд
  final Color inactiveColor = Colors.transparent;

  bool isEighthBigStep = false;

  @override
  void initState() {
    super.initState();
    widget.showOnboarding
        ? WidgetsBinding.instance.addPostFrameCallback((_) {
          _showFullScreenOnboarding(false, widget.isSeventhBigStep, false);
        })
        : null;
  }

  Future<void> logScanEvent() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final profile = await apiService.getProfile();

      AppMetrica.setUserProfileID(profile['id'].toString());
      await AppMetrica.reportEvent('scanning_success');
    } catch (e) {
      print('Ошибка при логине: $e');
    }
  }

  bool isGuest() {
    final apiService = Provider.of<ApiService>(context, listen: false);
    return apiService.isGuest;
  }

  void _showFullScreenOnboarding(isFirst, isSeventh, isEight) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.82),
      transitionDuration: const Duration(milliseconds: timeShowAnimation),
      pageBuilder: (context, _, __) {
        return OnboardingContent(
          hideOnboarding: () {
            Navigator.pop(context);
          },
          iconKey: GlobalKey(),
          isFirstBigStep: isFirst,
          isSeventhBigStep: isSeventh,
          isEightBigStep: isEight,
        );
      },
    );
  }

  Future<List<Issue>> _analyzeResumeSkills(int id, String nameIssue) async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final response = await apiService.analyzeSkills(id);

      final issues = response['issues'] as List<dynamic>? ?? [];

      return issues
          .map(
            (issue) => Issue(
              errorText: issue['text'].toString(),
              suggestion: 'Рекомендуем исключить данный навык',
              description: issue['reason'].toString(),
            ),
          )
          .toList();
    } catch (e) {
      print('Ошибка при анализе $e');
      return [];
    }
  }

  Future<List<Issue>> _analyzeResumeAboutMe(int id, String nameIssue) async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final response = await apiService.analyzeAbout(id);

      final comment = response['comment'] as String?;

      if (comment != null && comment.isNotEmpty && !comment.contains('Контактные данные указаны корректно: '
          'будущий работодатель может с вами связаться.')) {
        return [
          Issue(
            errorText: 'О себе',
            suggestion: comment,
            description:
                'В разделе "О себе" отсутствуют контактные данные, что затрудняет связь с вами. '
                'Контактная информация является важной частью резюме и упрощает процесс коммуникации с работодателем.',
          ),
        ];
      }
      return [];
    } catch (e) {
      print('Ошибка при анализе $e');
      return [];
    }
  }

  Future<List<Issue>> _analyzeResumeExperience(int id, String nameIssue) async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final response = await apiService.analyzeExperience(id);

      final comment = response['comment'] as String?;

      if (comment != null && comment.isNotEmpty && !comment.contains('Раздел «Опыт работы» выглядит хорошо.')) {
        return [
          Issue(
            errorText: 'Опыт работы',
            suggestion: comment,
            description:
                'Описание опыта слишком краткое, что делает его недостаточно информативным. '
                'Важно детально описывать обязанности и достижения, чтобы работодатель мог оценить ваш вклад в компанию.',
          ),
        ];
      }
      return [];
    } catch (e) {
      print('Ошибка при анализе опыта работы: $e');
      return [];
    }
  }

  Future<List<Issue>> _analyzeResumeStructure(int id) async {
    try {
      final issues = <Issue>[];

      // Проверяем наличие обязательных разделов
      final requiredSections = {
        'contacts': 'Контактные данные',
        'job': 'Желаемая должность',
        'experience': 'Опыт работы',
        'skills': 'Навыки',
        'about': 'О себе',
      };

      for (final entry in requiredSections.entries) {
        if (widget.resume[entry.key] == null ||
            (widget.resume[entry.key] is String &&
                widget.resume[entry.key].isEmpty)) {
          issues.add(
            Issue(
              errorText: entry.value,
              suggestion: 'Добавьте раздел "${entry.value}" в резюме',
              description: 'Пропущенный раздел',
            ),
          );
        }
      }

      // Проверяем длинные блоки текста в разделах
      final textSections = {
        'experience': 'Опыт работы',
        'education': 'Образование',
        'skills': 'Навыки',
        'about': 'О себе',
      };

      for (final entry in textSections.entries) {
        final sectionText = widget.resume[entry.key] as String? ?? '';
        if (sectionText.isNotEmpty) {
          // Разбиваем на абзацы (если есть переносы строк)
          final paragraphs = sectionText.split('\n');

          for (final paragraph in paragraphs) {
            if (paragraph.trim().isEmpty) continue;

            // Считаем примерное количество предложений (по точкам)
            final sentenceCount = paragraph.split('.').length - 1;
            if (sentenceCount > 5) {
              issues.add(
                Issue(
                  errorText: '${entry.value}',
                  suggestion:
                      'Разбейте текст на абзацы для улучшения восприятия',
                  description:
                      'Длинный блок текста в разделе "${entry.value}" - более 5 предложений без разделения',
                  flag: true,
                ),
              );
            }
          }
        }
      }

      return issues;
    } catch (e) {
      print('Ошибка при анализе структуры: $e');
      return [];
    }
  }

  Future<List<Issue>> _analyzeResumeGrammar(int id, String requiredType) async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final response = await apiService.checkGrammar(id);

      // Проверяем наличие данных
      if (response['issues'] == null) return [];

      // Фильтруем и преобразуем в Issue
      return (response['issues'] as List)
          .where((issue) => issue['type'] == requiredType)
          .map(
            (issue) => Issue(
              errorText: issue['text'] ?? '',
              suggestion: issue['suggestion'] ?? '',
              description:
                  requiredType.contains('spelling')
                      ? 'Ошибка в написании слова. Верный вариант - "${issue['suggestion']}".'
                      : 'Ошибка в написании. Верный вариант - "${issue['suggestion']}".',
            ),
          )
          .toList();
    } catch (e) {
      print('Ошибка при получении ошибок: $e');
      return [];
    }
  }

  Future<void> scanningStructureState() async {
    setState(() {
      isLoading = true;
      isScanningStructure = true;
      structureIssues = [];
    });

    try {
      final issues = await _analyzeResumeStructure(widget.resume['id']);
      setState(() {
        structureIssues = issues;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isScanningStructure = false;
        isLoading = false;
      });
      if (mounted) {}
    }
  }

  final List<Map<String, Widget>> iconsList = [
    {'active': textAIconNoFill, 'inactive': textAIcon},
    {'active': moreIconNoFill, 'inactive': moreIcon},
    {'active': penIconNoFill, 'inactive': penIcon},
  ];

  @override
  Widget build(BuildContext context) {
    const borderWindowColor = royalPurple;
    const windowColor = Colors.white;
    const windowColorInBox = lightLavender;
    const padding = 12.0;
    const buttonColor = cosmicBlue;
    final screenHeight = MediaQuery.of(context).size.height;
    final containerHeight = screenHeight * (7 / 10);
    final paddingVHForMainWindow = screenHeight * 0.1;

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
                constraints: BoxConstraints(
                  maxHeight: containerHeight,
                  minHeight: containerHeight,
                ),
                padding: const EdgeInsets.all(padding),
                decoration: BoxDecoration(
                  color: windowColor,
                  borderRadius: BorderRadius.circular(27),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 10,
                      blurRadius: 10,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // Строка с иконками
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(3, (index) {
                        final bool isFirst =
                            index == 0; // Первая (левая) иконка
                        final bool isLast =
                            index == 2; // Последняя (правая) иконка

                        return Padding(
                          padding: EdgeInsets.only(
                            left:
                                isFirst
                                    ? 16
                                    : 0, // Отступ слева только для первой
                            right:
                                isLast
                                    ? 16
                                    : 0, // Отступ справа только для последней
                          ),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIndex = index;
                              });
                            },
                            child: Container(
                              // ← Просто Container вместо AnimatedContainer
                              decoration: BoxDecoration(
                                color:
                                    selectedIndex == index
                                        ? Colors.white
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.all(8),
                              child:
                                  selectedIndex == index
                                      ? iconsList[index]['active']
                                      : iconsList[index]['inactive'],
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 10),

                    // Фиолетовый контейнер
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(padding * 1.5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(21),
                          border: Border.all(
                            color: lightVioletBlue,
                            width: widthBorderRadius,
                          ),
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
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(
                            milliseconds: timeShowAnimation,
                          ),
                          child: _getContent(selectedIndex),
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

  Widget _buildText(String text, bool mark) {
    final _textStyle = TextStyle(
      fontFamily: 'Playfair',
      height: 1.1,
      color: deepIndigo,
      fontSize: 12.8,
      fontWeight: FontWeight.w800,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (mark)
          Padding(
            padding: const EdgeInsets.only(top: 2.0, right: 6),
            child: miniDoneIcon,
          ),
        Expanded(child: Text(text, style: _textStyle, softWrap: true)),
      ],
    );
  }

  Widget _getContent(int index) {
    final _box = SizedBox(height: 6);

    switch (index) {
      case 0:
        return isScanningFix
            ? (isScanningSpell
                ? Scan(
                  onBackPressed: () {
                    setState(() {
                      isScanningSpell = false;
                    });
                  },
                  onClose: widget.onClose,
                  resume: widget.resume,
                  title: 'Орфография',
                  issues: spellingIssues,
                  isLoading: isLoading,
                  onResumeChange: widget.onResumeChange,
                  isStructure: false,
                  isEmptyError: false,
                )
                : isScanningPunctuation
                ? Scan(
                  onBackPressed: () {
                    setState(() {
                      isScanningPunctuation = false;
                    });
                  },
                  onClose: widget.onClose,
                  resume: widget.resume,
                  title: 'Пунктуация',
                  issues: punctuationIssues,
                  isLoading: isLoading,
                  onResumeChange: widget.onResumeChange,
                  isStructure: false,
                  isEmptyError: false,
                )
                : isScanningGrammar
                ? Scan(
                  onBackPressed: () {
                    setState(() {
                      isScanningGrammar = false;
                    });
                  },
                  onClose: widget.onClose,
                  resume: widget.resume,
                  title: 'Грамматика',
                  issues: grammarIssues,
                  isLoading: isLoading,
                  onResumeChange: widget.onResumeChange,
                  isStructure: false,
                  isEmptyError: false,
                )
                : isScanningStyle
                ? Scan(
                  onBackPressed: () {
                    setState(() {
                      isScanningStyle = false;
                    });
                  },
                  onClose: widget.onClose,
                  resume: widget.resume,
                  title: 'Стилевые ошибки',
                  issues: styleIssues,
                  isLoading: isLoading,
                  onResumeChange: widget.onResumeChange,
                  isStructure: false,
                  isEmptyError: false,
                )
                : _scan(index, 'Исправление ошибок'))
            : _buildPage(index, 'Исправление ошибок', [
              _buildText(
                'Раздел предназначен для автоматического поиска и исправления ошибок в резюме. '
                'Обработка включает: ',
                false,
              ),
              _box,
              _buildText(
                'Орфография: исправление неправильного написания слов, опечаток, паронимов.',
                true,
              ),
              _box,
              _buildText(
                'Грамматика: исправление ошибок в построении предложений, согласовании, управлении падежами, '
                'использовании предлогов.',
                true,
              ),
              _box,
              _buildText(
                'Пунктуация: исправление ошибок в расстановке запятых, тире, двоеточий, лишних или '
                'пропущенных знаков',
                true,
              ),
              _box,
              _buildText(
                'Стиль: устранение тавтологии, канцеляризмов и нелогичных фраз.',
                true,
              ),
            ]);
      case 1:
        return isScanningStructure
            ? Scan(
              onBackPressed: () {
                setState(() {
                  isScanningStructure = false;
                });
              },
              onClose: widget.onClose,
              resume: widget.resume,
              title: 'Структура',
              issues: structureIssues,
              isLoading: isLoading,
              onResumeChange: widget.onResumeChange,
              isStructure: true,
              isEmptyError: true,
            )
            : _buildPage(index, 'Структура', [
              _buildText(
                'Данный раздел предназначен для автоматического выявления разделов, требующих редактирования. '
                'Обработка ошибок включает в себя следующие категории: ',
                false,
              ),
              _box,
              _buildText(
                'Компоненты: выявление отсутствующих разделов. ',
                true,
              ),
              _box,
              _buildText(
                'Смысловые части: рекомендации о разделении текста на образцы. ',
                true,
              ),
            ]);
      case 2:
        return isScanningContent
            ? (isScanningSkills
                ? Scan(
                  onBackPressed: () {
                    setState(() {
                      isScanningSkills = false;
                    });
                  },
                  onClose: widget.onClose,
                  resume: widget.resume,
                  title: 'Навыки',
                  issues: skillsIssues,
                  isLoading: isLoading,
                  onResumeChange: widget.onResumeChange,
                  isStructure: false,
                  isEmptyError: true,
                )
                : isScanningAboutMe
                ? Scan(
                  onBackPressed: () {
                    setState(() {
                      isScanningAboutMe = false;
                    });
                  },
                  onClose: widget.onClose,
                  resume: widget.resume,
                  title: 'О себе',
                  isLoading: isLoading,
                  issues: aboutMeIssues,
                  onResumeChange: widget.onResumeChange,
                  isStructure: true,
                  isEmptyError: true,
                )
                : isScanningExperience
                ? Scan(
                  onBackPressed: () {
                    setState(() {
                      isScanningExperience = false;
                    });
                  },
                  onClose: widget.onClose,
                  resume: widget.resume,
                  title: 'Опыт работы',
                  issues: experienceIssues,
                  isLoading: isLoading,
                  onResumeChange: widget.onResumeChange,
                  isStructure: true,
                  isEmptyError: true,
                )
                : _scan(index, 'Содержание'))
            : _buildPage(index, 'Содержание', [
              _buildText(
                'Данный раздел предназначен для автоматического выявления ошибок в содержании текста резюме. '
                'Обработка ошибок включает в себя следующие категории: ',
                false,
              ),
              _box,
              _buildText(
                'Навыки: в случае, если в вашем резюме присутствуют нерелевантные навыки (навыки, которые '
                'не относятся к вашей профессии). ',
                true,
              ),
              _box,
              _buildText(
                'О себе: в данной категории будут предложения о добавлении важных пунктов о вас. ',
                true,
              ),
              _box,
              _buildText(
                'Опыт работы: в данной категории будут рекомендации о том, как лучше рассказать о вашем опыте работы. ',
                true,
              ),
            ]);
      default:
        return Container();
    }
  }

  Widget _buildPage(int index, title, list) {
    const borderWindowColor = royalPurple;
    const padding = 12.0;
    const buttonColor = cosmicBlue;

    final textStyle = TextStyle(
      color: buttonColor,
      fontFamily: 'Playfair',
      height: 1.0,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            // Контейнер занимает всё место до кнопки
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(17),
                ),
                // Внутренний скролл только если нужно
                child: LayoutBuilder(
                  builder: (context, innerConstraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: innerConstraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Заголовок
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: padding / 2,
                                  horizontal: padding / 2,
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      title,
                                      style: textStyle.copyWith(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                        color: violet,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 10),
                                    Divider(
                                      color: lightViolet.withOpacity(0.5),
                                      thickness: 2,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Контент
                              Column(children: list),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Кнопка "Просканировать"
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: ElevatedButton(
                onPressed:
                    widget.showOnboarding
                        ? () {
                          widget.onClose;
                          Navigator.pop(context);
                          setState(() {
                            isEighthBigStep = true;
                          });
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _showFullScreenOnboarding(false, false, true);
                          });
                        }
                        : (!isGuest() || index == 0)
                        ? () async {
                          try {
                            logScanEvent();

                            switch (index) {
                              case 0:
                                setState(() {
                                  isScanningFix = true;
                                });
                                break;
                              case 1:
                                scanningStructureState();
                                break;
                              case 2:
                                setState(() {
                                  isScanningContent = true;
                                });
                                break;
                            }
                          } catch (e) {
                            debugPrint('Ошибка отправки события: $e');
                          }
                        }
                        : () async {
                          if (isGuest()) {
                            final overlay = Overlay.of(context);
                            final overlayEntry = OverlayEntry(
                              builder:
                                  (context) => Positioned(
                                    top: MediaQuery.of(context).padding.top,
                                    left: 24,
                                    right: 24,
                                    child: Material(
                                      color: Colors.transparent,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 10,
                                              offset: Offset(0, 4),
                                            ),
                                          ],
                                          border: Border.all(
                                            color: mediumSlateBlue.withOpacity(
                                              0.3,
                                            ),
                                            width: 2,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.info_outline_rounded,
                                              color: mediumSlateBlue,
                                              size: 24,
                                            ),
                                            SizedBox(width: 8),
                                            Flexible(
                                              child: Text(
                                                'Доступно только авторизованным пользователям',
                                                style: TextStyle(
                                                  fontFamily: 'Playfair',
                                                  color: midnightPurple,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  height: 1.3,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                            );

                            overlay.insert(overlayEntry);

                            await Future.delayed(const Duration(seconds: 2));
                            overlayEntry.remove();
                          }
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  elevation: 0,
                ),
                child: const Text(
                  'Просканировать',
                  style: TextStyle(
                    color: midnightPurple,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Playfair',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _scan(int index, String title) {
    const borderWindowColor = royalPurple;
    const windowColor = Colors.white;
    const windowColorInBox = lightLavender;
    const padding = 12.0;
    const buttonColor = cosmicBlue;
    final screenHeight = MediaQuery.of(context).size.height;
    final space = screenHeight * 0.05;

    final textStyle = TextStyle(
      color: buttonColor,
      fontFamily: 'Playfair',
      height: 1.0,
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: padding / 2,
            horizontal: padding / 2,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: buttonLightLavender.withOpacity(0.53),
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
        SizedBox(height: 10),
        Divider(color: lightViolet.withOpacity(0.5), thickness: 2),
        SizedBox(height: space / 2),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children:
                  index == 0
                      ? [
                        _buildButton('Орфография', () async {
                          setState(() {
                            isLoading = true;
                            isScanningSpell = true;
                            spellingIssues = [];
                          });

                          try {
                            final issues = await _analyzeResumeGrammar(
                              widget.resume['id'],
                              'spelling',
                            );
                            setState(() {
                              spellingIssues = issues;
                              isLoading = false;
                            });
                          } catch (e) {
                            setState(() {
                              isScanningSpell = false;
                              isLoading = false;
                            });
                          }
                        }),
                        _buildButton('Пунктуация', () async {
                          setState(() {
                            isLoading = true;
                            isScanningPunctuation = true;
                            punctuationIssues = [];
                          });

                          try {
                            final issues = await _analyzeResumeGrammar(
                              widget.resume['id'],
                              'punctuation',
                            );
                            setState(() {
                              punctuationIssues = issues;
                              isLoading = false;
                            });
                          } catch (e) {
                            setState(() {
                              isScanningPunctuation = false;
                              isLoading = false;
                            });
                          }
                        }),
                        _buildButton('Грамматика', () async {
                          setState(() {
                            isLoading = true;
                            isScanningGrammar = true;
                            grammarIssues = [];
                          });

                          try {
                            final issues = await _analyzeResumeGrammar(
                              widget.resume['id'],
                              'grammar',
                            );
                            setState(() {
                              grammarIssues = issues;
                              isLoading = false;
                            });
                          } catch (e) {
                            setState(() {
                              isLoading = false;
                              isScanningGrammar = false;
                            });
                          }
                        }),
                        _buildButton('Стилевые ошибки', () async {
                          setState(() {
                            isLoading = true;
                            isScanningStyle = true;
                            styleIssues = [];
                          });

                          try {
                            final issues = await _analyzeResumeGrammar(
                              widget.resume['id'],
                              'style',
                            );
                            setState(() {
                              styleIssues = issues;
                              isLoading = false;
                            });
                          } catch (e) {
                            setState(() {
                              isLoading = false;
                              isScanningStyle = false;
                            });
                          }
                        }),
                      ]
                      : [
                        _buildButton('Навыки', () async {
                          setState(() {
                            isLoading = true;
                            isScanningSkills = true;
                            skillsIssues = [];
                          });

                          try {
                            final issues = await _analyzeResumeSkills(
                              widget.resume['id'],
                              'skills',
                            );
                            setState(() {
                              skillsIssues = issues;
                              isLoading = false;
                            });
                          } catch (e) {
                            setState(() {
                              isLoading = false;
                              isScanningSkills = false;
                            });
                          }
                        }),
                        _buildButton('О себе', () async {
                          setState(() {
                            isLoading = true;
                            isScanningAboutMe = true;
                            aboutMeIssues = [];
                          });

                          try {
                            final issues = await _analyzeResumeAboutMe(
                              widget.resume['id'],
                              'about',
                            );
                            setState(() {
                              aboutMeIssues = issues;
                              isLoading = false;
                            });
                          } catch (e) {
                            setState(() {
                              isLoading = false;
                              isScanningAboutMe = false;
                            });
                          }
                        }),
                        _buildButton('Опыт работы', () async {
                          setState(() {
                            isLoading = true;
                            isScanningExperience = true;
                            experienceIssues = [];
                          });

                          try {
                            final issues = await _analyzeResumeExperience(
                              widget.resume['id'],
                              'experience',
                            );
                            setState(() {
                              isLoading = false;
                              experienceIssues = issues;
                            });
                          } catch (e) {
                            setState(() {
                              isLoading = false;
                              isScanningExperience = false;
                            });
                          }
                        }),
                      ],
            ),
          ),
        ),
        SizedBox(height: space),
      ],
    );
  }

  Widget _buildButton(String text, onPressed) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            side: BorderSide(
              color: buttonLightLavender.withOpacity(0.53),
              width: widthBorderRadius,
            ),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            minimumSize: const Size(double.infinity, 50),
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            elevation: 0,
          ),
          child: Text(
            text,
            style: TextStyle(
              color: midnightPurple,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              fontFamily: 'Playfair',
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 25),
      ],
    );
  }
}

ButtonStyle _buttonStyle(Color borderColor) {
  return ElevatedButton.styleFrom(
    side: BorderSide(color: borderColor, width: widthBorderRadius),
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    ),
    minimumSize: const Size(double.infinity, 50),
    elevation: 0,
  );
}

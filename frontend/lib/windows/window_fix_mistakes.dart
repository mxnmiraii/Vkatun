import 'package:flutter/material.dart';
import 'package:vkatun/design/colors.dart';
import 'package:vkatun/design/dimensions.dart';
import 'package:vkatun/windows/scan_windows/check_widget.dart';
import 'package:vkatun/windows/scan_windows/scan.dart';

class WindowFixMistakes extends StatefulWidget {
  final VoidCallback onClose;
  final AnimationController rotationController;
  final Map<String, dynamic> resume;

  const WindowFixMistakes({
    super.key,
    required this.onClose,
    required this.rotationController,
    required this.resume,
  });

  @override
  State<WindowFixMistakes> createState() => _WindowFixMistakesState();
}

class _WindowFixMistakesState extends State<WindowFixMistakes> {
  int selectedIndex = 0;
  bool isScanning = false;
  bool isScanningSpell = false;
  bool isScanningPunctuation = false;
  bool isScanningGrammar = false;
  bool isScanningStyle = false;

  final Color activeColor = Colors.white; // основной бэкграунд
  final Color inactiveColor = Colors.transparent;

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
                  borderRadius: BorderRadius.circular(borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 10,
                      blurRadius: 10,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.all(padding * 1.5),
                  decoration: BoxDecoration(
                    color: windowColorInBox,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIndex = index;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(
                                milliseconds: timeShowAnimation,
                              ),
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color:
                                    selectedIndex == index
                                        ? activeColor
                                        : inactiveColor,
                                border: Border.all(color: Colors.blue.shade900),
                                borderRadius: BorderRadius.circular(
                                  selectedIndex == index ? 20 : 12,
                                ),
                              ),
                              child: Icon(
                                _getIcon(index),
                                color: Colors.blue.shade900,
                                size: 28,
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 10),
                      // Нижний контент
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(
                            milliseconds: timeShowAnimation,
                          ),
                          child: _getContent(selectedIndex),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(int index) {
    switch (index) {
      case 0:
        return Icons.spellcheck;
      case 1:
        return Icons.account_tree_outlined;
      case 2:
        return Icons.edit;
      default:
        return Icons.help_outline;
    }
  }

  Widget _getContent(int index) {
    switch (index) {
      case 0:
        return isScanning
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
                  issues: [
                    Issue(
                      errorText: "devoloper",
                      suggestion: "developer",
                      description:
                          "Неправильное написание слова на английском",
                    ),
                    Issue(
                      errorText: "програмная инжинерия",
                      suggestion: "программная инженерия",
                      description: "Ошибка в корне и суффиксах (двойная «м», «е» вместо «и»)",
                    ),
                    Issue(
                      errorText: "государственый",
                      suggestion: "государственный",
                      description: "Пропущена буква «н»",
                    ),
                    Issue(
                      errorText: "Мовинг",
                      suggestion: "Майвинг (или Moving)",
                      description: "Не существует слова «Мовинг» — это искажение",
                    ),
                  ],
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
                  issues: [
                    Issue(
                      errorText: "общежитии ВГУ!",
                      suggestion: "общежитии ВГУ",
                      description:
                          "Восклицательный знак здесь неуместен",
                    ),
                    Issue(
                      errorText:
                          "и, командировкам",
                      suggestion:
                          "	и командировкам",
                      description: "Запятая не ставится между однородными членами",
                    ),
                  ],
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
                  issues: [
                    Issue(
                      errorText: "23 лет",
                      suggestion: "23 года",
                      description:
                          "Ошибка в управлении числительного и существительного",
                    ),
                    Issue(
                      errorText: "проживает в г. Воронеже",
                      suggestion: "проживает в городе Воронеж",
                      description: "Нарушена форма существительного в предложном падеже",
                    ),
                    Issue(
                      errorText: "факультет компьютерных науков",
                      suggestion: "факультет компьютерных наук",
                      description: "Согласование: нужен родительный падеж ед. ч. (если бы слово было «науки»)",
                    ),
                  ],
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
                  issues: [
                    Issue(
                      errorText: "git, sql, kafka golang postgreSQL",
                      suggestion: "Git, SQL, Kafka, Golang, PostgreSQL",
                      description:
                          "Несоблюдение регистра и структуры перечисления",
                    ),
                    Issue(
                      errorText: "ВГУ",
                      suggestion: "Воронежского государственного университета (ВГУ)",
                      description: "Сначала расшифровка, затем аббревиатура — по стилю",
                    ),
                    Issue(
                      errorText: "вахтёр",
                      suggestion: "сторож",
                      description: "«Вахтёр» — разговорное слово, в деловом резюме лучше заменить",
                    ),
                    Issue(
                      errorText: "два года и два месяца",
                      suggestion: "2 года и 2 месяца",
                      description: "В деловом стиле принято использовать цифры",
                    ),
                  ],
                )
                : _scan())
            : _buildPage();
      case 1:
        return Container();
      case 2:
        return Container();
      default:
        return Container();
    }
  }

  Widget _buildPage() {
    const borderWindowColor = royalPurple;
    const windowColor = Colors.white;
    const windowColorInBox = lightLavender;
    const padding = 12.0;
    const buttonColor = cosmicBlue;
    final screenHeight = MediaQuery.of(context).size.height;

    final textStyle = TextStyle(
      color: buttonColor,
      fontFamily: 'Playfair',
      height: 1.0,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
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
              color: borderWindowColor,
              width: widthBorderRadius,
            ),
          ),
          child: Text(
            'Исправление ошибок',
            style: textStyle.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 20),
        Expanded(
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  Text(
                    'Данный раздел предназначен для автоматического выявления и исправления ошибок в тексте резюме. '
                    'Обработка ошибок включает в себя следующие категории: ',
                    style: textStyle.copyWith(
                      color: deepIndigo,
                      fontSize: 12.8,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 4),
                  Text(
                    '–  Орфография: исправление орфографических ошибок, таких как неправильное написание слов, опечатки, '
                    'ошибки в употреблении паронимов и другие.',
                    style: textStyle.copyWith(
                      color: deepIndigo,
                      fontSize: 12.8,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 4),
                  Text(
                    '–  Грамматика: исправление ошибок в построении предложений, согласовании слов, управлении падежами, '
                    'а также в использовании предлогов.',
                    style: textStyle.copyWith(
                      color: deepIndigo,
                      fontSize: 12.8,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 4),
                  Text(
                    '–  Пунктуация: исправление ошибок в расстановке запятых, тире, двоеточие, а также исправление '
                    'пропущенных или лишних знаков препинания.',
                    style: textStyle.copyWith(
                      color: deepIndigo,
                      fontSize: 12.8,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 4),
                  Text(
                    '–  Стилевые ошибки: улучшение стиля текста, включая устранение тавтологии, канцеляризмов и '
                    'нелогичных построений фраз.',
                    style: textStyle.copyWith(
                      color: deepIndigo,
                      fontSize: 12.8,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              isScanning = true;
            });
          },
          style: ElevatedButton.styleFrom(
            side: BorderSide(color: midnightPurple, width: widthBorderRadius),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            minimumSize: const Size(double.infinity, 50),
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            elevation: 0,
          ),
          child: const Text(
            'Просканировать',
            style: TextStyle(
              color: midnightPurple,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _scan() {
    const borderWindowColor = royalPurple;
    const windowColor = Colors.white;
    const windowColorInBox = lightLavender;
    const padding = 12.0;
    const buttonColor = cosmicBlue;
    final screenHeight = MediaQuery.of(context).size.height;

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
              color: borderWindowColor,
              width: widthBorderRadius,
            ),
          ),
          child: Text(
            'Исправление ошибок',
            style: textStyle.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 20),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isScanningSpell = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  side: BorderSide(
                    color: midnightPurple,
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
                child: const Text(
                  'Орфография',
                  style: TextStyle(
                    color: midnightPurple,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isScanningPunctuation = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  side: BorderSide(
                    color: midnightPurple,
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
                child: const Text(
                  'Пунктуация',
                  style: TextStyle(
                    color: midnightPurple,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isScanningGrammar = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  side: BorderSide(
                    color: midnightPurple,
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
                child: const Text(
                  'Грамматика',
                  style: TextStyle(
                    color: midnightPurple,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isScanningStyle = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  side: BorderSide(
                    color: midnightPurple,
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
                child: const Text(
                  'Стилевые ошибки',
                  style: TextStyle(
                    color: midnightPurple,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
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

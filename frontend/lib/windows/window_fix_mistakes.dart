import 'package:flutter/material.dart';
import 'package:vkatun/design/colors.dart';
import 'package:vkatun/design/dimensions.dart';
import 'package:vkatun/design/images.dart';
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

  final Color activeColor = Colors.white; // основной бэкграунд
  final Color inactiveColor = Colors.transparent;

  final List<Map<String, Widget>> iconsList = [
    {
      'active': textAIconNoFill,
      'inactive': textAIcon,
    },
    {
      'active': moreIconNoFill,
      'inactive': moreIcon,
    },
    {
      'active': penIconNoFill,
      'inactive': penIcon,
    },
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
                        final bool isFirst = index == 0;  // Первая (левая) иконка
                        final bool isLast = index == 2;   // Последняя (правая) иконка

                        return Padding(
                          padding: EdgeInsets.only(
                            left: isFirst ? 16 : 0,   // Отступ слева только для первой
                            right: isLast ? 16 : 0,   // Отступ справа только для последней
                          ),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIndex = index;
                              });
                            },
                            child: Container( // ← Просто Container вместо AnimatedContainer
                              decoration: BoxDecoration(
                                color: selectedIndex == index ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: selectedIndex == index
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
                              upColorGradient,    // Верхний цвет (#E2E5FF)
                              downColorGradient.withOpacity(0.6), // Нижний цвет (#B2B1FF99 с 60% прозрачностью)
                            ],
                          ),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: timeShowAnimation),
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

  Widget _getIcon(int index) {
    switch (index) {
      case 0:
        return textAIcon;
      case 1:
        return moreIcon;
      case 2:
        return penIcon;
      default:
        return textAIcon;
    }
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
        Expanded(
          child: Text(
            text,
            style: _textStyle,
            softWrap: true,
          ),
        ),
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
                  issues: [
                    Issue(
                      errorText: "devoloper",
                      suggestion: "developer",
                      description: "Неправильное написание слова на английском",
                    ),
                    Issue(
                      errorText: "програмная инжинерия",
                      suggestion: "программная инженерия",
                      description:
                          "Ошибка в корне и суффиксах (двойная «м», «е» вместо «и»)",
                    ),
                    Issue(
                      errorText: "государственый",
                      suggestion: "государственный",
                      description: "Пропущена буква «н»",
                    ),
                    Issue(
                      errorText: "Мовинг",
                      suggestion: "Майвинг (или Moving)",
                      description:
                          "Не существует слова «Мовинг» — это искажение",
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
                      description: "Восклицательный знак здесь неуместен",
                    ),
                    Issue(
                      errorText: "и, командировкам",
                      suggestion: "	и командировкам",
                      description:
                          "Запятая не ставится между однородными членами",
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
                      description:
                          "Нарушена форма существительного в предложном падеже",
                    ),
                    Issue(
                      errorText: "факультет компьютерных науков",
                      suggestion: "факультет компьютерных наук",
                      description:
                          "Согласование: нужен родительный падеж ед. ч. (если бы слово было «науки»)",
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
                      suggestion:
                          "Воронежского государственного университета (ВГУ)",
                      description:
                          "Сначала расшифровка, затем аббревиатура — по стилю",
                    ),
                    Issue(
                      errorText: "вахтёр",
                      suggestion: "сторож",
                      description:
                          "«Вахтёр» — разговорное слово, в деловом резюме лучше заменить",
                    ),
                    Issue(
                      errorText: "два года и два месяца",
                      suggestion: "2 года и 2 месяца",
                      description: "В деловом стиле принято использовать цифры",
                    ),
                  ],
                )
                : _scan(index, 'Исправление ошибок'))
            : _buildPage(index, 'Исправление ошибок', [
              _buildText(
                'Раздел предназначен для автоматического поиска и исправления ошибок в резюме. '
                'Обработка включает: ', false,
              ),
              _box,
              _buildText(
                'Орфография: исправление неправильного написания слов, опечаток, паронимов.', true,
              ),
              _box,
              _buildText(
                'Грамматика: исправление ошибок в построении предложений, согласовании, управлении падежами, '
                'использовании предлогов.', true,
              ),
              _box,
              _buildText(
                'Пунктуация: исправление ошибок в расстановке запятых, тире, двоеточий, лишних или '
                'пропущенных знаков', true,
              ),
              _box,
              _buildText(
                'Стиль: устранение тавтологии, канцеляризмов и нелогичных фраз.', true,
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
              issues: [
                Issue(
                  errorText: "Компоненты",
                  suggestion: "",
                  description:
                      "Отсутствует содержание пунктов: желаемая должность",
                ),
                Issue(
                  errorText: "Смысловые части",
                  suggestion: "",
                  description:
                      "Тоже какая то тут ошибка у вас. Не знаю пока какая",
                ),
              ],
            )
            : _buildPage(index, 'Структура', [
              _buildText(
                'Данный раздел предназначен для автоматического выявления разделов, требующих редактирования. '
                'Обработка ошибок включает в себя следующие категории: ', false,
              ),
              _box,
              _buildText('Компоненты: выявление отсутствующих разделов. ', true),
              _box,
              _buildText(
                'Смысловые части: рекомендации о разделении тексте на образцы. ', true,
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
                  issues: [
                    Issue(
                      errorText: "Рисование",
                      suggestion: "",
                      description:
                          "В вашем резюме присутствуют нерелевантные навыки (навыки, которые не относятся к вашей "
                          "профессии): 'рисование'",
                    ),
                    Issue(
                      errorText: "Танцы",
                      suggestion: "",
                      description:
                          "В вашем резюме присутствуют нерелевантные навыки (навыки, которые не относятся к вашей "
                          "профессии): 'танцы'",
                    ),
                    Issue(
                      errorText: "Музыка",
                      suggestion: "",
                      description:
                          "В вашем резюме присутствуют нерелевантные навыки (навыки, которые не относятся к вашей "
                          "профессии): 'музыка'",
                    ),
                  ],
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
                  issues: [],
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
                  issues: [],
                )
                : _scan(index, 'Содержание'))
            : _buildPage(index, 'Содержание', [
              _buildText(
                'Данный раздел предназначен для автоматического выявления ошибок в содержании текста резюме. '
                'Обработка ошибок включает в себя следующие категории: ', false,
              ),
              _box,
              _buildText(
                'Навыки: в случае, если в вашем резюме присутствуют нерелевантные навыки (навыки, которые '
                'не относятся к вашей профессии). ', true,
              ),
              _box,
              _buildText(
                'О себе: в данной категории будут предложения о добавлении важных пунктов о вас. ', true,
              ),
              _box,
              _buildText(
                'Опыт работы: в данной категории будут рекомендации о том, как лучше рассказать о вашем опыте работы. ', true,
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
                onPressed: () {
                  switch (index) {
                    case 0:
                      return setState(() {
                        isScanningFix = true;
                      });
                    case 1:
                      return setState(() {
                        isScanningStructure = true;
                      });
                    case 2:
                      setState(() {
                        isScanningContent = true;
                      });
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
              color: borderWindowColor,
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
        Divider(
          color: lightViolet.withOpacity(0.5),
          thickness: 2,
        ),
        SizedBox(height: space / 2),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:
                index == 0
                    ? [
                      _buildButton('Орфография', () {
                        setState(() {
                          isScanningSpell = true;
                        });
                      }),
                      _buildButton('Пунктуация', () {
                        setState(() {
                          isScanningPunctuation = true;
                        });
                      }),
                      _buildButton('Грамматика', () {
                        setState(() {
                          isScanningGrammar = true;
                        });
                      }),
                      _buildButton('Стилевые ошибки', () {
                        setState(() {
                          isScanningStyle = true;
                        });
                      }),
                    ]
                    : [
                      _buildButton('Навыки', () {
                        setState(() {
                          isScanningSkills = true;
                        });
                      }),
                      _buildButton('О себе', () {
                        setState(() {
                          isScanningAboutMe = true;
                        });
                      }),
                      _buildButton('Опыт работы', () {
                        setState(() {
                          isScanningExperience = true;
                        });
                      }),
                    ],
          ),
        ),
        SizedBox(height: space),
      ],
    );
  }

  Widget _buildButton(String text, onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
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
      child: Text(
        text,
        style: TextStyle(
          color: midnightPurple,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
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

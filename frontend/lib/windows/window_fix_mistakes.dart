import 'package:flutter/material.dart';
import 'package:vkatun/design/colors.dart';
import 'package:vkatun/design/dimensions.dart';
import 'package:vkatun/design/images.dart';

class WindowFixMistakes extends StatefulWidget {
  final VoidCallback onClose;
  final AnimationController rotationController;

  const WindowFixMistakes({
    super.key,
    required this.onClose,
    required this.rotationController,
  });

  @override
  State<WindowFixMistakes> createState() => _WindowFixMistakesState();
}

class _WindowFixMistakesState extends State<WindowFixMistakes> {
  int selectedIndex = 0;
  bool isScanning = false;

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
                              duration: const Duration(milliseconds: timeShowAnimation),
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
                          duration: const Duration(milliseconds: 300),
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
        return isScanning ? _scan() : _buildPage();
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
        SizedBox(height: 20,),
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
          )
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
        Spacer(),
        ElevatedButton(
          onPressed: () {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => EntryPage()),
            // );
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
            'Орфография',
            style: TextStyle(
              color: midnightPurple,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Spacer(),
        ElevatedButton(
          onPressed: () {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => EntryPage()),
            // );
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
            'Пунктуация',
            style: TextStyle(
              color: midnightPurple,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Spacer(),
        ElevatedButton(
          onPressed: () {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => EntryPage()),
            // );
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
            'Грамматика',
            style: TextStyle(
              color: midnightPurple,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Spacer(),
        ElevatedButton(
          onPressed: () {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => EntryPage()),
            // );
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
            'Стилевые ошибки',
            style: TextStyle(
              color: midnightPurple,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Spacer(),
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

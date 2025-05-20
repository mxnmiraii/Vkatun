import 'package:flutter/material.dart';
import 'package:vkatun/design/dimensions.dart';
import 'package:vkatun/design/images.dart';
import '../design/colors.dart';

class OnboardingContent extends StatefulWidget {
  final VoidCallback closeOnboarding;
  final GlobalKey addIconKey;

  const OnboardingContent({
    required this.closeOnboarding,
    required this.addIconKey,
  });

  @override
  State<OnboardingContent> createState() => _OnboardingContentState();
}

class _OnboardingContentState extends State<OnboardingContent> {
  static const _textStyle = TextStyle(
    fontSize: 16,
    fontFamily: 'Playfair',
    fontWeight: FontWeight.w800,
    color: midnightPurple,
  );

  static final _blueButtonStyle = ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
    backgroundColor: onboardingButtonColorBlue,
    foregroundColor: Colors.white,
    side: BorderSide.none,
    textStyle: const TextStyle(
      fontFamily: 'Playfair',
      fontWeight: FontWeight.w800,
      fontSize: 15,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  static final _violetButtonStyle = OutlinedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
    backgroundColor: onboardingButtonColorViolet,
    foregroundColor: midnightPurple,
    side: BorderSide.none,
    textStyle: const TextStyle(
      fontFamily: 'Playfair',
      fontWeight: FontWeight.w800,
      fontSize: 15,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  bool _isFirstStep = true;

  String get _currentText => _isFirstStep
      ? 'Привет! Здесь начинается наш путь знакомства. '
      'Я расскажу тебе, как пользоваться нашим приложением. Хорошо?'
      : 'Давай загрузим твое первое резюме!';

  String get _mainButtonText => _isFirstStep ? 'Да, конечно' : 'Хорошо!';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Фон с эффектом подсветки
          if (!_isFirstStep) _buildSpotlightEffect(),

          // Основной контент онбординга
          Positioned(
            bottom: bottom35 * 2 + 80,
            left: bottom35,
            right: bottom35,
            child: Material(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_currentText, style: _textStyle),
                    const SizedBox(height: 16),
                    _isFirstStep
                        ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: widget.closeOnboarding,
                            style: _violetButtonStyle,
                            child: const Text('Нет, я сам'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => setState(() => _isFirstStep = false),
                            style: _blueButtonStyle,
                            child: Text(
                              _mainButtonText,
                              style: _textStyle.copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    )
                        : SizedBox(
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: widget.closeOnboarding,
                            style: _blueButtonStyle,
                            child: Text(
                              _mainButtonText,
                              style: _textStyle.copyWith(color: Colors.white),
                            ),
                          ),
                          const Spacer(),
                        ],
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

  Widget _buildSpotlightEffect() {
    final renderBox = widget.addIconKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return const SizedBox();

    final targetPosition = renderBox.localToGlobal(Offset.zero);
    final targetSize = renderBox.size;

    // Центр вырезанной области (не кнопки!)
    final center = Offset(
      targetPosition.dx + targetSize.width / 2,
      targetPosition.dy + targetSize.height / 2,
    );

    return Stack(
      children: [
        // Затемнение фона с "дыркой"
        Positioned.fill(
          child: CustomPaint(
            painter: _SpotlightPainter(
              targetKey: widget.addIconKey,
              context: context,
            ),
          ),
        ),

        Positioned(
          left: center.dx - targetSize.width / 2,
          top: center.dy - targetSize.height / 2,
          child: SizedBox(
            width: targetSize.width,
            height: targetSize.height,
            child: addIcon
          ),
        ),
      ],
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final GlobalKey targetKey;
  final BuildContext context;

  _SpotlightPainter({
    required this.targetKey,
    required this.context,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final renderBox = targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final targetSize = renderBox.size;
    final targetPosition = renderBox.localToGlobal(Offset.zero);

    // Центр кнопки
    final center = Offset(
      targetPosition.dx + targetSize.width / 2,
      targetPosition.dy + targetSize.height / 2,
    );

    // Радиус круга - на 10% больше размера кнопки
    final radius = (targetSize.width + targetSize.height) / 2 * 0.6;

    // Сначала рисуем полупрозрачный черный фон (теперь это будет цвет кнопки)
    final backgroundPaint = Paint()
      ..color = backgroundOnboarding.withOpacity(0) // Бывший цвет кнопки теперь для фона
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    // Затем "вырезаем" круг, используя Path.combine
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final circlePath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));

    final combinedPath = Path.combine(
      PathOperation.difference,
      path,
      circlePath,
    );

    // Теперь круг (кнопка) будет с цветом, который был у фона
    final paint = Paint()
      ..color = backgroundOnboarding.withOpacity(0) // Бывший цвет фона теперь для кнопки
      ..style = PaintingStyle.fill;

    canvas.drawPath(combinedPath, paint);

    // Дополнительно рисуем сам круг (кнопку) нужным цветом
    final buttonPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, buttonPaint);


  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) => false;
}
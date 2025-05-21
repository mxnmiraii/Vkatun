import 'package:flutter/material.dart';
import 'package:vkatun/design/dimensions.dart';
import 'package:vkatun/design/images.dart';
import '../design/colors.dart';

class OnboardingContent extends StatefulWidget {
  final VoidCallback? closeOnboarding;
  final VoidCallback hideOnboarding;
  final GlobalKey iconKey;
  final bool isFirstBigStep;
  final bool isSecondBigStep;
  final bool isThirdBigStep;
  final bool isFourthBigStep;
  final bool isFifthBigStep;
  final bool isSixthBigStep;

  const OnboardingContent({
    super.key,
    this.closeOnboarding,
    required this.hideOnboarding,
    required this.iconKey,
    this.isFirstBigStep = true,
    this.isSecondBigStep = false,
    this.isThirdBigStep = false,
    this.isFourthBigStep = false,
    this.isFifthBigStep = false,
    this.isSixthBigStep = false,
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
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  bool _isFirstStep = true;
  bool _isThirdStep = true;

  String get _currentText =>
      _isFirstStep
          ? 'Привет! Здесь начинается наш путь знакомства. '
              'Я расскажу тебе, как пользоваться нашим приложением. Хорошо?'
          : 'Давай загрузим твое первое резюме!';

  String get _mainButtonText => _isFirstStep ? 'Да, конечно' : 'Хорошо!';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body:
          widget.isFirstBigStep
              ? Stack(
                children: [
                  if (!_isFirstStep) _buildSpotlightEffect(addIcon),

                  // Основной контент онбординга
                  Positioned(
                    bottom: bottom35 * 2 + 80,
                    left: bottom35,
                    right: bottom35,
                    child: Material(
                      borderRadius: BorderRadius.circular(19),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                        onPressed:
                                            () => setState(
                                              () => _isFirstStep = false,
                                            ),
                                        style: _blueButtonStyle,
                                        child: Text(
                                          _mainButtonText,
                                          style: _textStyle.copyWith(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                                : SizedBox(
                                  child: Row(
                                    children: [
                                      ElevatedButton(
                                        onPressed: widget.hideOnboarding,
                                        style: _blueButtonStyle,
                                        child: Text(
                                          _mainButtonText,
                                          style: _textStyle.copyWith(
                                            color: Colors.white,
                                          ),
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
              )
              : widget.isSecondBigStep
              ? Stack(
                children: [
                  // if (!_isFirstStep) _buildSpotlightEffect(),
                  _isThirdStep
                      ? Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: bottom35),
                          child: Material(
                            borderRadius: BorderRadius.circular(19),
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Здесь можно проверить свое резюме и отредактировать, если нужно!',
                                    style: _textStyle,
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      ElevatedButton(
                                        onPressed:
                                            () => setState(
                                              () => _isThirdStep = false,
                                            ),
                                        style: _blueButtonStyle,
                                        child: Text(
                                          'Отлично!',
                                          style: _textStyle.copyWith(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                      : Stack(
                        children: [
                          _buildSpotlightEffect(forwardIconWBg),
                          Positioned(
                            left: bottom35,
                            right: bottom35,
                            top: MediaQuery.of(context).size.height * 0.2 + 80,
                            child: Material(
                              borderRadius: BorderRadius.circular(19),
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Данные можно отредактировать нажав на стрелку. Попробуй!',
                                      style: _textStyle,
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        ElevatedButton(
                                          onPressed: widget.hideOnboarding,
                                          style: _blueButtonStyle,
                                          child: Text(
                                            'Давай!',
                                            style: _textStyle.copyWith(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        Spacer(),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                ],
              )
              : widget.isThirdBigStep
              ? Stack(
                children: [
                  _buildSpotlightEffect(doneIcon),
                  Positioned(
                    left: bottom35,
                    right: bottom35,
                    bottom: bottom35 * 2 + 80,
                    child: Material(
                      borderRadius: BorderRadius.circular(19),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'После просмотра или редактирования резюме не забудь сохранить! '
                              'Для этого нажми на эту кнопку здесь и на предыдущем экране!',
                              style: _textStyle,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: widget.hideOnboarding,
                                  style: _blueButtonStyle,
                                  child: Text(
                                    'Хорошо!',
                                    style: _textStyle.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Spacer(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
              : widget.isFourthBigStep
              ? Stack(
                children: [
                  _buildSpotlightEffect(doneIcon),
                  Positioned(
                    left: bottom35,
                    right: bottom35,
                    bottom: bottom35 * 2 + 80,
                    child: Material(
                      borderRadius: BorderRadius.circular(19),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'После просмотра или редактирования резюме не забудь сохранить! '
                              'Для этого нажми на эту кнопку здесь!',
                              style: _textStyle,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: widget.hideOnboarding,
                                  style: _blueButtonStyle,
                                  child: Text(
                                    'Хорошо!',
                                    style: _textStyle.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Spacer(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
              : widget.isFifthBigStep
              ? Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: bottom35),
                  child: Material(
                    borderRadius: BorderRadius.circular(19),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Поздравляю! Ты загрузил свое первое резюме! Нажми на него, чтобы отредактировать.',
                            style: _textStyle,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: widget.hideOnboarding,
                                style: _blueButtonStyle,
                                child: Text(
                                  'Хорошо!',
                                  style: _textStyle.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Spacer(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              : widget.isSixthBigStep
              ? Stack(
                children: [
                  _buildSpotlightEffect(magicIcon),
                  Positioned(
                    left: bottom35,
                    right: bottom35,
                    bottom: bottom35 * 2 + 80,
                    child: Material(
                      borderRadius: BorderRadius.circular(19),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Отлично, теперь нажми на эту кнопку, чтобы посмотреть рекомендации '
                              'для улучшения твоего резюме!',
                              style: _textStyle,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: widget.hideOnboarding,
                                  style: _blueButtonStyle,
                                  child: Text(
                                    'Хорошо!',
                                    style: _textStyle.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Spacer(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
              : Stack(),
    );
  }

  Widget _buildSpotlightEffect(icon) {
    final renderBox =
        widget.iconKey.currentContext?.findRenderObject() as RenderBox?;
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
        Positioned.fill(
          child: CustomPaint(
            painter: _SpotlightPainter(
              targetKey: widget.iconKey,
              context: context,
            ),
          ),
        ),

        Positioned(
          left: center.dx - 36,
          top: center.dy - 36,
          child: SizedBox(
            width: 72,
            height: 72,
            child: FittedBox(fit: BoxFit.contain, child: icon),
          ),
        ),
      ],
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final GlobalKey targetKey;
  final BuildContext context;

  _SpotlightPainter({required this.targetKey, required this.context});

  @override
  void paint(Canvas canvas, Size size) {
    final renderBox =
        targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final targetSize = renderBox.size;
    final targetPosition = renderBox.localToGlobal(Offset.zero);

    final center = Offset(
      targetPosition.dx + targetSize.width / 2,
      targetPosition.dy + targetSize.height / 2,
    );

    final radius = (targetSize.width + targetSize.height) / 2 * 0.6;

    final backgroundPaint =
        Paint()
          ..color = backgroundOnboarding.withOpacity(0)
          ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );

    final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final circlePath =
        Path()..addOval(Rect.fromCircle(center: center, radius: radius));

    final combinedPath = Path.combine(
      PathOperation.difference,
      path,
      circlePath,
    );

    final paint =
        Paint()
          ..color = backgroundOnboarding.withOpacity(0)
          ..style = PaintingStyle.fill;

    canvas.drawPath(combinedPath, paint);

    final buttonPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.75)
          ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, buttonPaint);
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) => false;
}

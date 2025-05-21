import 'package:flutter/material.dart';
import 'package:vkatun/design/colors.dart';
import 'package:vkatun/design/dimensions.dart';
import 'package:vkatun/design/images.dart';
import 'package:vkatun/pages/register_page.dart';
import 'package:vkatun/pages/resumes_page.dart';

import 'entry_page.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      color: blue,
      fontFamily: 'Playfair',
      fontSize: 22,
      fontWeight: FontWeight.w700,
      // letterSpacing: -1.1,
      height: 1.5,
    );

    const backgroundButtonColor = mediumSlateBlue;

    final screenHeight = MediaQuery.of(context).size.height;
    final backgroundHeight = screenHeight * 0.65;
    final appBarHeight = screenHeight * 0.15;
    final backgroundColorWater = waterBackground.withOpacity(0.21);
    final buttonHeight = screenHeight * 0.07;

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: backgroundColorWater,
        automaticallyImplyLeading: false,
        toolbarHeight: appBarHeight,
        title: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: arrowBackIcon,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Center(child: logoFullIcon),
          ],
        ),
        centerTitle: true,
        elevation: 0,
      ),

      body: Stack(
        children: [
          // Фоновая закругленная форма
          ClipPath(
            clipper: BottomCurveClipper(),
            child: Container(
              height: backgroundHeight, // Высота изогнутого фона
              color: backgroundColorWater, // Цвет фона (как на твоем макете)
            ),
          ),

          Transform.translate(
            offset: Offset(0, -appBarHeight / 2),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  signUp,
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        Text(
                          'Создай свое идеальное резюме',
                          style: textStyle,
                          textAlign: TextAlign.center,
                        ),

                        Text(
                          'вместе с нами',
                          style: textStyle,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
                  ),
                  const SizedBox(height: 64),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: buttonMargin / 2,
              padding: const EdgeInsets.symmetric(horizontal: buttonPaddingHorizontal),
              child: IntrinsicHeight( // Добавляем IntrinsicHeight для правильного отображения VerticalDivider
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded( // Равномерно распределяем пространство
                          child: ElevatedButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => EntryPage()),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: backgroundButtonColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(borderRadius),
                              ),
                              minimumSize: Size(50, buttonHeight),
                              padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Войти',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),

                        SizedBox(
                          height: buttonHeight,
                          child: VerticalDivider(
                            color: waterBackground,
                            thickness: 3,
                            width: 48,
                          ),
                        ),

                        Expanded( // Равномерно распределяем пространство
                          child: ElevatedButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => RegisterPage()),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              minimumSize: Size(50, buttonHeight),
                              padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Создать аккаунт',
                              style: TextStyle(
                                color: electricVioletBlue,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0,
                                height: 1.0,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: bottom35),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 120);

    path.quadraticBezierTo(
      size.width * 0.7, size.height,
      size.width, size.height - 70,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}


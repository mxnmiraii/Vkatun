import 'package:flutter/material.dart';
import 'package:vkatun/design/colors.dart';
import 'package:vkatun/design/dimensions.dart';
import 'package:vkatun/design/images.dart';
import 'package:vkatun/pages/resumes_page.dart';

import 'entry_page.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      color: midnightPurple,
      fontFamily: 'Playfair',
      fontSize: 20,
      fontWeight: FontWeight.w700,
      // letterSpacing: -1.1,
      height: 1.5,
    );

    const borderButtonColor = royalPurple;
    const backgroundButtonColor = lightLavender;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                startSignUpImage,
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Text('Войдите или зарегистрируйтесь,', style: textStyle, textAlign: TextAlign.center),
                      Text('чтобы пользоваться всеми функциями', style: textStyle, textAlign: TextAlign.center,),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: buttonMargin,
              padding: const EdgeInsets.symmetric(horizontal: buttonPaddingHorizontal),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EntryPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  side: BorderSide(
                    color: borderButtonColor,
                    width: widthBorderRadius,
                  ),
                  backgroundColor: backgroundButtonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                  padding: buttonPadding,
                  elevation: 0,
                ),
                child: const Text(
                  'Войти или зарегистрироваться',
                  style: TextStyle(
                    color: midnightPurple,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
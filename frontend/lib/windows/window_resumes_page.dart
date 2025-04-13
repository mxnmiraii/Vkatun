import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vkatun/design/colors.dart';
import 'package:vkatun/design/dimensions.dart';

class WindowResumesPage extends StatelessWidget {
  const WindowResumesPage({super.key});

  @override
  Widget build(BuildContext context) {
    const borderWindowColor = royalPurple;
    const windowColor = lightLavender;
    const padding = 20.0;
    const buttonColor = cosmicBlue;

    final textStyle = TextStyle(
      color: buttonColor,
      fontFamily: 'Playfair',
      // letterSpacing: -1.1,
      height: 1.0,
    );

    return Dialog(
      insetPadding: const EdgeInsets.all(30),
      child: Container(
        padding: const EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: windowColor,
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
            Container(
              padding: const EdgeInsets.symmetric(vertical: padding / 2, horizontal: padding),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: borderWindowColor,
                  width: widthBorderRadius,
                )
              ),
              child: Text(
                'Резюме',
                style: textStyle.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: 30,),

            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                side: BorderSide(
                  color: borderWindowColor,
                  width: widthBorderRadius,
                ),

                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),

                minimumSize: const Size(double.infinity, 50),
                elevation: 0,
              ),
              child: Text(
                'Редактировать резюме',
                style: textStyle.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                side: BorderSide(
                  color: borderWindowColor,
                  width: widthBorderRadius,
                ),

                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),

                minimumSize: const Size(double.infinity, 50),
                elevation: 0,
              ),
              child: Text(
                'Экспорт резюме',
                style: textStyle.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                side: BorderSide(
                  color: borderWindowColor,
                  width: widthBorderRadius,
                ),

                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),

                minimumSize: const Size(double.infinity, 50),
                elevation: 0,
              ),
              child: Text(
                'Удалить резюме',
                style: textStyle.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

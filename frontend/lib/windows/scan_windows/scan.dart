import 'package:flutter/material.dart';
import 'package:vkatun/design/colors.dart';
import 'package:vkatun/design/dimensions.dart';
import 'package:vkatun/design/images.dart';

import 'check_widget.dart';

class Scan extends StatelessWidget {
  final VoidCallback onBackPressed;
  final VoidCallback onClose;
  final Map<String, dynamic> resume;
  final String title;
  final List<Issue> issues;
  const Scan({
    super.key,
    required this.onBackPressed,
    required this.onClose,
    required this.resume,
    required this.title,
    required this.issues,
  });

  @override
  Widget build(BuildContext context) {
    const borderWindowColor = royalPurple;
    const padding = 12.0;
    const buttonColor = cosmicBlue;

    final textStyle = TextStyle(
      color: buttonColor,
      fontFamily: 'Playfair',
      height: 1.0,
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(onPressed: onBackPressed, icon: backCircleIcon),

            Container(
              padding: const EdgeInsets.symmetric(
                vertical: padding / 2 * 1.5,
                horizontal: padding / 2 * 1.5,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: borderWindowColor.withOpacity(0.47),
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
          ],
        ),
        SizedBox(height: 20),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return CheckWidget(
                availableHeight: constraints.maxHeight - 114,
                onClose: onClose,
                resume: resume,
                issues: issues,
              );
            },
          ),
        ),
      ],
    );
  }
}

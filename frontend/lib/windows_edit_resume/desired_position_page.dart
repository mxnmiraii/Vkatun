import 'package:flutter/material.dart';
import 'package:vkatun/design/colors.dart';
import 'package:vkatun/design/dimensions.dart';
import 'package:vkatun/design/images.dart';

class DesiredPositionPage extends StatefulWidget {
  const DesiredPositionPage({super.key});

  @override
  State<DesiredPositionPage> createState() => _DesiredPositionPageState();
}

class _DesiredPositionPageState extends State<DesiredPositionPage> {
  final TextEditingController _positionController = TextEditingController();

  @override
  void dispose() {
    _positionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = screenHeight * 0.23 / 2;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: Container(
          decoration: const BoxDecoration(
            color: veryPaleBlue,
            boxShadow: [
              BoxShadow(
                color: Color(0x1A000000),
                offset: Offset(0, 4),
                blurRadius: 8,
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            toolbarHeight: appBarHeight,
            automaticallyImplyLeading: false,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Container(
              alignment: Alignment.topCenter,
              height: appBarHeight,
              padding: const EdgeInsets.only(top: 39),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: backIconWBg,
                  ),
                  Text(
                    'Желаемая должность',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      fontFamily: 'Playfair',
                      color: midnightPurple,
                    ),
                  ),
                  Opacity(opacity: 0, child: backIconWBg),
                ],
              ),
            ),
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: buttonPaddingVertical),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 36),
            Text(
              'Должность',
              style: const TextStyle(
                fontFamily: 'Playfair',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: mediumGray,
              ),
            ),
            const SizedBox(height: 2), // меньшее расстояние
            TextField(
              controller: _positionController,
              style: const TextStyle(
                fontFamily: "NotoSans",
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: black,
              ),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: lightGray),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: lightGray),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: gray),
                ),
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: bottom35),
        child: IconButton(
          icon: biggerDoneIcon,
          onPressed: () {
            Navigator.pop(context); // Тут можно добавить логику сохранения
          },
          iconSize: 72,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

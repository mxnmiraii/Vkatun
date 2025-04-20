import 'package:flutter/material.dart';
import 'package:vkatun/design/colors.dart';
import 'package:vkatun/design/dimensions.dart';
import 'package:vkatun/design/images.dart';

class AboutMePage extends StatefulWidget {
  const AboutMePage({super.key});

  @override
  State<AboutMePage> createState() => _AboutMePageState();
}

class _AboutMePageState extends State<AboutMePage> {
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _patronymicController = TextEditingController();

  @override
  void dispose() {
    _surnameController.dispose();
    _nameController.dispose();
    _patronymicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _textStyle = TextStyle(
      color: midnightPurple,
      fontFamily: 'Playfair',
      height: 1.0,
    );

    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = screenHeight * 0.15 / 2;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: Container(
          decoration: const BoxDecoration(
            color: veryPaleBlue, // основной цвет AppBar
            boxShadow: [
              BoxShadow(
                color: Color(0x1A000000), // черная тень с 10% прозрачностью
                offset: Offset(0, 4),     // вниз на 4 пикселя
                blurRadius: 8,            // мягкая тень
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent, // чтобы тень была видна
            toolbarHeight: appBarHeight,
            automaticallyImplyLeading: false,
            elevation: 0, // отключаем встроенную тень
            scrolledUnderElevation: 0,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: backIconWBg,
                ),
                Text(
                  'ФИО',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
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

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: buttonPaddingVertical),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 36),

            _buildTextField(
              label: 'Фамилия',

              controller: _surnameController,
            ),

            const SizedBox(height: 20),

            _buildTextField(
              label: 'Имя',
              controller: _nameController,
            ),

            const SizedBox(height: 20),

            _buildTextField(
              label: 'Отчество',
              controller: _patronymicController,
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: bottom35),
        child: IconButton(
          icon: doneIcon,
          onPressed: () {
            Navigator.pop(context);
          },
          iconSize: 36, // Можно настроить размер иконки
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Playfair',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: mediumGray,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
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
    );
  }
}

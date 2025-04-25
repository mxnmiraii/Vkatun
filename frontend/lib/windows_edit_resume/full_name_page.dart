import 'package:flutter/material.dart';
import 'package:vkatun/design/colors.dart';
import 'package:vkatun/design/dimensions.dart';
import 'package:vkatun/design/images.dart';

class FullNamePage extends StatefulWidget {
  const FullNamePage({super.key});

  @override
  State<FullNamePage> createState() => _FullNamePageState();
}

class _FullNamePageState extends State<FullNamePage> {
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
              padding: const EdgeInsets.only(top: 38), // вот этот отступ точно работает
              child: Row(
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
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: buttonPaddingVertical),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 36),

            _buildTextField(label: 'Фамилия', controller: _surnameController),

            const SizedBox(height: 20),

            _buildTextField(
                label: 'Имя',
                controller: _nameController
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
          icon: biggerDoneIcon,
          onPressed: () {
            Navigator.pop(context);
          },
          iconSize: 72, // Можно настроить размер иконки
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
        const SizedBox(height: 0),
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

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
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = screenHeight * 0.23 / 2;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: Container(
          color: Colors.white,
          child: AppBar(
            backgroundColor: Colors.transparent,
            toolbarHeight: appBarHeight,
            automaticallyImplyLeading: false,
            elevation: 0, // убрали тень
            scrolledUnderElevation: 0,
            title: Container(
              alignment: Alignment.topCenter,
              height: appBarHeight,
              padding: const EdgeInsets.only(top: 38),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: backIconWBg,
                  ),
                  const Text(
                    'ФИО',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                      fontFamily: 'Playfair',
                      color: Color(0xFF2C2C86),
                    ),
                  ),
                  Opacity(opacity: 0, child: backIconWBg),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8F9FF),
              Color(0xFFE6EDFF),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 24),
          child: Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white, // чисто белый фон
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Color(0xFF979CFF), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Color(0x4D979CFF),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildTextField(label: 'Фамилия', controller: _surnameController),
                const SizedBox(height: 16),
                _buildTextField(label: 'Имя', controller: _nameController),
                const SizedBox(height: 16),
                _buildTextField(label: 'Отчество', controller: _patronymicController),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 35),
        child: SizedBox(
          width: 72,
          height: 72,
          child: IconButton(
            icon: circleWithPenIcon,
            onPressed: () {
              Navigator.pop(context);
            },
            padding: EdgeInsets.zero,
            splashRadius: 36,
          ),
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
            fontWeight: FontWeight.w700,
            color: Color(0xFF6A6AFF),
          ),
        ),
        TextField(
          controller: controller,
          style: const TextStyle(
            fontFamily: "NotoSans",
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 10),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF6A6AFF)),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF6A6AFF)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF2C2C86)),
            ),
          ),
        ),
      ],
    );
  }
}

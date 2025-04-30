import 'package:flutter/material.dart';
import 'package:vkatun/design/colors.dart';
import 'package:vkatun/design/dimensions.dart';
import 'package:vkatun/design/images.dart';

class FullNamePage extends StatefulWidget {
  final List<String> data;
  const FullNamePage({super.key, required this.data});

  @override
  State<FullNamePage> createState() => _FullNamePageState();
}

class _FullNamePageState extends State<FullNamePage> {
  late TextEditingController _surnameController = TextEditingController();
  late TextEditingController _nameController = TextEditingController();
  late TextEditingController _patronymicController = TextEditingController();

  @override
  void dispose() {
    _surnameController.dispose();
    _nameController.dispose();
    _patronymicController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _surnameController = TextEditingController(text: widget.data.isNotEmpty ? widget.data[0] : '');
    _nameController = TextEditingController(text: widget.data.length > 1 ? widget.data[1] : '');
    _patronymicController = TextEditingController(text: widget.data.length > 2 ? widget.data[2] : '');
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = screenHeight * 0.1;
    final screenWidth = MediaQuery.of(context).size.width;
    final space = screenWidth * 0.05;

    return Scaffold(
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: Container(
          color: Colors.white,
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            toolbarHeight: appBarHeight,
            centerTitle: false,
            title: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      SizedBox(width: space),
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: lightArrowBackIcon),
                    ],
                  ),
                ),

                Center(
                  child: Text(
                    'ФИО',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                      fontFamily: 'Playfair',
                      color: purpleBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      body: Stack(
        children: [
          // Градиент на фоне
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.8, -0.1), // правый край, чуть выше центра
                radius: 1.6,
                colors: [
                  Color(0xFFD8D7FF), // начало
                  Color(0xFFE9F7FA), // середина
                  Color(0xFFFFFFFF), // конец
                ],
                stops: [0.0, 0.75, 0.95],
              ),
            ),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.only(top: 24),
            child: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: vividPeriwinkleBlue.withOpacity(0.8), // прозрачность
                  width: 1.6,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.30),
                    blurRadius: 2,
                    spreadRadius: 0.2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildTextField(
                    label: 'Фамилия',
                    controller: _surnameController,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                      label: 'Имя',
                      controller: _nameController),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Отчество',
                    controller: _patronymicController,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: bottom35),
        child: SizedBox(
          child: IconButton(
            icon: darkerBiggerDoneIcon,
            onPressed: () {
              // ОБРАЩЕНИЕ К БД И ИЗМЕНЕНИЕ
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
            fontWeight: FontWeight.w800,
            color: lavenderBlue,
          ),
        ),
        TextField(
          controller: controller,
          style: const TextStyle(
            fontFamily: "NotoSans",
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: black,
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.only(
              top: 7,
              bottom: 14,
            ), // Уменьшаем отступы сверху и снизу
            border: UnderlineInputBorder(
              borderSide: BorderSide(
                color: lightDarkenLavender, // Цвет полоски
                width: 2.5,
              ),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: lightDarkenLavender, width: 2.5),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: lightDarkenLavender, width: 2.5),
            ),
          ),
        ),
      ],
    );
  }
}



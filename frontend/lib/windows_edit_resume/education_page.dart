import 'package:flutter/material.dart';
import 'package:vkatun/design/colors.dart';
import 'package:vkatun/design/dimensions.dart';
import 'package:vkatun/design/images.dart';

class EducationPage extends StatefulWidget {
  final List<String> data;
  const EducationPage({super.key, required this.data});

  @override
  State<EducationPage> createState() => _EducationPageState();
}

class _EducationPageState extends State<EducationPage> {
  late TextEditingController _institutionController;
  late TextEditingController _specializationController;
  late TextEditingController _facultyController;
  late TextEditingController _graduationYearController;

  @override
  void dispose() {
    _institutionController.dispose();
    _specializationController.dispose();
    _facultyController.dispose();
    _graduationYearController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    final data = widget.data;

    _institutionController = TextEditingController(
      text: data.isNotEmpty ? data[0] : '',
    );
    _facultyController = TextEditingController(
      text: data.length > 1 ? data[1] : '',
    );
    _specializationController = TextEditingController(
      text: data.length > 2 ? data[2] : '',
    );
    _graduationYearController = TextEditingController(
      text: data.length > 3 ? _extractYear(data[3]) : '',
    );
  }

  String _extractYear(String input) {
    final match = RegExp(r'\b(19|20)\d{2}\b').firstMatch(input);
    return match?.group(0) ?? '';
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
                        icon: lightArrowBackIcon,
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Text(
                    'Образование',
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
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.8, -0.1),
                radius: 1.6,
                colors: [
                  Color(0xFFD8D7FF),
                  Color(0xFFE9F7FA),
                  Color(0xFFFFFFFF),
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
                  color: vividPeriwinkleBlue.withOpacity(0.8),
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
                    label: 'Название учебного заведения',
                    controller: _institutionController,
                    index: 0,
                    length: widget.data.length,
                  ),

                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Факультет',
                    controller: _facultyController,
                    index: 2,
                    length: widget.data.length,
                  ),

                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Специализация',
                    controller: _specializationController,
                    index: 1,
                    length: widget.data.length,
                  ),

                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Год окончания',
                    controller: _graduationYearController,
                    index: 3,
                    length: widget.data.length,
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
    required int index,
    required int length,
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
        index + 1 != length
            ? TextField(
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
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(
                color: lightDarkenLavender,
                width: 2.5,
              ),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: lightDarkenLavender,
                width: 2.5,
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: lightDarkenLavender,
                width: 2.5,
              ),
            ),
          ),
        )
            : TextField(
          controller: controller,
          style: const TextStyle(
            fontFamily: "NotoSans",
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: black,
          ),
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.only(
              top: 7,
              bottom: 14,
            ),
            border: InputBorder.none,
          ),
        ),
      ],
    );
  }
}
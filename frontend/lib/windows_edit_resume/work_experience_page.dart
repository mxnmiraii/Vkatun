import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vkatun/design/colors.dart';
import 'package:vkatun/design/dimensions.dart';
import 'package:vkatun/design/images.dart';

class WorkExperiencePage extends StatefulWidget {
  final List<String> data;
  const WorkExperiencePage({super.key, required this.data});

  @override
  State<WorkExperiencePage> createState() => _WorkExperiencePageState();
}

class _WorkExperiencePageState extends State<WorkExperiencePage> {
  late TextEditingController _startDateController = TextEditingController();
  late TextEditingController _endDateController = TextEditingController();
  late TextEditingController _companyController = TextEditingController();
  late TextEditingController _positionController = TextEditingController();
  late TextEditingController _dutiesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final data = widget.data;

    _startDateController = TextEditingController(text: data.isNotEmpty ? data[0] : '');
    _endDateController = TextEditingController(text: data.length > 1 ? data[1] : '');
    _companyController = TextEditingController(text: data.length > 2 ? data[2] : '');
    _positionController = TextEditingController(text: data.length > 3 ? data[3] : '');
    _dutiesController = TextEditingController(text: data.length > 4 ? data[4] : '');
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _companyController.dispose();
    _positionController.dispose();
    _dutiesController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    if (_startDateController.text.trim().isEmpty) {
      _showError('Введите дату начала работы');
      return false;
    }
    if (_endDateController.text.trim().isEmpty) {
      _showError('Введите дату окончания работы');
      return false;
    }
    if (_companyController.text.trim().isEmpty) {
      _showError('Введите название компании');
      return false;
    }
    if (_positionController.text.trim().isEmpty) {
      _showError('Введите должность');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = screenHeight * 0.1;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: SafeArea(
          bottom: false,
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
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: lightArrowBackIcon,
                    ),
                  ),
                  Center(
                    child: Text(
                      'Опыт работы',
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
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildTextField(
                    label: 'Начало работы',
                    controller: _startDateController,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Окончание',
                    controller: _endDateController,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Название компании',
                    controller: _companyController,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Должность',
                    controller: _positionController,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Обязанности',
                    controller: _dutiesController,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: bottom35),
        child: IconButton(
          icon: darkerBiggerDoneIcon,
          onPressed: () {
            if (_validateInputs()) {
              Navigator.pop(context);
            }
          },
          padding: EdgeInsets.zero,
          splashRadius: 36,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool noUnderline = false,
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
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          style: const TextStyle(
            fontFamily: "NotoSansBengali",
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: black,
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.only(top: 7, bottom: 14),
            border: noUnderline
                ? InputBorder.none
                : UnderlineInputBorder(
              borderSide: BorderSide(
                color: lightDarkenLavender,
                width: 2.5,
              ),
            ),
            enabledBorder: noUnderline
                ? InputBorder.none
                : UnderlineInputBorder(
              borderSide: BorderSide(
                color: lightDarkenLavender,
                width: 2.5,
              ),
            ),
            focusedBorder: noUnderline
                ? InputBorder.none
                : UnderlineInputBorder(
              borderSide: BorderSide(
                color: lightDarkenLavender,
                width: 2.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

}

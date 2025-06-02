// WorkExperiencePage.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vkatun/api_service.dart';
import 'package:vkatun/design/colors.dart';
import 'package:vkatun/design/dimensions.dart';
import 'package:vkatun/design/images.dart';

class WorkExperiencePage extends StatefulWidget {
  final List<String> data;
  final int resumeId;
  final VoidCallback onResumeChange;

  const WorkExperiencePage({
    super.key,
    required this.data,
    required this.resumeId,
    required this.onResumeChange,
  });

  @override
  State<WorkExperiencePage> createState() => _WorkExperiencePageState();
}

class _WorkExperiencePageState extends State<WorkExperiencePage> {
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _companyController;
  late TextEditingController _positionController;
  late TextEditingController _dutiesController;

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

  Future<void> _saveExperience() async {
    if (!_validateInputs()) return;

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);

      // Формируем новый блок опыта
      final newExperienceBlock = '''
${_startDateController.text} - ${_endDateController.text}
${_calculateDuration(_startDateController.text, _endDateController.text)}
${_companyController.text}
${_positionController.text}
${_dutiesController.text}
'''.trim();

      // Получаем текущий опыт
      final currentResume = await apiService.getResumeById(widget.resumeId);
      String currentExperience = currentResume['experience'] ?? '';

      if (widget.data.isNotEmpty && widget.data[0].isNotEmpty) {
        // Редактирование существующей записи - находим старый блок
        final oldExperienceBlock = '''
${widget.data[0]} - ${widget.data[1]}
${_calculateDuration(widget.data[0], widget.data[1])}
${widget.data[2]}
${widget.data[3]}
${widget.data.length > 4 ? widget.data[4] : ''}
'''.trim();

        // Заменяем только первое вхождение (на случай дублирования)
        currentExperience = currentExperience.replaceFirst(oldExperienceBlock, newExperienceBlock);
      } else {
        // Новая запись - добавляем с разделителем
        currentExperience = currentExperience.isEmpty
            ? newExperienceBlock
            : '$currentExperience\n\n$newExperienceBlock';
      }

      // Сохраняем
      await apiService.editResumeSection(
        id: widget.resumeId,
        section: 'experience',
        content: currentExperience,
      );

      // Обновляем родительский виджет
      widget.onResumeChange();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: ${e.toString()}')),
        );
      }
    }
  }

  String _calculateDuration(String start, String end) {
    try {
      final startParts = start.split(' ');
      final endParts = end.split(' ');

      if (startParts.length != 2 || endParts.length != 2) return '';

      final months = {
        'январь': 1, 'февраль': 2, 'март': 3, 'апрель': 4,
        'май': 5, 'июнь': 6, 'июль': 7, 'август': 8,
        'сентябрь': 9, 'октябрь': 10, 'ноябрь': 11, 'декабрь': 12
      };

      final startMonth = months[startParts[0].toLowerCase()] ?? 1;
      final startYear = int.tryParse(startParts[1]) ?? 0;
      final endMonth = months[endParts[0].toLowerCase()] ?? 1;
      final endYear = int.tryParse(endParts[1]) ?? 0;

      if (startYear == 0 || endYear == 0) return '';

      final totalMonths = (endYear - startYear) * 12 + (endMonth - startMonth) + 1;

      if (totalMonths <= 0) return '';

      final years = totalMonths ~/ 12;
      final monthsRemainder = totalMonths % 12;

      if (years > 0 && monthsRemainder > 0) {
        return '$years ${_getYearWord(years)} $monthsRemainder ${_getMonthWord(monthsRemainder)}';
      } else if (years > 0) {
        return '$years ${_getYearWord(years)}';
      } else {
        return '$monthsRemainder ${_getMonthWord(monthsRemainder)}';
      }
    } catch (e) {
      return '';
    }
  }

  String _getYearWord(int years) {
    if (years % 100 >= 11 && years % 100 <= 14) return 'лет';

    switch (years % 10) {
      case 1: return 'год';
      case 2:
      case 3:
      case 4: return 'года';
      default: return 'лет';
    }
  }

  String _getMonthWord(int months) {
    if (months % 100 >= 11 && months % 100 <= 14) return 'месяцев';

    switch (months % 10) {
      case 1: return 'месяц';
      case 2:
      case 3:
      case 4: return 'месяца';
      default: return 'месяцев';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = screenHeight * 0.1;

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
          onPressed: _saveExperience,
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
        ),
      ],
    );
  }
}
// EducationPage.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vkatun/api_service.dart';
import 'package:vkatun/design/colors.dart';
import 'package:vkatun/design/dimensions.dart';
import 'package:vkatun/design/images.dart';

class EducationPage extends StatefulWidget {
  final List<String> data;
  final int resumeId;
  final VoidCallback onResumeChange;

  const EducationPage({
    super.key,
    required this.data,
    required this.resumeId,
    required this.onResumeChange,
  });

  @override
  State<EducationPage> createState() => _EducationPageState();
}

class _EducationPageState extends State<EducationPage> {
  late TextEditingController _institutionController;
  late TextEditingController _specializationController;
  late TextEditingController _yearsController;

  @override
  void initState() {
    super.initState();
    final data = widget.data;

    _institutionController = TextEditingController(
      text: data.isNotEmpty ? data[0] : '',
    );
    _specializationController = TextEditingController(
      text: data.length > 1 ? data[1] : '',
    );
    _yearsController = TextEditingController(
      text: data.length > 2 ? data[2] : '',
    );
  }

  @override
  void dispose() {
    _institutionController.dispose();
    _specializationController.dispose();
    _yearsController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    if (_institutionController.text.trim().isEmpty) {
      _showError('Введите название учебного заведения');
      return false;
    }
    if (_specializationController.text.trim().isEmpty) {
      _showError('Введите специализацию');
      return false;
    }
    if (_yearsController.text.trim().isEmpty) {
      _showError('Введите годы обучения');
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

  Future<void> _saveEducation() async {
    if (!_validateInputs()) return;

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);

      final newEducationBlock = '''
${_institutionController.text}
${_specializationController.text}
${_yearsController.text}
'''.trim();

      final currentResume = await apiService.getResumeById(widget.resumeId);
      String currentEducation = currentResume['education'] ?? '';

      if (widget.data.isNotEmpty && widget.data[0].isNotEmpty) {
        // Находим старый блок для замены
        final oldEducationBlock = '''
${widget.data[0]}
${widget.data.length > 1 ? widget.data[1] : ''}
${widget.data.length > 2 ? widget.data[2] : ''}
'''.trim();

        currentEducation = currentEducation.replaceFirst(oldEducationBlock, newEducationBlock);
      } else {
        // Добавляем новую запись
        currentEducation = currentEducation.isEmpty
            ? newEducationBlock
            : '$currentEducation\n\n$newEducationBlock';
      }

      await apiService.editResumeSection(
        id: widget.resumeId,
        section: 'education',
        content: currentEducation,
      );

      widget.onResumeChange();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка сохранения: ${e.toString()}')),
        );
      }
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
                    label: 'Название учебного заведения',
                    controller: _institutionController,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Специализация',
                    controller: _specializationController,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Годы обучения',
                    controller: _yearsController,
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
          onPressed: _saveEducation,
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
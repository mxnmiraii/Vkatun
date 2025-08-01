import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vkatun/api_service.dart';
import 'package:vkatun/design/colors.dart';
import 'package:vkatun/design/dimensions.dart';
import 'package:vkatun/design/images.dart';

class DesiredPositionPage extends StatefulWidget {
  final List<String> data;
  final int resumeId;
  final VoidCallback? onResumeChange;

  const DesiredPositionPage({
    super.key,
    required this.data,
    required this.resumeId,
    required this.onResumeChange,
  });

  @override
  State<DesiredPositionPage> createState() => _DesiredPositionPageState();
}

class _DesiredPositionPageState extends State<DesiredPositionPage> {
  late TextEditingController _positionController = TextEditingController();

  @override
  void dispose() {
    _positionController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final newPosition = _positionController.text.trim();
    final currentPosition = widget.data.isNotEmpty ? widget.data[0] : '';

    final position = _positionController.text.trim();

    // Проверка длины
    if (position.length > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Название должности должно быть не длиннее 100 символов')),
      );
      return;
    }

    // Проверка символов (русские буквы, пробелы, дефис)
    final validChars = RegExp(r'^[а-яА-ЯёЁ\s\-,:]+$'); // разрешены пробелы, дефисы, запятые, двоеточия
    if (!validChars.hasMatch(position)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Должность может содержать только русские буквы, пробелы, дефисы, запятые и двоеточия')),
      );
      return;
    }

    // Проверяем, были ли изменения
    if (newPosition != currentPosition) {
      try {
        final apiService = Provider.of<ApiService>(context, listen: false);

        // Обновляем секцию "desired_position"
        await apiService.editResumeSection(
          id: widget.resumeId,
          section: 'job',
          content: newPosition,
        );

        // Возвращаем новые данные
        Navigator.pop(context, [newPosition]);
        widget.onResumeChange?.call();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка сохранения: ${e.toString()}')),
        );
      }
    } else {
      // Если изменений не было, просто закрываем страницу
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();

    _positionController = TextEditingController(
      text: widget.data.isNotEmpty ? widget.data[0] : '',
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
                      'Желаемая должность',
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
          // Градиент на фоне
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
              child: _buildTextField(
                label: 'Должность',
                controller: _positionController,
                index: 0,
                length: widget.data.length,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: bottom35),
        child: IconButton(
          icon: darkerBiggerDoneIcon,
          onPressed: _saveChanges,
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
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          style: const TextStyle(
            fontFamily: "NotoSansBengali",
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: black,
          ),
          maxLines: null,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.only(top: 7, bottom: 14),
            border: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: lightDarkenLavender,
                width: 2.5,
              ),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: lightDarkenLavender,
                width: 2.5,
              ),
            ),
            focusedBorder: const UnderlineInputBorder(
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
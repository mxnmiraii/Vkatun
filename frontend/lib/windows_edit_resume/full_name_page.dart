import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vkatun/design/colors.dart';
import 'package:vkatun/design/dimensions.dart';
import 'package:vkatun/design/images.dart';

import '../api_service.dart';
import '../pages/onboarding_content.dart';

class FullNamePage extends StatefulWidget {
  final List<String> data;
  final bool showOnboarding;
  final int resumeId;
  final VoidCallback? hideOnboarding;
  final GlobalKey? doneIconKey;
  final VoidCallback? onReturnFromOnboarding;
  final VoidCallback? onResumeChange;

  const FullNamePage({
    super.key,
    required this.data,
    this.showOnboarding = false,
    this.hideOnboarding,
    this.doneIconKey,
    this.onReturnFromOnboarding,
    required this.resumeId,
    required this.onResumeChange,
  });

  @override
  State<FullNamePage> createState() => _FullNamePageState();
}

class _FullNamePageState extends State<FullNamePage>
    with TickerProviderStateMixin {
  late TextEditingController _surnameController = TextEditingController();
  late TextEditingController _nameController = TextEditingController();
  late TextEditingController _patronymicController = TextEditingController();

  late final _pulseCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );
  late final _pulseAnim = _pulseCtrl.drive(
    Tween(begin: 0.95, end: 1.05).chain(CurveTween(curve: Curves.easeInOut)),
  );

  @override
  void dispose() {
    _surnameController.dispose();
    _nameController.dispose();
    _patronymicController.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final newData = [
      _surnameController.text.trim(),
      _nameController.text.trim(),
      _patronymicController.text.trim(),
    ];

    // Проверяем, были ли изменения
    bool hasChanges = false;
    for (int i = 0; i < newData.length; i++) {
      if (i < widget.data.length && newData[i] != widget.data[i] ||
          i >= widget.data.length && newData[i].isNotEmpty) {
        hasChanges = true;
        break;
      }
    }

    if (hasChanges) {
      try {
        final apiService = Provider.of<ApiService>(context, listen: false);
        final fullName = newData.join(' ');

        // Обновляем секцию "title" (ФИО)
        await apiService.editResumeSection(
          id: widget.resumeId,
          section: 'title',
          content: fullName,
        );

        // Возвращаем новые данные
        if (widget.onReturnFromOnboarding != null) {
          widget.onReturnFromOnboarding!();
        }
        Navigator.pop(context, newData);
        widget.onResumeChange!();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка сохранения: ${e.toString()}')),
        );
      }
    } else {
      // Если изменений не было, просто закрываем страницу
      if (widget.onReturnFromOnboarding != null) {
        widget.onReturnFromOnboarding!();
      }
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();

    _surnameController = TextEditingController(
      text: widget.data.isNotEmpty ? widget.data[0] : '',
    );
    _nameController = TextEditingController(
      text: widget.data.length > 1 ? widget.data[1] : '',
    );
    _patronymicController = TextEditingController(
      text: widget.data.length > 2 ? widget.data[2] : '',
    );

    widget.showOnboarding
        ? WidgetsBinding.instance.addPostFrameCallback((_) {
          _showFullScreenOnboarding();
        })
        : null;
  }

  void _showFullScreenOnboarding() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.82),
      transitionDuration: const Duration(milliseconds: timeShowAnimation),
      pageBuilder: (context, _, __) {
        return OnboardingContent(
          hideOnboarding: () {
            Navigator.pop(context);
            _pulseCtrl.repeat(reverse: true);
          },
          iconKey: widget.doneIconKey ?? GlobalKey(),
          isFirstBigStep: false,
          isThirdBigStep: true,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = screenHeight * 0.1;
    final screenWidth = MediaQuery.of(context).size.width;
    final space = screenWidth * 0.05;

    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: SafeArea(
          // Добавлен SafeArea для AppBar
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
                      onPressed:
                          widget.showOnboarding
                              ? null
                              : () {
                                Navigator.pop(context);
                              },
                      icon: lightArrowBackIcon,
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
      ),

      body: SafeArea(
        // Добавлен SafeArea для основного контента
        top: false, // Отключаем верхний SafeArea, так как он уже есть в AppBar
        child: Stack(
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
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildTextField(
                      label: 'Фамилия',
                      controller: _surnameController,
                      index: 0,
                      length: widget.data.length,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Имя',
                      controller: _nameController,
                      index: 1,
                      length: widget.data.length,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Отчество',
                      controller: _patronymicController,
                      index: 2,
                      length: widget.data.length,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: bottom35),
        child:
            widget.showOnboarding
                ? ScaleTransition(
                  scale: _pulseAnim,
                  child: IconButton(
                    icon: darkerBiggerDoneIcon,
                    onPressed: () {
                      _saveChanges();
                    }, // Используем новую функцию
                    iconSize: 36,
                  ),
                )
                : IconButton(
                  icon: darkerBiggerDoneIcon,
                  onPressed: () {
                    _saveChanges();
                  }, // Используем новую функцию
                  iconSize: 36,
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
        TextField(
          controller: controller,
          style: const TextStyle(
            fontFamily: "NotoSansBengali",
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: black,
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.only(top: 7, bottom: 14),
            border:
                index != 3
                    ? UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: lightDarkenLavender,
                        width: 2.5,
                      ),
                    )
                    : InputBorder.none,
            enabledBorder:
                index != 3
                    ? UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: lightDarkenLavender,
                        width: 2.5,
                      ),
                    )
                    : InputBorder.none,
            focusedBorder:
                index != 3
                    ? UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: lightDarkenLavender,
                        width: 2.5,
                      ),
                    )
                    : InputBorder.none,
          ),
        ),
      ],
    );
  }
}

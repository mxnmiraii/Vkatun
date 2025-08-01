import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
import 'package:vkatun/api_service.dart';
import 'package:vkatun/design/colors.dart';
import 'package:vkatun/design/dimensions.dart';
import 'package:vkatun/design/images.dart';

class ContactInfoPage extends StatefulWidget {
  final List<String> data;
  final int resumeId;
  final VoidCallback? onResumeChange;

  const ContactInfoPage({
    super.key,
    required this.data,
    required this.resumeId,
    required this.onResumeChange,
  });

  @override
  State<ContactInfoPage> createState() => _ContactInfoPageState();
}

class _ContactInfoPageState extends State<ContactInfoPage> {
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  final _phoneMaskFormatter = MaskTextInputFormatter(
    mask: '+7 (###) ###-##-##',
    filter: {"#": RegExp(r'\d')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(
      text: widget.data.isNotEmpty ? widget.data[0] : '',
    );
    _emailController = TextEditingController(
      text: widget.data.length > 1 ? widget.data[1] : '',
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final newPhone = _phoneController.text.trim();
    final newEmail = _emailController.text.trim();
    final currentPhone = widget.data.isNotEmpty ? widget.data[0] : '';
    final currentEmail = widget.data.length > 1 ? widget.data[1] : '';

    // Проверяем, были ли изменения
    if (newPhone != currentPhone || newEmail != currentEmail) {
      try {
        final apiService = Provider.of<ApiService>(context, listen: false);

        // Обновляем контактные данные
        await apiService.editResumeSection(
          id: widget.resumeId,
          section: 'contacts',
          content: '$newPhone\n$newEmail',
        );

        // Возвращаем новые данные
        Navigator.pop(context, [newPhone, newEmail]);
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
                      'Контактные данные',
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
              child: Column(
                children: [
                  _buildTextField(
                    label: 'Телефон',
                    controller: _phoneController,
                    index: 0,
                    length: widget.data.length,
                    inputFormatters: [_phoneMaskFormatter],
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Email',
                    controller: _emailController,
                    index: 1,
                    length: widget.data.length,
                    keyboardType: TextInputType.emailAddress,
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
            onPressed: _saveChanges,
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
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
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
          inputFormatters: inputFormatters,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontFamily: "NotoSansBengali",
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: black,
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.only(top: 7, bottom: 14),
            border: index != length - 1
                ? UnderlineInputBorder(
              borderSide: BorderSide(
                color: lightDarkenLavender,
                width: 2.5,
              ),
            )
                : InputBorder.none,
            enabledBorder: index != 2
                ? UnderlineInputBorder(
              borderSide: BorderSide(
                color: lightDarkenLavender,
                width: 2.5,
              ),
            )
                : InputBorder.none,
            focusedBorder: index != 2
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
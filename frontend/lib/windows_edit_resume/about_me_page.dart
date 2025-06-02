import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vkatun/api_service.dart';
import 'package:vkatun/design/colors.dart';
import 'package:vkatun/design/dimensions.dart';
import 'package:vkatun/design/images.dart';

class AboutMePage extends StatefulWidget {
  final String data;
  final int resumeId;
  final VoidCallback? onResumeChange;

  const AboutMePage({
    super.key,
    required this.data,
    required this.resumeId,
    required this.onResumeChange,
  });

  @override
  State<AboutMePage> createState() => _AboutMePageState();
}

class _AboutMePageState extends State<AboutMePage> {
  late TextEditingController _aboutMeController;

  @override
  void dispose() {
    _aboutMeController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final newAboutMe = _aboutMeController.text.trim();
    final currentAboutMe = widget.data;

    // Проверяем, были ли изменения
    if (newAboutMe != currentAboutMe) {
      try {
        final apiService = Provider.of<ApiService>(context, listen: false);

        // Обновляем секцию "about_me"
        await apiService.editResumeSection(
          id: widget.resumeId,
          section: 'about',
          content: newAboutMe,
        );

        // Возвращаем новые данные
        Navigator.pop(context, newAboutMe);
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
    _aboutMeController = TextEditingController(text: widget.data);
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
                      'О себе',
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'О себе',
                    style: TextStyle(
                      fontFamily: 'Playfair',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: lavenderBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _aboutMeController,
                    style: const TextStyle(
                      fontFamily: "NotoSansBengali",
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: black,
                    ),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.only(top: 7, bottom: 14),
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
}
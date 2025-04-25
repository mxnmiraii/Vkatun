import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:vkatun/design/colors.dart';
import 'package:vkatun/design/dimensions.dart';
import 'package:vkatun/design/images.dart';


class ContactInfoPage extends StatefulWidget {
  const ContactInfoPage({super.key});

  @override
  State<ContactInfoPage> createState() => _ContactInfoPageState();
}

class _ContactInfoPageState extends State<ContactInfoPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final _phoneMaskFormatter = MaskTextInputFormatter(
    mask: '+7 (###) ###-##-##',
    filter: {"#": RegExp(r'\d')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = screenHeight * 0.23 / 2;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: Container(
          decoration: const BoxDecoration(
            color: veryPaleBlue,
            boxShadow: [
              BoxShadow(
                color: Color(0x1A000000),
                offset: Offset(0, 4),
                blurRadius: 8,
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            toolbarHeight: appBarHeight,
            automaticallyImplyLeading: false,
            elevation: 0,
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
                    'Контактные данные',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                      fontFamily: 'Playfair',
                      color: midnightPurple,
                    ),
                  ),
                  Opacity(opacity: 0, child: backIconWBg),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: buttonPaddingVertical),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 36),
            _buildTextField(
              label: 'Телефон',
              controller: _phoneController,
              inputFormatters: [_phoneMaskFormatter],
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              label: 'Email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: bottom35),
        child: IconButton(
          icon: biggerDoneIcon,
          onPressed: () {
            Navigator.pop(context);
          },
          iconSize: 72,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'NotoSans',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: mediumGray,
          ),
        ),
        const SizedBox(height: 0),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: const TextStyle(
            fontFamily: "NotoSans",
            fontSize: 16,
            fontWeight: FontWeight.w700, // одинаковая жирность
            color: black,
          ),
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 14),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: lightGray),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: lightGray),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: gray),
            ),
          ),
        ),
      ],
    );
  }
}

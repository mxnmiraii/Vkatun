import 'package:flutter/material.dart';
import 'package:vkatun/design/colors.dart';
import 'package:vkatun/design/dimensions.dart';
import 'package:vkatun/design/images.dart';

import '../pages/start_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountMainPageState();
}

class _AccountMainPageState extends State<AccountPage> {
  late TextEditingController _fioController = TextEditingController();
  late TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _fioController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fioController = TextEditingController(text: 'Петров Иван Натанович');
    _emailController = TextEditingController(text: 'ivan.petrov@email.com');
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
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: lightArrowBackIcon
                ),

                Text(
                  'Аккаунт',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 32,
                    fontFamily: 'Playfair',
                    color: purpleBlue,
                  ),
                ),

                IconButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => StartPage())
                      );
                    },
                    icon: logOutIcon,
                )
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
              margin: const EdgeInsets.symmetric(horizontal: 10),
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
              child: Column(children: [
                _buildTextField(label: 'ФИО', controller: _fioController, onPressed: () {}),
                SizedBox(height: 30,),
                _buildTextField(label: 'Почта', controller: _emailController, onPressed: () {}),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required onPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Playfair',
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: darkImperialBlue,
          ),
        ),

        SizedBox(height: 10,),

        TextField(
          controller: controller,
          style: const TextStyle(
            fontFamily: "NotoSans",
            fontSize: 14,
            fontWeight: FontWeight.w300,
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
                color: lightVioletDivider.withOpacity(0.5), // Цвет полоски
                width: 1,
              ),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: lightVioletDivider.withOpacity(0.5),
                width: 1,
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: lightVioletDivider.withOpacity(0.5),
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

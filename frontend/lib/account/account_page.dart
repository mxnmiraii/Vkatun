import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vkatun/design/colors.dart';
import 'package:vkatun/design/dimensions.dart';
import 'package:vkatun/design/images.dart';

import '../api_service.dart';
import '../pages/start_page.dart';
import 'account_main_page.dart';
import 'account_settings.dart';

class AccountPage extends StatefulWidget {
  final Map<String, dynamic> profileData;
  const AccountPage({super.key, required this.profileData});

  @override
  State<AccountPage> createState() => _AccountMainPageState();
}

class _AccountMainPageState extends State<AccountPage> {
  late TextEditingController _usernameController = TextEditingController();
  late TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.profileData['username']);
    _emailController = TextEditingController(text: widget.profileData['email']);
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
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          toolbarHeight: appBarHeight,
          centerTitle: false,
          systemOverlayStyle: SystemUiOverlayStyle.dark, // ← важная строка
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: lightArrowBackIcon,
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
                onPressed: () async {
                  final apiService = Provider.of<ApiService>(context, listen: false);
                  await apiService.clearToken();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => StartPage()),
                        (Route<dynamic> route) => false,
                  );
                },
                icon: logOutIcon,
                tooltip: 'Выйти из аккаунта',
              ),
            ],
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
                _buildTextField(label: 'Имя пользователя', controller: _usernameController, onPressed: () {}),
                SizedBox(height: 30,),
                _buildTextField(label: 'Почта', controller: _emailController, onPressed: () {}),
              ]),
            ),
          ),
        ],
      ),

      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: bottom35),
        child: IconButton(
          icon: circle,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AccountSettingsPage(profileData: widget.profileData,))
            );
          },
          iconSize: 36, // Можно настроить размер иконки
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
          readOnly: true, // ← вот это добавили
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
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(
                color: lightVioletDivider.withOpacity(0.5),
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

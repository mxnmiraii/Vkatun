import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vkatun/account/account_page.dart';
import 'package:vkatun/design/colors.dart';
import 'package:vkatun/design/dimensions.dart';
import 'package:vkatun/design/images.dart';

import '../api_service.dart';
import '../windows/scan_windows/indicator.dart';
import 'metrics_page.dart';

class AccountMainPage extends StatefulWidget {
  const AccountMainPage({super.key});

  @override
  State<AccountMainPage> createState() => _AccountMainPageState();
}

class _AccountMainPageState extends State<AccountMainPage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  Future<Map<String, dynamic>> _getProfileData() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final response = await apiService.getProfile();

      return response;
    } catch (e) {
      print('Ошибка при анализе $e');
      return {"id": null, "email": null};
    }
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
        child: SafeArea(
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
                    'Администратор',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 32,
                      fontFamily: 'Playfair',
                      color: purpleBlue,
                    ),
                  ),

                  Opacity(opacity: 0, child: lightArrowBackIcon),
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
                _buildTextField(
                  label: 'Данные об аккаунте',
                  onPressed: () async {
                    try {
                      // Ждем загрузки данных
                      final profileData = await _getProfileData();
                      // Переходим только после успешной загрузки
                      if (mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AccountPage(profileData: profileData),
                          ),
                        );
                      }
                    } catch (e) {
                      print('Ошибка загрузки данных: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Не удалось загрузить данные')),
                      );
                    }
                  },
                ),
                SizedBox(height: 30,),
                _buildTextField(label: 'Метрики', onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MetricsPage())
                  );
                }),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required onPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

            IconButton(
              onPressed: onPressed,
              icon: lightArrowForwardIcon,
            )
          ],
        ),

        Divider(
          color: lightVioletDivider.withOpacity(0.5),
          thickness: 1,
        )
      ],
    );
  }
}
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
              title: Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: lightArrowBackIcon,
                    ),
                    Flexible(
                      child: Text(
                        'Администратор',
                        overflow: TextOverflow.ellipsis, // добавит ... если не влезает
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 32,
                          fontFamily: 'Playfair',
                          color: purpleBlue,
                        ),
                      ),
                    ),
                    Opacity(opacity: 0, child: lightArrowBackIcon),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // Градиентный фон
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height,
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
              child: Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
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
                        label: 'Данные об аккаунте',
                        onPressed: () async {
                          try {
                            final profileData = await _getProfileData();
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
                          }
                        },
                      ),
                      const SizedBox(height: 30),
                      _buildTextField(
                        label: 'Метрики',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MetricsPage()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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
          children: [
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontFamily: 'Playfair',
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: darkImperialBlue,
                ),
              ),
            ),
            IconButton(
              onPressed: onPressed,
              icon: lightArrowForwardIcon,
            ),
          ],
        ),
        Divider(
          color: lightVioletDivider.withOpacity(0.5),
          thickness: 1,
        ),
      ],
    );
  }
}

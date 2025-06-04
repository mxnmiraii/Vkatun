import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vkatun/account/period_selector.dart';
import 'package:vkatun/design/colors.dart';
import 'package:vkatun/design/dimensions.dart';
import 'package:vkatun/design/images.dart';
import '../api_service.dart';

class MetricsPage extends StatefulWidget {
  const MetricsPage({super.key});

  @override
  State<MetricsPage> createState() => _MetricsPageState();
}

class _MetricsPageState extends State<MetricsPage> {
  Map<String, dynamic> metrics = {
    "total_users": 0,
    "active_users_today": 0,
    "total_resumes": 0,
    "total_changes_app": 0,
  };

  bool isLoading = true;
  String errorMessage = '';
  String selectedPeriod = 'week'; // По умолчанию день

  @override
  void initState() {
    super.initState();
    _loadMetrics(selectedPeriod);
  }

  Future<void> _loadMetrics(String period) async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final data = await apiService.getMetricsHistory(period);

      if (!mounted) return;

      setState(() {
        metrics = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Не удалось загрузить метрики: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = screenHeight * 0.1;
    final screenWidth = MediaQuery.of(context).size.width;

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
                  Text(
                    'Метрики',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 32,
                      fontFamily: 'Playfair',
                      color: purpleBlue,
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
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                children: [
                  PeriodSelector(
                    selectedPeriod: selectedPeriod,
                    onPeriodSelected: (period) {
                      setState(() {
                        selectedPeriod = period;
                      });
                      _loadMetrics(period);
                    },
                  ),
                  const SizedBox(height: 20),
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (errorMessage.isNotEmpty)
                    Text(errorMessage, style: const TextStyle(color: Colors.red))
                  else
                    Column(
                      children: [
                        _buildTextField(
                          label: 'Количество загруженных резюме – ${metrics['total_resumes']}',
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          label: '${selectedPeriod == 'day' ? 'Количество активных пользователей' : 'Среднее количество активных пользователей в день'} – ${metrics['active_users_today']}',
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          label: 'Общее количество зарегистрированных пользователей – ${metrics['total_users']}',
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          label: 'Процент принятых рекомендаций – ${metrics['total_changes_app']}%',
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({required String label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'NotoSansBengali',
              fontWeight: FontWeight.w400,
              fontSize: 16.4,
              color: cosmicBlue,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Divider(color: lightVioletDivider.withOpacity(0.5), thickness: 1),
      ],
    );
  }
}
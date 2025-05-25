import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vkatun/design/colors.dart';
import 'package:vkatun/design/dimensions.dart';
import 'package:vkatun/windows/scan_windows/check_widget.dart';

import '../api_service.dart';
import '../design/images.dart';

class ApplyCorrections extends StatefulWidget {
  final Map<String, dynamic> originalResume;
  final List<Issue> corrections;
  final Issue? singleCorrection;
  final VoidCallback? onResumeChange;

  const ApplyCorrections({
    super.key,
    required this.originalResume,
    required this.corrections,
    this.singleCorrection,
    required this.onResumeChange,
  });

  @override
  State<ApplyCorrections> createState() => _ApplyCorrectionsState();
}

class _ApplyCorrectionsState extends State<ApplyCorrections> {
  late Map<String, dynamic> _correctedResume;
  final ScrollController _originalScrollController = ScrollController();
  final ScrollController _correctedScrollController = ScrollController();
  bool _isSyncingScroll = false;

  @override
  void initState() {
    super.initState();
    _correctedResume = Map<String, dynamic>.from(widget.originalResume);

    if (widget.singleCorrection != null) {
      _applyCorrection(widget.singleCorrection!);
    } else {
      for (var correction in widget.corrections) {
        _applyCorrection(correction);
      }
    }

    // Синхронизация прокрутки
    _originalScrollController.addListener(() {
      if (!_isSyncingScroll) {
        _isSyncingScroll = true;
        _syncScroll(_originalScrollController, _correctedScrollController);
        _isSyncingScroll = false;
      }
    });

    _correctedScrollController.addListener(() {
      if (!_isSyncingScroll) {
        _isSyncingScroll = true;
        _syncScroll(_correctedScrollController, _originalScrollController);
        _isSyncingScroll = false;
      }
    });
  }

  @override
  void dispose() {
    _originalScrollController.dispose();
    _correctedScrollController.dispose();
    super.dispose();
  }

  void _syncScroll(ScrollController source, ScrollController target) {
    if (source.position.hasContentDimensions &&
        target.position.hasContentDimensions) {
      final sourceOffset = source.offset;
      final maxSource = source.position.maxScrollExtent;
      final maxTarget = target.position.maxScrollExtent;

      if (maxSource > 0 && maxTarget > 0) {
        final targetOffset = (sourceOffset / maxSource) * maxTarget;
        if ((target.offset - targetOffset).abs() > 1.0) {
          target.jumpTo(targetOffset);
        }
      }
    }
  }

  void _applyCorrection(Issue correction) {
    _correctedResume.forEach((key, value) {
      if (value is String && value.contains(correction.errorText)) {
        _correctedResume[key] = value.replaceAll(
          correction.errorText,
          correction.suggestion,
        );
      }
    });
  }

  TextSpan _highlightErrors(String text, List<Issue> errors) {
    final spans = <TextSpan>[];
    int lastIndex = 0;
    errors.sort(
          (a, b) => text.indexOf(a.errorText).compareTo(text.indexOf(b.errorText)),
    );

    for (final error in errors) {
      final index = text.indexOf(error.errorText, lastIndex);
      if (index != -1) {
        if (index > lastIndex) {
          spans.add(
            TextSpan(
              text: text.substring(lastIndex, index),
              style: const TextStyle(
                color: Colors.black,
                fontFamily: 'NotoSans',
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
            ),
          );
        }
        spans.add(
          TextSpan(
            text: text.substring(index, index + error.errorText.length),
            style: const TextStyle(
              color: Colors.black,
              backgroundColor: Color(0xFFFFCDD2),
              fontFamily: 'NotoSans',
              fontSize: 14,
              fontWeight: FontWeight.w300,
            ),
          ),
        );
        lastIndex = index + error.errorText.length;
      }
    }

    if (lastIndex < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(lastIndex),
          style: const TextStyle(
            color: Colors.black,
            fontFamily: 'NotoSans',
            fontSize: 14,
            fontWeight: FontWeight.w300,
          ),
        ),
      );
    }

    return spans.isEmpty
        ? TextSpan(text: text, style: const TextStyle(color: Colors.black))
        : TextSpan(children: spans);
  }

  TextSpan _highlightCorrections(String text, List<Issue> corrections) {
    final spans = <TextSpan>[];
    int lastIndex = 0;
    corrections.sort(
          (a, b) =>
          text.indexOf(a.suggestion).compareTo(text.indexOf(b.suggestion)),
    );

    for (final correction in corrections) {
      final index = text.indexOf(correction.suggestion, lastIndex);
      if (index != -1) {
        if (index > lastIndex) {
          spans.add(
            TextSpan(
              text: text.substring(lastIndex, index),
              style: const TextStyle(
                color: Colors.black,
                fontFamily: 'NotoSans',
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
            ),
          );
        }
        spans.add(
          TextSpan(
            text: text.substring(index, index + correction.suggestion.length),
            style: const TextStyle(
              color: Colors.black,
              backgroundColor: Color(0xFFC8E6C9),
              fontFamily: 'NotoSans',
              fontSize: 14,
              fontWeight: FontWeight.w300,
            ),
          ),
        );
        lastIndex = index + correction.suggestion.length;
      }
    }

    if (lastIndex < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(lastIndex),
          style: const TextStyle(
            color: Colors.black,
            fontFamily: 'NotoSans',
            fontSize: 14,
            fontWeight: FontWeight.w300,
          ),
        ),
      );
    }

    return spans.isEmpty
        ? TextSpan(text: text, style: const TextStyle(color: Colors.black))
        : TextSpan(children: spans);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = screenHeight * 0.15 / 2;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: veryPaleBlue,
        toolbarHeight: appBarHeight,
        automaticallyImplyLeading: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: backIconWBg,
            ),
            Text(
              'Резюме',
              style: TextStyle(
                color: midnightPurple,
                fontFamily: 'Playfair',
                fontWeight: FontWeight.w800,
                fontSize: 24,
              ),
              textAlign: TextAlign.center,
            ),
            Opacity(opacity: 0, child: backIconWBg),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            height: 2,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.transparent,
              boxShadow: [
                BoxShadow(
                  color: periwinkle.withOpacity(0.54),
                  blurRadius: 0,
                  spreadRadius: 0,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    width: 170,
                    height: 60,
                    decoration: BoxDecoration(
                      color: veryPaleBlue,
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(borderRadius),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: periwinkle.withOpacity(0.54),
                          offset: Offset(2, 2),
                          blurRadius: 4,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 12.0,
                      ),
                      child: Text(
                        'Что было:',
                        style: TextStyle(
                          fontFamily: 'Playfair',
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: midnightPurple,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),

              Expanded(
                child: _buildScrollableResumeView(
                  isNewVersion: false,
                  controller: _originalScrollController,
                ),
              ),

              Container(
                height: 2,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  boxShadow: [
                    BoxShadow(
                      color: periwinkle.withOpacity(0.54),
                      offset: Offset(0, 2),
                      blurRadius: 0,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),

              Container(
                width: 170,
                height: 60,
                decoration: BoxDecoration(
                  color: veryPaleBlue,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(borderRadius),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: periwinkle.withOpacity(0.54),
                      offset: Offset(2, 2),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 12.0,
                  ),
                  child: Text(
                    'Что будет:',
                    style: TextStyle(
                      fontFamily: 'Playfair',
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: midnightPurple,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Expanded(
                child: _buildScrollableResumeView(
                  isNewVersion: true,
                  controller: _correctedScrollController,
                ),
              ),
            ],
          ),
        ],
      ),

      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: bottom35),
        child: IconButton(
          icon: doneBlueIcon,
          onPressed: () {
            _editResumeFull();
            widget.onResumeChange!();
          },
          iconSize: 36, // Можно настроить размер иконки
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  Future<void> _editResumeFull() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      // Показываем индикатор загрузки
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Подготавливаем данные для отправки
      final dataToUpdate = {
        'title': _correctedResume['title'],
        'contacts': _correctedResume['contacts'],
        'job': _correctedResume['job'],
        'experience': _correctedResume['experience'],
        'education': _correctedResume['education'],
        'skills': _correctedResume['skills'],
        'about': _correctedResume['about'],
      };

      // Отправляем изменения
      await apiService.editResume(
        widget.originalResume['id'] as int,
        dataToUpdate,
      );

      // Успешное обновление - закрываем экран с результатом
      if (mounted) {
        Navigator.of(context).pop(); // Закрываем индикатор загрузки
        Navigator.of(context).pop(true);
      }

    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Закрываем индикатор загрузки
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Не удалось сохранить изменения: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildScrollableResumeView({
    required bool isNewVersion,
    required ScrollController controller,
  }) {
    final fieldMap = {
      'ФИО': 'title',
      'Желаемая должность': 'job',
      'Контактные данные': 'contacts',
      'Опыт работы': 'experience',
      'Образование': 'education',
      'Ключевые навыки': 'skills',
      'О себе': 'about',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Scrollbar(
        controller: controller,
        child: SingleChildScrollView(
          controller: controller,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: fieldMap.entries.map((entry) {
              final label = entry.key;
              final key = entry.value;

              final originalText =
                  widget.originalResume[key]?.toString() ?? 'Не указано';
              final correctedText =
                  _correctedResume[key]?.toString() ?? originalText;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 16.0,
                      left: 16,
                      right: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Playfair'
                          ),
                        ),
                        const SizedBox(height: 16),
                        RichText(
                          text: isNewVersion
                              ? _highlightCorrections(
                            correctedText,
                            widget.corrections,
                          )
                              : _highlightErrors(
                            originalText,
                            widget.corrections,
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                    ),
                  ),
                  Divider(height: 0.5, color: lightGray),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
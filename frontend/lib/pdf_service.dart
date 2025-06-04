import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class PdfService {
  // Цветовая схема
  static const _primaryColor = PdfColor.fromInt(0xFF111827);
  static const _secondaryColor = PdfColor.fromInt(0xFF6B7280);
  static const _accentColor = PdfColor.fromInt(0xFF3B82F6);
  static const _lightBackground = PdfColor.fromInt(0xFFF9FAFB);

  // Размеры шрифтов
  static const double _bodyTextSize = 10.0;
  static const double _sectionTitleSize = 12.0;
  static const double _headerTextSize = 18.0;
  static const double _nameTextSize = 22.0;

  // Отступы
  static const double _pagePadding = 28.0;
  static const double _sectionSpacing = 16.0;
  static const double _paragraphSpacing = 8.0;
  static const double _lineHeight = 1.4;
  static const double _maxContentWidth = 500.0;

  static Future<File> generateResumePdf(Map<String, dynamic> resume) async {
    final pdf = pw.Document();

    // Загрузка шрифтов
    final font = await _loadFont('assets/fonts/Roboto-Regular.ttf');
    final mediumFont = await _loadFont('assets/fonts/Roboto-Medium.ttf');
    final boldFont = await _loadFont('assets/fonts/Roboto-Bold.ttf');

    final theme = pw.ThemeData.withFont(
      base: font,
      bold: boldFont,
      fontFallback: [font],
    );

    // Основной контент
    final content = _buildResumeContent(resume, boldFont, mediumFont, font);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(_pagePadding),
        theme: theme,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        footer: _buildFooter,
        build: (pw.Context context) => content,
      ),
    );

    return _savePdfToDownloads(pdf);
  }

  static List<pw.Widget> _buildResumeContent(
      Map<String, dynamic> resume,
      pw.Font boldFont,
      pw.Font mediumFont,
      pw.Font font,
      ) {
    final content = <pw.Widget>[
      _buildHeader(resume['title'] ?? 'Резюме', boldFont),
      pw.SizedBox(height: _sectionSpacing),
      _buildContactSection(resume['contacts'] ?? '', mediumFont),
      pw.SizedBox(height: _sectionSpacing),
      _buildJobSection(resume['job'] ?? '', mediumFont),
    ];

    // Добавляем секции с проверкой на наличие контента
    _addSectionIfExists(content, resume, 'about', 'О себе', font);
    _addSectionIfExists(content, resume, 'experience', 'Опыт работы', mediumFont);
    _addSectionIfExists(content, resume, 'education', 'Образование', mediumFont);
    _addSectionIfExists(content, resume, 'skills', 'Навыки', mediumFont);

    return content;
  }

  static void _addSectionIfExists(
      List<pw.Widget> content,
      Map<String, dynamic> resume,
      String key,
      String title,
      pw.Font font,
      ) {
    final sectionContent = resume[key];
    if (sectionContent?.toString().isNotEmpty ?? false) {
      content.addAll([
        pw.SizedBox(height: _sectionSpacing),
        _buildSectionTitle(title, font),
        pw.SizedBox(height: _paragraphSpacing),
        _buildContentSection(sectionContent, key == 'skills', font),
      ]);
    }
  }

  static pw.Widget _buildContentSection(String content, bool isSkills, pw.Font font) {
    if (isSkills) {
      return _buildSkillsSection(content, font);
    }
    return _buildTextSection(content, font);
  }

  static pw.Widget _buildHeader(String title, pw.Font font) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title.split(' Мужчина').first,
          style: pw.TextStyle(
            font: font,
            fontSize: _nameTextSize,
            fontWeight: pw.FontWeight.bold,
            color: _primaryColor,
          ),
        ),
        pw.Divider(thickness: 1.5, color: _accentColor, height: 24),
      ],
    );
  }

  static pw.Widget _buildContactSection(String contacts, pw.Font font) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Контактные данные', font),
        pw.SizedBox(height: _paragraphSpacing),
        pw.Text(
          contacts,
          style: pw.TextStyle(
            fontSize: _bodyTextSize,
            color: _secondaryColor,
            lineSpacing: _lineHeight,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildJobSection(String job, pw.Font font) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Желаемая должность', font),
        pw.SizedBox(height: _paragraphSpacing),
        pw.Text(
          job,
          style: pw.TextStyle(
            fontSize: _bodyTextSize,
            color: _secondaryColor,
            lineSpacing: _lineHeight,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildTextSection(String text, pw.Font font) {
    return pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: _bodyTextSize,
        color: _secondaryColor,
        lineSpacing: _lineHeight,
      ),
    );
  }

  static pw.Widget _buildSkillsSection(String skills, pw.Font font) {
    final skillItems = skills.split('\n').where((s) => s.trim().isNotEmpty);

    return pw.Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        for (final skill in skillItems)
          pw.Container(
            padding: pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: _accentColor, width: 1),
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Text(
              skill.trim(),
              style: pw.TextStyle(
                fontSize: _bodyTextSize,
                color: _accentColor,
              ),
            ),
          ),
      ],
    );
  }

  static pw.Widget _buildSectionTitle(String title, pw.Font font) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        font: font,
        fontSize: _sectionTitleSize,
        color: _primaryColor,
        fontWeight: pw.FontWeight.bold,
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: pw.EdgeInsets.only(top: 20),
      child: pw.Text(
        'Страница ${context.pageNumber} из ${context.pagesCount}',
        style: const pw.TextStyle(
          fontSize: 10,
          color: _secondaryColor,
        ),
      ),
    );
  }

  static Future<pw.Font> _loadFont(String path) async {
    try {
      final fontData = await rootBundle.load(path);
      return pw.Font.ttf(fontData);
    } catch (e) {
      print('Ошибка загрузки шрифта: $e');
      return pw.Font.helvetica();
    }
  }

  static Future<File> _savePdfToDownloads(pw.Document pdf) async {
    final downloadsDir = await _getDownloadsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${downloadsDir.path}/resume_$timestamp.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static Future<Directory> _getDownloadsDirectory() async {
    if (Platform.isAndroid) {
      try {
        final dir = Directory('/storage/emulated/0/Download');
        if (await dir.exists()) return dir;
      } catch (e) {
        print('Не удалось получить папку загрузок: $e');
      }
    }
    return await getApplicationDocumentsDirectory();
  }

  static Future<void> openFile(File file) async {
    try {
      await Printing.layoutPdf(onLayout: (_) => file.readAsBytes());
    } catch (e) {
      print('Ошибка открытия PDF: $e');
    }
  }
}
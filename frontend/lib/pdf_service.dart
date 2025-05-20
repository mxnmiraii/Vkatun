import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';

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

  static Future<File> generateResumePdf(Map<String, dynamic> resume) async {
    final pdf = pw.Document();

    // 1. ЗАГРУЖАЕМ ПРАВИЛЬНЫЕ ШРИФТЫ
    final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    final font = pw.Font.ttf(fontData);

    final mediumFontData = await rootBundle.load('assets/fonts/Roboto-Medium.ttf');
    final mediumFont = pw.Font.ttf(mediumFontData);

    final boldFontData = await rootBundle.load('assets/fonts/Roboto-Bold.ttf');
    final boldFont = pw.Font.ttf(boldFontData);

    // 2. СОЗДАЕМ ТЕМУ С ШРИФТАМИ
    final theme = pw.ThemeData.withFont(
      base: font,
      bold: boldFont,
      fontFallback: [font], // важный параметр для кириллицы
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(_pagePadding),
        theme: theme, // применяем тему
        build: (pw.Context context) {
          return [
            _buildHeader(resume['title'] ?? 'Резюме', boldFont),
            pw.SizedBox(height: _sectionSpacing),

            _buildContactSection(resume['contacts'] ?? '', mediumFont),
            pw.SizedBox(height: _sectionSpacing),

            _buildJobSection(resume['job'] ?? '', mediumFont),
            pw.SizedBox(height: _sectionSpacing),

            if (resume['experience']?.toString().isNotEmpty ?? false)
              _buildExperienceSection(resume['experience'], mediumFont),

            if (resume['education']?.toString().isNotEmpty ?? false)
              _buildEducationSection(resume['education'], mediumFont),

            if (resume['skills']?.toString().isNotEmpty ?? false)
              _buildSkillsSection(resume['skills'], mediumFont),

            if (resume['about']?.toString().isNotEmpty ?? false)
              _buildAboutSection(resume['about'], font),
          ];
        },
      ),
    );

    return _savePdfToDownloads(pdf);
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
            color: _secondaryColor, // Изменил с _primaryColor на _secondaryColor
            lineSpacing: _lineHeight,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildExperienceSection(String experience, pw.Font font) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Опыт работы', font),
        pw.SizedBox(height: _paragraphSpacing),
        _buildBulletList(experience),
      ],
    );
  }

  static pw.Widget _buildEducationSection(String education, pw.Font font) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Образование', font),
        pw.SizedBox(height: _paragraphSpacing),
        _buildBulletList(education),
      ],
    );
  }

  static pw.Widget _buildSkillsSection(String skills, pw.Font font) {
    final skillItems = skills.split('\n').where((s) => s.trim().isNotEmpty);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Навыки', font),
        pw.SizedBox(height: _paragraphSpacing),
        pw.Wrap(
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
        ),
      ],
    );
  }

  static pw.Widget _buildAboutSection(String about, pw.Font font) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('О себе', font),
        pw.SizedBox(height: _paragraphSpacing),
        pw.Text(
          about,
          style: pw.TextStyle(
            fontSize: _bodyTextSize,
            color: _secondaryColor,
            lineSpacing: _lineHeight,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildBulletList(String content) {
    final items = content.split('\n').where((p) => p.trim().isNotEmpty);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        for (final item in items)
          pw.Padding(
            padding: pw.EdgeInsets.only(bottom: 6),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '• ',
                  style: pw.TextStyle(
                    fontSize: _bodyTextSize,
                    color: _accentColor,
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    item,
                    style: pw.TextStyle(
                      fontSize: _bodyTextSize,
                      color: _secondaryColor,
                      lineSpacing: _lineHeight,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  static pw.Widget _buildSectionTitle(String title, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 20.0, bottom: 8.0),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          font: font,
          fontSize: _sectionTitleSize,
          color: _primaryColor,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  static Future<pw.Font> _loadRussianFont() async {
    try {
      final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
      return pw.Font.ttf(fontData);
    } catch (e) {
      print('Ошибка загрузки шрифта: $e');
      return pw.Font.helvetica();
    }
  }

  static Future<pw.Font> _loadRussianMediumFont() async {
    try {
      final fontData = await rootBundle.load('assets/fonts/Roboto-Medium.ttf');
      return pw.Font.ttf(fontData);
    } catch (e) {
      print('Ошибка загрузки medium шрифта: $e');
      return _loadRussianFont();
    }
  }

  static Future<pw.Font> _loadRussianBoldFont() async {
    try {
      final fontData = await rootBundle.load('assets/fonts/Roboto-Bold.ttf');
      return pw.Font.ttf(fontData);
    } catch (e) {
      print('Ошибка загрузки bold шрифта: $e');
      return _loadRussianFont();
    }
  }

  static Future<File> _savePdfToDownloads(pw.Document pdf) async {
    final downloadsDir = await _getDownloadsDirectory();

    final now = DateTime.now();
    final formattedDate =
        'resume_'
        '${now.day.toString().padLeft(2, '0')}_'
        '${now.month.toString().padLeft(2, '0')}_'
        '${now.year}_'
        '${now.hour}_'
        '${now.minute}_'
        '${now.second}';

    final file = File('${downloadsDir.path}/$formattedDate.pdf');
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

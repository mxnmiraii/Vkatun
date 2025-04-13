import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:vkatun/design/images.dart'; // Предполагается, что здесь ваши иконки
import 'package:vkatun/design/dimensions.dart';
import 'package:vkatun/windows/window_resumes_page.dart';

import '../design/colors.dart'; // Предполагается, что здесь bottom50

class ResumesPage extends StatelessWidget {
  const ResumesPage({super.key});

  Future<void> _pickPdfFile(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;

        if (file.extension?.toLowerCase() == 'pdf') {
          // Здесь можно сохранить файл или выполнить другие действия
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('PDF файл выбран: ${file.name}')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка: выбранный файл не является PDF')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при выборе файла: ${e.toString()}')),
      );
    }
  }

  void _showWindowResumesPage(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: white75,
      barrierLabel: 'Close',
      transitionDuration: const Duration(milliseconds: timeShowAnimation),
      transitionBuilder: (ctx, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, -1), end: const Offset(0, 0)).animate(anim1),
          child: Opacity(
            // opacity: anim1.value,
            opacity: 1,
            child: child,
          ),
        );
      },
      pageBuilder: (ctx, anim1, anim2) {
        return const WindowResumesPage();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = screenHeight * 0.15;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: appBarHeight,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
                icon: accountIcon,
                onPressed: () {
                  _showWindowResumesPage(context);
                },
            ),
            Flexible(
              child: Transform.translate(
                offset: Offset(0, -appBarHeight * 0.15),
                child: logoFullIcon,
              ),
            ),
            IconButton(icon: parametersIcon, onPressed: () {}),
          ],
        ),
        centerTitle: true,
        elevation: 0,
      ),

      body: const Center(child: Text('Resumes Page')),

      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: bottom50),
        child: IconButton(
          icon: addIcon,
          onPressed: () => _pickPdfFile(context),
          iconSize: 36, // Можно настроить размер иконки
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
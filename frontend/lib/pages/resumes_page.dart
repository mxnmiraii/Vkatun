import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:vkatun/design/images.dart';
import 'package:vkatun/design/dimensions.dart';
import 'package:vkatun/windows/window_resumes_page.dart';

import '../design/colors.dart';

class ResumesPage extends StatefulWidget {
  const ResumesPage({super.key});

  @override
  State<StatefulWidget> createState() => _ResumesPageState();
}

class _ResumesPageState extends State<ResumesPage> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  bool _isDialogOpen = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: timeShowAnimation),
      upperBound: 0.125, // 45 градусов (0.125 * 2 * pi)
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _openDialog() {
    _rotationController.forward();
    setState(() {
      _isDialogOpen = true;
    });

    late OverlayEntry buttonOverlayEntry;

    buttonOverlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: bottom35,
        left: 0,
        right: 0,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: AnimatedBuilder(
              animation: _rotationController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationController.value * 2 * math.pi,
                  child: IconButton(
                    icon: addIcon,
                    onPressed: () {
                      buttonOverlayEntry.remove();
                      _closeDialog();
                    },
                    iconSize: 36,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(buttonOverlayEntry);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: white75,
      barrierLabel: 'Close',
      transitionDuration: const Duration(milliseconds: timeShowAnimation),
      transitionBuilder: (ctx, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, -1), end: const Offset(0, 0)).animate(anim1),
          child: child,
        );
      },
      pageBuilder: (ctx, anim1, anim2) {
        return WindowResumesPage(
          onClose: () {
            // buttonOverlayEntry.remove();
            _closeDialog();
          },
          rotationController: _rotationController,
        );
      },
    ).then((_) {
      if (buttonOverlayEntry.mounted) {
        buttonOverlayEntry.remove();
      }
      if (_isDialogOpen) {
        _closeDialog();
      }
    });
  }

  void _closeDialog() {
    _rotationController.reverse();
    setState(() {
      _isDialogOpen = false;
    });
    Navigator.of(context).pop();
  }

  void _onAddIconPressed() {
    _pickPdfFile(context);
  }

  Future<void> _pickPdfFile(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;

        if (file.extension?.toLowerCase() == 'pdf') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('PDF файл выбран: ${file.name}')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ошибка: выбранный файл не является PDF')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при выборе файла: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = screenHeight * 0.15;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: appBarHeight,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: accountIcon,
              onPressed: _openDialog,
            ),
            Flexible(
              child: Transform.translate(
                offset: Offset(0, -appBarHeight * 0.125),
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
        padding: EdgeInsets.only(bottom: bottom35),
        child: AnimatedBuilder(
          animation: _rotationController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationController.value * 2 * math.pi,
              child: IconButton(
                icon: addIcon,
                onPressed: _onAddIconPressed,
                // onPressed: _pickPdfFile(context),
                iconSize: 36,
              ),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

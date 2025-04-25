import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:vkatun/design/images.dart';
import 'package:vkatun/design/dimensions.dart';
import 'package:vkatun/pages/resume_view_page.dart';
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
  List<Map<String, dynamic>> _resumes = [];
  final List<Color> resumeCardColors = [
    babyBlue,
    lightLavender,
    lavenderMist,
    veryPalePink,
  ];

  Color _getColorByResumeId(int id) {
    return resumeCardColors[id % resumeCardColors.length];
  }

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: timeShowAnimation),
      upperBound: 0.125,
    );
    _loadResumes();
  }

  Future<void> _loadResumes() async {
    // Имитация API запроса с задержкой
    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      _resumes = [
        {
          'id': 0,
          'title': 'Петров Иван Иванович',
          'created_at': '2023-12-25', // Самое новое (будет слева вверху)
        },
        {
          'id': 1,
          'title': 'Сидорова Анна Михайловна',
          'created_at': '2023-12-20',
        },
        {
          'id': 2,
          'title': 'Кузнецов Дмитрий Сергеевич',
          'created_at': '2023-12-15',
        },
        {
          'id': 3,
          'title': 'Иванова Мария Петровна',
          'created_at': '2023-12-10',
        },
        {
          'id': 4,
          'title': 'Смирнов Алексей Владимирович',
          'created_at': '2023-12-05',
        },
        {
          'id': 5,
          'title': 'Фролова Екатерина Дмитриевна',
          'created_at': '2023-11-30',
        },
      ];

      // Сортируем по дате (новые сверху)
      _resumes.sort((a, b) => b['created_at'].compareTo(a['created_at']));
    });
  }

  // Заглушка для получения полного резюме по ID
  Map<String, dynamic> _getResumeById(int id) {
    // ... (оставляем предыдущую реализацию без изменений)
    // Добавим новые примеры для новых резюме
    switch (id) {
      case 0:
        return {
          'id': 0,
          'title': 'Петров Иван Иванович',
          'contacts': 'Телефон: +7 (912) 345-67-89 Email: ivan.petrov@email.com',
          'job': 'вахтёр в №5 общежитии ВГУ!',
          'experience': 'ООО "Атом Мовинг"\nGolang backend devoloper\nдва года и два месяца',
          'education': 'Воронежский государственый университет (ВГУ),\nфакультет компьютерных науков\nпрограмная инжинерия\nБакалавр, 2023',
          'skills': 'git, sql, kafka golang postgreSQL',
          'about': 'Мужчина, 23 лет, родился 8 февраля 2002 года.\nГражданство: Россия\nЕсть разрешение на работу, проживает в г. Воронеже\nГотов к переезду и, командировкам',
          'created_at': '2023-12-25',
          'updated_at': '2023-12-25',
        };
      case 1:
        return {
          'id': 1,
          'title': 'Сидорова Анна Михайловна',
          'contacts': 'Телефон: +7 (923) 456-78-90 Email: anna.sidorova@email.com',
          'job': 'UX/UI дизайнер',
          'experience': 'ООО "ДизайнСтудия"\n3 года опыта',
          'education': 'СПбГУ, факультет искусств\nМагистр, 2021',
          'skills': 'Figma, Adobe XD, Photoshop, User Research',
          'about': 'Женщина, 25 лет, ищу удаленную работу',
          'created_at': '2023-12-20',
          'updated_at': '2023-12-20',
        };
      case 2:
        return {
          'id': 2,
          'title': 'Кузнецов Дмитрий Сергеевич',
          'contacts': 'Телефон: +7 (934) 567-89-01 Email: d.kuznetsov@email.com',
          'job': 'Project Manager',
          'experience': 'Яндекс\nМенеджер проектов\n5 лет опыта',
          'education': 'МГУ, экономический факультет\nМагистр, 2018',
          'skills': 'Agile, Scrum, Jira, Team Management',
          'about': 'Опыт управления командами до 10 человек',
          'created_at': '2023-12-15',
          'updated_at': '2023-12-15',
        };
      case 3:
        return {
          'id': 3,
          'title': 'Иванова Мария Петровна',
          'contacts': 'Телефон: +7 (945) 678-90-12 Email: maria.ivanova@email.com',
          'job': 'Маркетолог',
          'experience': 'ООО "РекламаМир"\n2 года опыта',
          'education': 'МГИМО, факультет международных отношений\nБакалавр, 2020',
          'skills': 'SMM, Google Ads, Копирайтинг',
          'about': 'Специалист по digital-маркетингу',
          'created_at': '2023-12-10',
          'updated_at': '2023-12-10',
        };
      case 4:
        return {
          'id': 4,
          'title': 'Смирнов Алексей Владимирович',
          'contacts': 'Телефон: +7 (956) 789-01-23 Email: alex.smirnov@email.com',
          'job': 'Бухгалтер',
          'experience': 'ПАО "Сбербанк"\nГлавный бухгалтер\n7 лет опыта',
          'education': 'РЭУ им. Плеханова\nФинансы и кредит\nМагистр, 2015',
          'skills': '1С, Налоговый учет, МСФО',
          'about': 'Сертифицированный профессиональный бухгалтер',
          'created_at': '2023-12-05',
          'updated_at': '2023-12-05',
        };
      case 5:
        return {
          'id': 5,
          'title': 'Фролова Екатерина Дмитриевна',
          'contacts': 'Телефон: +7 (967) 890-12-34 Email: ekaterina.frolova@email.com',
          'job': 'Юрист',
          'experience': 'Юридическая фирма "Право и Закон"\n5 лет опыта',
          'education': 'МГЮА им. Кутафина\nЮриспруденция\nМагистр, 2017',
          'skills': 'Гражданское право, Договорное право, Судебные споры',
          'about': 'Специализация: корпоративное право',
          'created_at': '2023-11-30',
          'updated_at': '2023-11-30',
        };
      default:
        return {};
    }
  }

  void _openDialog(int resumeId) {
    final resume = _getResumeById(resumeId);

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
            _closeDialog();
          },
          rotationController: _rotationController,
          resume: resume,
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
          // После выбора файла обновляем список резюме
          _loadResumes();
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
              onPressed: () {}
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

      body: _resumes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 32,
            childAspectRatio: 1.4,
          ),
          itemCount: _resumes.length,
          itemBuilder: (context, index) {
            // Определяем порядок отображения (зигзаг)
            final itemIndex = _getZigzagIndex(index, _resumes.length);
            final resume = _resumes[itemIndex];

            return GestureDetector(
              onTap: () {
                // Короткое нажатие - открываем ResumeViewPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResumeViewPage(resume: _getResumeById(resume['id'])),
                  ),
                );
              },
              onLongPress: () {
                // Долгое нажатие - открываем диалог как раньше
                _openDialog(resume['id']);
              },
              child: Card(
                color: _getColorByResumeId(resume['id']),
                elevation: 0,
                margin: EdgeInsets.zero, // Убираем внешние отступы карточки
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                  side: BorderSide(
                    color: royalPurple,
                    width: widthBorderRadius,
                  ),
                ),
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: 0, // Убираем минимальную высоту
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8, // Минимальные внутренние отступы
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: royalPurple,
                            width: widthBorderRadius,
                          ),
                          color: Colors.white,
                        ),
                        child: Text(
                          'Резюме',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Playfair',
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            color: royalPurple,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          resume['title'],
                          // 'Java-разработчик\nгод и 2 месяца',
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Playfair',
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: royalPurple,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),

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
                iconSize: 36,
              ),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // Функция для определения индекса в зигзагообразном порядке
  int _getZigzagIndex(int displayIndex, int totalItems) {
    final row = displayIndex ~/ 2;
    if (row % 2 == 0) {
      // Четные ряды (0, 2, 4...) - обычный порядок
      return displayIndex;
    } else {
      // Нечетные ряды (1, 3, 5...) - обратный порядок
      final start = row * 2;
      final end = math.min(start + 1, totalItems - 1);
      return end - (displayIndex - start);
    }
  }
}
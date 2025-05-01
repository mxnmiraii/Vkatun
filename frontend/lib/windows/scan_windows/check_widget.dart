import 'package:flutter/material.dart';
import 'package:vkatun/design/dimensions.dart';
import 'package:vkatun/design/images.dart';
import '../../design/colors.dart';
import '../../pages/apply_all_corrections_page.dart';

class CheckWidget extends StatefulWidget {
  final double availableHeight;
  final VoidCallback onClose;
  final Map<String, dynamic> resume;
  final List<Issue> issues;
  const CheckWidget(
      {
        super.key,
        required this.availableHeight,
        required this.onClose,
        required this.resume,
        required this.issues
      }
      );

  @override
  State<CheckWidget> createState() => _CheckWidgetState();
}

class _CheckWidgetState extends State<CheckWidget> with TickerProviderStateMixin {
  int? expandedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: royalPurple.withOpacity(0.47),
            width: widthBorderRadius,
          ),
        ),
        clipBehavior: Clip.hardEdge, // вот так ты обрезаешь всё по скруглениям контейнера!
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: expandedIndex != null
                    ? const NeverScrollableScrollPhysics()
                    : const BouncingScrollPhysics(),
                child: Column(
                  children: List.generate(widget.issues.length, (index) {
                    bool isExpanded = expandedIndex == index;
                    bool isHidden = expandedIndex != null && expandedIndex != index;

                    return AnimatedSize(
                      duration: const Duration(milliseconds: timeShowAnimation),
                      curve: Curves.easeInOut,
                      child: isHidden
                          ? const SizedBox.shrink()
                          : IssueCard(
                        issue: widget.issues[index],
                        isExpanded: isExpanded,
                        onToggle: () {
                          setState(() {
                            expandedIndex = isExpanded ? null : index;
                          });
                        },
                        availableHeight: widget.availableHeight,
                        onClose: widget.onClose,
                        resume: widget.resume,
                      ),
                    );
                  }),
                ),
              ),
            ),
            if (expandedIndex == null)
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 16), // отступы сверху и снизу
                child: FractionallySizedBox(
                  widthFactor: 3 / 4,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      side: BorderSide(
                        color: midnightPurple.withOpacity(0.47),
                        width: widthBorderRadius,
                      ),
                      backgroundColor: veryPaleBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(borderRadius),
                      ),
                      minimumSize: const Size(0, 40),
                      elevation: 0,
                    ),
                    onPressed: () {
                      widget.onClose();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ApplyCorrections(
                            originalResume: widget.resume,
                            corrections: widget.issues,
                          ),
                        ),
                      ).then((correctedResume) {
                        if (correctedResume != null) {
                          // Сохраняем исправленное резюме
                          print('Исправленное резюме: $correctedResume');
                        }
                      });
                    },
                    child: Text(
                      'Внедрить все',
                      style: TextStyle(
                        fontFamily: 'Playfair',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        height: 1.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
          ],
        ),
      )
    );
  }
}

class IssueCard extends StatefulWidget {
  final Issue issue;
  final bool isExpanded;
  final VoidCallback onToggle;
  final double availableHeight;
  final VoidCallback onClose;
  final Map<String, dynamic> resume;

  const IssueCard({
    super.key,
    required this.issue,
    required this.isExpanded,
    required this.onToggle,
    required this.availableHeight,
    required this.onClose,
    required this.resume
  });

  @override
  _IssueCardState createState() => _IssueCardState();
}

class _IssueCardState extends State<IssueCard> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _heightAnimation;
  late final Animation<double> _descAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: timeShowAnimation),
    );
    _heightAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _descAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant IssueCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      color: midnightPurple,
      fontFamily: 'Playfair',
      height: 1.0,
    );

    final textStyleDescription = TextStyle(
      color: Colors.black,
      fontSize: 13,
      fontFamily: 'Playfair',
      fontWeight: FontWeight.w800,
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 3,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              ListTile(
                title: Text(
                  widget.issue.errorText,
                  style: textStyle.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 12),
                child: Row(
                  children: [
                    AnimatedRotation(
                      turns: widget.isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: timeShowAnimation),
                      child: IconButton(
                        icon: arrowDown,
                        onPressed: widget.onToggle,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
              SizeTransition(
                sizeFactor: _heightAnimation,
                axisAlignment: -1.0,
                child: AnimatedOpacity(
                  opacity: _descAnimation.value,
                  duration: const Duration(milliseconds: timeShowAnimation),
                  child: widget.isExpanded
                      ? SizedBox(
                    height: widget.availableHeight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            widget.issue.description,
                            style: textStyleDescription.copyWith(color: Colors.black),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Вариант исправления:',
                            style: textStyleDescription,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.issue.suggestion,
                            style: textStyleDescription.copyWith(color: Colors.green),
                          ),
                          const Spacer(),
                          Center(
                              child: FractionallySizedBox(
                                widthFactor: 3 / 4,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    side: BorderSide(
                                      color: midnightPurple.withOpacity(0.47),
                                      width: widthBorderRadius,
                                    ),
                                    backgroundColor: veryPaleBlue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(borderRadius),
                                    ),
                                    minimumSize: const Size(0, 40),
                                    elevation: 0,
                                  ),
                                  onPressed: () {
                                    widget.onClose();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ApplyCorrections(
                                          originalResume: widget.resume,
                                          corrections: [widget.issue],
                                          singleCorrection: widget.issue,
                                        ),
                                      ),
                                    ).then((correctedResume) {
                                      if (correctedResume != null) {
                                        // Сохраняем исправленное резюме
                                        print('Исправленное резюме: $correctedResume');
                                      }
                                    });
                                  },
                                  child: Text(
                                    'Внедрить',
                                    style: TextStyle(
                                      fontFamily: 'Playfair',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      height: 1.0,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                          )
                        ],
                      ),
                    ),
                  )
                      : null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class Issue {
  final String errorText;
  final String suggestion;
  final String description;

  const Issue({
    required this.errorText,
    required this.suggestion,
    required this.description,
  });
}
import 'package:flutter/material.dart';
import 'package:open_pdf/pages/pdfViewer/widgets/pdf_actions_buttons_row.dart';
import 'package:open_pdf/utils/constants.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';

class ExpandableFab extends StatefulWidget {
  const ExpandableFab({super.key});

  @override
  ExpandableFabState createState() => ExpandableFabState();
}

class ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: 40,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleFab() {
    setState(() {
      _isExpanded = !_isExpanded;
      _isExpanded ? _controller.forward() : _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("context.isTablet ${context.screenWidth}");
    return AnimatedContainer(
      height: 50,
      width: _isExpanded
          ? !context.isMobile
              ? context.width(30)
              : context.width(90)
          : 50,
      curve: Curves.easeIn,
      duration: Constants.globalDuration,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: context.theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      padding: EdgeInsets.zero,
      child: SizedBox(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (_isExpanded)
              const Expanded(
                child: PdfActionsButtonRow(),
              ),
            IconButton(
              color: context.theme.scaffoldBackgroundColor,
              padding: EdgeInsets.zero,
              onPressed: () {
                _toggleFab();
              },
              icon: Align(
                alignment:
                    _isExpanded ? Alignment.centerRight : Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    _isExpanded
                        ? Icons.arrow_forward_ios_rounded
                        : Icons.arrow_back_ios_rounded,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

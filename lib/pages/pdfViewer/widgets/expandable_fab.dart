import 'package:flutter/material.dart';
import 'package:open_pdf/pages/pdfViewer/widgets/pdf_control_buttons.dart';
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
    return AnimatedContainer(
      duration: Constants.globalDuration,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
      ),
      padding: EdgeInsets.zero,
      width: _isExpanded ? context.screenWidth * 0.9 : 56.0,
      child: FloatingActionButton.extended(
        onPressed: () {
          _toggleFab();
        },
        extendedPadding: EdgeInsets.zero,

        // backgroundColor: ColorConstants.amberColor,
        // elevation: 4.0,
        label: const ActionsButtonRow(),
        icon: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Icon(_isExpanded ? Icons.close : Icons.arrow_back_ios)),
        isExtended: _isExpanded,
      ),
    );
  }
}

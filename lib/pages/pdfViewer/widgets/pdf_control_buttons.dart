import 'package:flutter/material.dart';
import 'package:open_pdf/pages/pdfViewer/widgets/dictonary_bottom_sheet.dart';
import 'package:open_pdf/pages/pdfViewer/widgets/page_information_widget.dart';
import 'package:open_pdf/providers/dictionary_provider.dart';
import 'package:open_pdf/providers/pdf_js_provider.dart';
import 'package:open_pdf/utils/constants.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
import 'package:provider/provider.dart';

class PdfControlButtons extends StatefulWidget {
  const PdfControlButtons({super.key});

  @override
  PdfControlButtonsState createState() => PdfControlButtonsState();
}

class PdfControlButtonsState extends State<PdfControlButtons>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _expandAnimation = Tween<double>(begin: 56.0, end: 250.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    )..addListener(() {
        setState(() {});
      });
  }

  void _toggleExpand() {
    if (isExpanded) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _expandAnimation.value,
      decoration: BoxDecoration(
        color: ColorConstants.amberColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (isExpanded) ...[
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () async {
                    await context.read<PdfJsProvider>().changePage(false);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                  onPressed: () async {
                    await context.read<PdfJsProvider>().changePage(true);
                  },
                ),
                IconButton(
                  icon:
                      const Icon(Icons.menu_book_outlined, color: Colors.white),
                  onPressed: () async {
                    context.hideKeyBoard();
                    final provider = context.read<DictionaryProvider>();
                    provider.clearResults();
                    await provider.fetchAllWords();
                    debugPrint(
                        "on bottom sheet call ${provider.results.length}");
                    await showModalBottomSheet(
                      context: context,
                      builder: (context) => const DictionaryBottomSheet(),
                    );
                  },
                ),
                const PageInformationWidget(),
              ],
            ],
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: IconButton(
              icon: Icon(isExpanded ? Icons.close : Icons.menu,
                  color: Colors.white),
              onPressed: _toggleExpand,
            ),
          ),
        ],
      ),
    );
  }
}

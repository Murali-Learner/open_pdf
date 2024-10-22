import 'package:flutter/material.dart';
import 'package:open_pdf/pages/pdfViewer/widgets/dictonary_bottom_sheet.dart';
import 'package:open_pdf/pages/pdfViewer/widgets/page_information_widget.dart';
import 'package:open_pdf/providers/pdf_control_provider.dart';
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
                  onPressed: () {
                    context.hideKeyBoard();
                    showModalBottomSheet(
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

class ActionsButtonRow extends StatelessWidget {
  const ActionsButtonRow({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<PdfControlProvider, PdfJsProvider>(
        builder: (context, pdfProvider, pdfJsProvider, _) {
      return ListView(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        children: [
          IconButton(
            tooltip: "Previous page",
            icon: Icon(
              Icons.arrow_back,
              color: ColorConstants.amberColor,
            ),
            onPressed: () async {
              await pdfJsProvider.changePage(false);
              // return await provider.previousPage();
            },
          ),
          IconButton(
            tooltip: "Next page",
            icon: Icon(
              Icons.arrow_forward,
              color: ColorConstants.amberColor,
            ),
            onPressed: () async {
              await pdfJsProvider.changePage(true);
              // await provider.nextPage();
            },
          ),
          const PageInformationWidget(),
          IconButton(
            tooltip: "Open dictionary",
            icon: Icon(
              Icons.menu_book_outlined,
              color: ColorConstants.amberColor,
            ),
            onPressed: () {
              context.hideKeyBoard();
              showModalBottomSheet(
                showDragHandle: true,
                context: context,
                backgroundColor: context.theme.scaffoldBackgroundColor,
                barrierColor: ColorConstants.color.withOpacity(0.5),
                isScrollControlled: true,
                useSafeArea: true,
                builder: (context) => const DictionaryBottomSheet(),
              );
            },
          ),
          IconButton(
            tooltip: "Slider",
            icon: Icon(
              pdfJsProvider.showSlider
                  ? Icons.arrow_drop_down_rounded
                  : Icons.arrow_drop_up_rounded,
              color: ColorConstants.amberColor,
              size: 40,
            ),
            onPressed: () async {
              pdfJsProvider.showSlider = !pdfJsProvider.showSlider;
            },
          ),
        ],
      );
    });
  }
}

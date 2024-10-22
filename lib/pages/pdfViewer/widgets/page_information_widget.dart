import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:open_pdf/providers/pdf_control_provider.dart';
import 'package:open_pdf/providers/pdf_js_provider.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
import 'package:open_pdf/utils/toast_utils.dart';
import 'package:provider/provider.dart';

class PageInformationWidget extends StatefulWidget {
  const PageInformationWidget({
    super.key,
  });

  @override
  State<PageInformationWidget> createState() => _PageInformationWidgetState();
}

class _PageInformationWidgetState extends State<PageInformationWidget> {
  late TextEditingController pageController;
  PdfControlProvider? pdfProvider;
  PdfJsProvider? pdfJsProvider;

  @override
  void initState() {
    super.initState();

    pdfProvider = context.read<PdfControlProvider>();
    pdfJsProvider = context.read<PdfJsProvider>();

    pageController =
        TextEditingController(text: pdfJsProvider!.currentPage.toString());
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        pdfJsProvider!.addListener(_updatePageController);
      },
    );
  }

  @override
  void dispose() {
    if (pdfJsProvider != null) {
      pdfJsProvider!.removeListener(_updatePageController);
    }

    pageController.dispose();
    super.dispose();
  }

  void _updatePageController() {
    if (pdfJsProvider != null) {
      setState(() {
        pageController.text = (pdfJsProvider!.currentPage).toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<PdfControlProvider, PdfJsProvider>(
      builder: (context, controlProvider, jsProvider, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 25),
              child: TextField(
                controller: pageController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
                style: context.textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
                onTap: () {
                  controlProvider.setConsiderScroll(false);
                },
                onSubmitted: (value) {
                  final newPage = int.tryParse(value);
                  log("newPage $newPage");
                  if (newPage != null &&
                      newPage > 0 &&
                      newPage <= jsProvider.totalPages) {
                    jsProvider.jumpPage(newPage);
                    // controlProvider.gotoPage(newPage);
                  } else {
                    ToastUtils.showErrorToast("Invalid page number");
                  }
                  controlProvider.setConsiderScroll(true);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text('/ ${jsProvider.totalPages}',
                  style: context.textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  )),
            ),
          ],
        );
      },
    );
  }
}

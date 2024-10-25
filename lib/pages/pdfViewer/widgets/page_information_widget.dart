import 'dart:developer';

import 'package:flutter/material.dart';
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
  PdfJsProvider? pdfJsProvider;

  @override
  void initState() {
    super.initState();

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
    return Consumer<PdfJsProvider>(
      builder: (context, jsProvider, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: context.width(12)),
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

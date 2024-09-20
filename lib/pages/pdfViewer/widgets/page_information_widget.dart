import 'package:flutter/material.dart';
import 'package:open_pdf/providers/pdf_control_provider.dart';
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

  @override
  void initState() {
    super.initState();

    pageController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        pdfProvider = context.read<PdfControlProvider>();

        pageController.text = (pdfProvider!.pdfCurrentPage).toString();

        pdfProvider!.addListener(_updatePageController);
      },
    );
  }

  @override
  void dispose() {
    if (pdfProvider != null) {
      pdfProvider!.removeListener(_updatePageController);
    }

    pageController.dispose();
    super.dispose();
  }

  void _updatePageController() {
    if (pdfProvider != null) {
      setState(() {
        pageController.text = pdfProvider!.pdfCurrentPage == 0 ||
                pdfProvider!.pdfCurrentPage == (pdfProvider!.totalPages - 1)
            ? (pdfProvider!.pdfCurrentPage + 1).toString()
            : pdfProvider!.pdfCurrentPage.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PdfControlProvider>(builder: (context, provider, _) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 25),
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
                if (newPage != null &&
                    newPage > 0 &&
                    newPage <= provider.totalPages) {
                  provider.setCurrentPage(newPage);

                  provider.gotoPage(newPage);
                } else {
                  ToastUtils.showErrorToast("Invalid page number");
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text('/ ${provider.totalPages}',
                style: context.textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                )),
          ),
        ],
      );
    });
  }
}

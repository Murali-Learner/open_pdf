import 'package:flutter/material.dart';
import 'package:open_pdf/providers/pdf_js_provider.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
import 'package:provider/provider.dart';

class PageNumberSlider extends StatelessWidget {
  const PageNumberSlider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PdfJsProvider>(
      builder: (context, provider, _) {
        if (!provider.showSlider) {
          return const IgnorePointer();
        }
        return Positioned(
          bottom: context.height(10),
          left: context.width(10),
          child: SizedBox(
            width: context.width(80),
            child: Card(
              child: Slider(
                value: provider.currentPage.toDouble(),
                min: 1,
                max: provider.totalPages.toDouble(),
                // divisions: 1,
                onChanged: (_) => {},
                onChangeEnd: (pageNo) {
                  provider.jumpPage(pageNo.toInt());
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

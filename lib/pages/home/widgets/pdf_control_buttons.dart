import 'package:flutter/material.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:provider/provider.dart';

class PdfControlButtons extends StatelessWidget {
  const PdfControlButtons({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Consumer<PdfProvider>(builder: (context, provider, _) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // IconButton(
          //   icon: const Icon(Icons.zoom_in),
          //   onPressed: () {
          //     provider.nextPage();
          //     provider.zoomUp();
          //   },
          // ),
          // IconButton(
          //   icon: const Icon(Icons.zoom_out),
          //   onPressed: () => provider.zoomDown(),
          // ),
          IconButton(
            icon: const Icon(Icons.first_page),
            onPressed: () => provider.gotoFirstPage(),
          ),
          IconButton(
            icon: const Icon(Icons.last_page),
            onPressed: () => provider.gotoLastPage(),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () => provider.nextPage(),
          ),
        ],
      );
    });
  }
}

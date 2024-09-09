import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:open_pdf/pages/download/download_page.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
import 'package:provider/provider.dart';

class FloatingDial extends StatelessWidget {
  const FloatingDial({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PdfProvider>(builder: (context, provider, _) {
      return provider.totalPdfList.isEmpty
          ? const SizedBox.shrink()
          : SpeedDial(
              icon: Icons.add,
              activeIcon: Icons.close,
              animationDuration: const Duration(milliseconds: 300),
              useRotationAnimation: true,
              elevation: 8.0,
              spaceBetweenChildren: 4,
              overlayColor: Colors.black,
              overlayOpacity: 0,
              children: [
                SpeedDialChild(
                    child: const Icon(Icons.file_copy),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    onTap: () async {
                      await provider.pickFile();
                    }),
                SpeedDialChild(
                  child: const Icon(Icons.download),
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  onTap: () {
                    context.push(navigateTo: const DownloadPage());
                  },
                ),
              ],
            );
    });
  }
}

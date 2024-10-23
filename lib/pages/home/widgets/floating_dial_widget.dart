import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:open_pdf/pages/download/downloads_page.dart';
import 'package:open_pdf/pages/pdfViewer/pdf_js_view.dart';
import 'package:open_pdf/providers/download_provider.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:open_pdf/utils/constants.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
import 'package:provider/provider.dart';

class FloatingDial extends StatelessWidget {
  const FloatingDial({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<PdfProvider, DownloadProvider>(
      builder: (context, pdfProvider, downloadProvider, _) {
        var list = [
          ...pdfProvider.localPdfList.values,
          ...downloadProvider.downloadedPdfMap.values
        ];
        return list.isEmpty
            ? const SizedBox.shrink()
            : SpeedDial(
                icon: Icons.add,
                activeIcon: Icons.close,
                animationDuration: const Duration(milliseconds: 150),
                useRotationAnimation: true,
                elevation: 8.0,
                childrenButtonSize: const Size.fromRadius(30),
                spaceBetweenChildren: 4,
                overlayColor: Colors.black,
                overlayOpacity: 0,
                children: [
                  SpeedDialChild(
                    child: Icon(
                      Icons.download,
                      color: ColorConstants.amberColor,
                    ),
                    backgroundColor: ColorConstants.color,
                    shape: const CircleBorder(),
                    onTap: () {
                      pdfProvider.clearSelectedFiles();
                      context.push(navigateTo: const DownloadPage());
                    },
                  ),
                  SpeedDialChild(
                    shape: const CircleBorder(),
                    child: Icon(
                      Icons.file_copy,
                      color: ColorConstants.amberColor,
                    ),
                    backgroundColor: ColorConstants.color,
                    onTap: () async {
                      pdfProvider.clearSelectedFiles();
                      context.read<PdfProvider>().pickFile().whenComplete(
                        () async {
                          if (pdfProvider.currentPDF != null) {
                            final base64 = await pdfProvider.convertBase64(
                                pdfProvider.currentPDF!.filePath!);

                            context.push(
                              navigateTo: PdfJsView(
                                base64: base64,
                                pdfName: pdfProvider.currentPDF!.fileName!,
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ],
              );
      },
    );
  }
}

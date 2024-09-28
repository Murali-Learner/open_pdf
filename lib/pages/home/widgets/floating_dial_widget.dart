import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:open_pdf/pages/download/downloads_page.dart';
import 'package:open_pdf/pages/pdfViewer/view_pdf_page.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:open_pdf/providers/theme_provider.dart';
import 'package:open_pdf/utils/constants.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
import 'package:provider/provider.dart';

class FloatingDial extends StatelessWidget {
  const FloatingDial({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<PdfProvider, ThemeProvider>(
      builder: (context, pdfProvider, themeProvider, _) {
        return pdfProvider.totalPdfList.isEmpty
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
                  // SpeedDialChild(
                  //   shape: const CircleBorder(),
                  //   child: Icon(
                  //     themeProvider.themeMode == ThemeMode.dark
                  //         ? Icons.light_mode
                  //         : Icons.dark_mode,
                  //     color: context.theme.primaryColor,
                  //   ),
                  //   backgroundColor: Colors.white,
                  //   onTap: () {
                  //     if (themeProvider.themeMode == ThemeMode.dark) {
                  //       themeProvider.setTheme(AppTheme.light);
                  //     } else {
                  //       themeProvider.setTheme(AppTheme.dark);
                  //     }
                  //   },
                  // ),
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
                      await context.read<PdfProvider>().pickFile().whenComplete(
                        () {
                          if (pdfProvider.currentPDF != null) {
                            context.push(
                                navigateTo:
                                    ViewPdfPage(pdf: pdfProvider.currentPDF!));
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

import 'package:flutter/material.dart';
import 'package:open_pdf/global_widgets/global_loading_widget.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:provider/provider.dart';

class DownloadButton extends StatefulWidget {
  const DownloadButton({
    super.key,
    required this.pdfUrl,
  });
  final String pdfUrl;
  @override
  State<DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  @override
  Widget build(BuildContext context) {
    return Consumer<PdfProvider>(builder: (context, provider, _) {
      return IconButton(
        icon: provider.downloadBtnLoading
            ? const GlobalLoadingWidget()
            : const Icon(
                Icons.download,
                size: 30,
              ),
        onPressed: provider.downloadBtnLoading
            ? null
            : () async {
                // if (widget.pdfUrl.isEmpty) {
                //   ToastUtils.showErrorToast("Enter valid URL");
                //   return;
                // }

                const link1 =
                    "http://englishonlineclub.com/pdf/iOS%20Programming%20-%20The%20Big%20Nerd%20Ranch%20Guide%20(6th%20Edition)%20[EnglishOnlineClub.com].pdf";
                // const link2 =
                //     "https://morth.nic.in/sites/default/files/dd12-13_0.pdf";

                await provider.downloadAndSavePdf(
                  // widget.pdfUrl,
                  // "https://enos.itcollege.ee/~jpoial/allalaadimised/reading/Android-Programming-Cookbook.pdf",
                  link1,
                );
              },
      );
    });
  }
}

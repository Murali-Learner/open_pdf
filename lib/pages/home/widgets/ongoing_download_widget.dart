import 'package:flutter/material.dart';
import 'package:open_pdf/models/pdf_model.dart';
import 'package:open_pdf/providers/download_provider.dart';
import 'package:provider/provider.dart';

class OngoingDownloadWidget extends StatefulWidget {
  final PdfModel pdf;

  const OngoingDownloadWidget({super.key, required this.pdf});

  @override
  OngoingDownloadWidgetState createState() => OngoingDownloadWidgetState();
}

class OngoingDownloadWidgetState extends State<OngoingDownloadWidget> {
  bool _isCancelling = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<DownloadProvider>();
    return _isCancelling
        ? const SizedBox(
            height: 35,
            width: 35,
            child: CircularProgressIndicator(),
          )
        : GestureDetector(
            onTap: () async {
              if (mounted) {
                setState(() {
                  _isCancelling = true;
                });
              }

              await provider.cancelDownload(widget.pdf);

              if (mounted) {
                setState(() {
                  _isCancelling = false;
                });
              }
            },
            child: const Icon(
              Icons.cancel,
              color: Colors.red,
              size: 35,
            ),
          );
  }
}

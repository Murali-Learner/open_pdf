import 'package:flutter/material.dart';
import 'package:open_pdf/pages/pdfViewer/view_pdf_page.dart';
import 'package:open_pdf/utils/constants.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';

class PdfViewAppBar extends StatelessWidget {
  const PdfViewAppBar({
    super.key,
    required this.pdfName,
  });
  final String pdfName;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Constants.globalDuration,
      height: context.height(7),
      decoration: BoxDecoration(
          color: context.theme.appBarTheme.backgroundColor,
          boxShadow: context.theme.brightness == Brightness.dark
              ? null
              : [
                  BoxShadow(
                    blurRadius: 6,
                    spreadRadius: 0.1,
                    offset: const Offset(0, 8),
                    color: Colors.grey.withOpacity(0.6),
                  )
                ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
              onPressed: () {
                context.pop();
              },
              icon: const Icon(Icons.arrow_back)),
          Expanded(
            flex: 6,
            child: Tooltip(
              message: pdfName,
              child: Text(
                "${pdfName}",
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyLarge!
                    .copyWith(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          // const Spacer(),
        ],
      ),
    );
  }
}

Future<String?> _passwordDialog(BuildContext context) async {
  final textController = TextEditingController();
  return await showDialog<String?>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return PasswordDialogWidget(textController: textController);
    },
  );
}

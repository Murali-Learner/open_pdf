// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:pdfrx/pdfrx.dart';
// import 'package:pdf_reader/providers/pdf_provider.dart';
// import 'package:pdf_reader/widgets/global_loading_widget.dart';
// import 'package:provider/provider.dart';

// class ViewPdfPage extends StatelessWidget {
//   const ViewPdfPage({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('PDF Viewer'),
//       ),
//       body: Consumer<PdfProvider>(
//         builder: (context, provider, _) {
//           if (provider.isLoading || provider.pdfController == null) {
//             return const GlobalLoadingWidget();
//           }

//           return Column(
//             children: [
//               // Container(
//               //     margin: const EdgeInsets.symmetric(horizontal: 24),
//               //     child: Text('Sharing data: \n${list?.join("\n\n")}\n')),
//               Expanded(
//                 child: PdfViewer.asset(
//                   provider.currentPDF!.filePath,
//                   controller: provider.pdfController!,
//                   params: PdfViewerParams(
//                     onViewerReady: (document, controller) {
//                       provider.handlePDF();

//                       controller.setZoom(controller.centerPosition, 0.3);
//                     },
//                     boundaryMargin: const EdgeInsets.symmetric(
//                         vertical: 5.0, horizontal: 5.0),
//                     activeMatchTextColor: Colors.red,
//                     enableTextSelection: true,
//                     panEnabled: true,
//                     onPageChanged: (pageNumber) {
//                       log("pageNumber: $pageNumber");
//                       final pdf = provider.currentPDF!.copyWith(
//                         pageNumber: pageNumber,
//                       );

//                       provider.setCurrentPDF(pdf);
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

// ignore_for_file: implementation_imports

import 'package:flutter/material.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
import 'package:open_pdf/utils/extensions/spacer_extension.dart';
import 'package:wikipedia/src/models/summary_data_model.dart';

class WikiBottomSheet extends StatelessWidget {
  const WikiBottomSheet({
    super.key,
    required this.pageData,
  });

  final WikipediaSummaryData pageData;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 10.0,
      ),
      constraints: BoxConstraints(maxHeight: context.height(80)),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pageData.title ?? '',
                    style: context.textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    pageData.description ?? '',
                    style: const TextStyle(
                        color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                  8.vSpace,
                  Text(
                    pageData.extract ?? '',
                    style: context.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

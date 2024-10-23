import 'package:flutter/material.dart';
import 'package:open_pdf/global_widgets/global_text_form_fields.dart';
import 'package:open_pdf/global_widgets/shimmer_loading.dart';
import 'package:open_pdf/pages/dictionary/widgets/no_results_found.dart';
import 'package:open_pdf/pages/pdfViewer/widgets/wiki_bottom_sheet.dart';
import 'package:open_pdf/providers/dictionary_provider.dart';
import 'package:open_pdf/utils/constants.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
import 'package:open_pdf/utils/extensions/spacer_extension.dart';
import 'package:open_pdf/utils/toast_utils.dart';
import 'package:provider/provider.dart';
import 'package:wikipedia/wikipedia.dart';

class WikiSearchListWidget extends StatefulWidget {
  const WikiSearchListWidget({super.key, required this.searchWord});
  final String searchWord;

  @override
  State<WikiSearchListWidget> createState() => _WikiSearchListWidgetState();
}

class _WikiSearchListWidgetState extends State<WikiSearchListWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController(text: widget.searchWord);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DictionaryProvider>(context);

    return Column(
      children: [
        10.vSpace,
        GlobalTextFormField(
          controller: _controller,
          onChanged: (value) {
            provider.searchWikipedia(value);
          },
          border: context.theme.brightness == Brightness.dark
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white))
              : null,
          labelText: 'Search Wikipedia',
        ),
        10.vSpace,
        Expanded(
          child: Consumer<DictionaryProvider>(builder: (context, provider, _) {
            if (provider.isWikiLoading) {
              return const ShimmerLoading();
            }

            if (provider.wikiResults.isEmpty) {
              return const NoResultsFound();
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              separatorBuilder: (context, index) => 5.vSpace,
              itemCount: provider.wikiResults.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final wikiResult = provider.wikiResults[index];
                return WikipediaCard(
                  wikiResult: wikiResult,
                );
              },
            );
          }),
        ),
      ],
    );
  }
}

class WikipediaCard extends StatelessWidget {
  const WikipediaCard({
    super.key,
    required this.wikiResult,
  });
  final WikipediaSearch wikiResult;
  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      child: GestureDetector(
        onTap: () async {
          Wikipedia instance = Wikipedia();
          final pageData = await instance.searchSummaryWithPageId(
              pageId: wikiResult.pageid!);
          if (pageData != null) {
            showModalBottomSheet(
              showDragHandle: true,
              context: context,
              backgroundColor: context.theme.scaffoldBackgroundColor,
              barrierColor: ColorConstants.color.withOpacity(0.5),
              isScrollControlled: true,
              useSafeArea: true,
              builder: (context) => WikiBottomSheet(pageData: pageData),
            );
          } else {
            ToastUtils.showErrorToast("Page data not found");
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: ColorConstants.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wikiResult.title ?? '',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: context.textTheme.titleLarge!.color,
                      ),
                    ),
                    4.vSpace,
                    Text(
                      wikiResult.snippet ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        color: context.textTheme.bodyMedium!.color
                            ?.withOpacity(0.8),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

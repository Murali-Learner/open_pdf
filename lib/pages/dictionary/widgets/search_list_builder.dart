import 'package:flutter/material.dart';
import 'package:open_pdf/global_widgets/shimmer_loading.dart';
import 'package:open_pdf/pages/dictionary/widgets/no_results_found.dart';
import 'package:open_pdf/pages/dictionary/widgets/word_tile_widget.dart';
import 'package:open_pdf/providers/dictionary_provider.dart';
import 'package:open_pdf/utils/extensions/spacer_extension.dart';
import 'package:provider/provider.dart';

class SearchListBuilder extends StatefulWidget {
  const SearchListBuilder({
    super.key,
  });

  @override
  State<SearchListBuilder> createState() => _SearchListBuilderState();
}

class _SearchListBuilderState extends State<SearchListBuilder> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Consumer<DictionaryProvider>(builder: (context, provider, _) {
        if (provider.isLoading) {
          return const ShimmerLoading();
        }
        if (provider.results.isEmpty) {
          return const NoResultsFound();
        }
        final results = provider.results.values.toList();
        debugPrint(
            "search list results ${results.length} ${results.last.toMap()}");
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          separatorBuilder: (context, index) => 5.vSpace,
          itemCount: results.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final item = results[index];
            return WordTile(word: item);
          },
        );
      }),
    );
  }
}

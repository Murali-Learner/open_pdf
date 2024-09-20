import 'package:flutter/material.dart';
import 'package:open_pdf/pages/dictionary/dictionary_page.dart';

class DictionaryBottomSheet extends StatelessWidget {
  const DictionaryBottomSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      // expand: true,
      builder: (context) {
        return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(5.0),
            margin: const EdgeInsets.all(5.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(16.0),
              ),
            ),
            child: DictionaryPage(
              showAppbar: false,
            ));
      },
    );
  }
}
  //  padding: const EdgeInsets.all(10.0),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   word.word,
  //                   style: context.textTheme.bodyLarge,
  //                   textAlign: TextAlign.center,
  //                 ),
  //                 const SizedBox(height: 8),
  //                 Text(
  //                   word.definition,
  //                   style: context.textTheme.bodyMedium,
  //                 ),
  //                 const SizedBox(height: 16),
  //                 if (word.examples.isNotEmpty) ...[
  //                   Text(
  //                     'Examples:',
  //                     style: context.textTheme.bodyLarge,
  //                   ),
  //                   const SizedBox(height: 8),
  //                   ...word.examples.map((example) => Text('• $example')),
  //                   const SizedBox(height: 16),
  //                 ],
  //                 if (word.synonyms.isNotEmpty) ...[
  //                   Text(
  //                     'Synonyms:',
  //                     style: context.textTheme.bodyLarge,
  //                   ),
  //                   const SizedBox(height: 8),
  //                   Text(word.synonyms.join(', ')),
  //                   const SizedBox(height: 16),
  //                 ],
  //                 if (word.antonyms.isNotEmpty) ...[
  //                   Text(
  //                     'Antonyms:',
  //                     style: context.textTheme.bodyMedium,
  //                   ),
  //                   const SizedBox(height: 8),
  //                   Text(word.antonyms.join(', ')),
  //                   const SizedBox(height: 16),
  //                 ],
  //               ],
  //             ),
  //           ),

import 'package:flutter/material.dart';
import 'package:open_pdf/pages/dictionary/widgets/dictionary_column.dart';
import 'package:open_pdf/providers/dictionary_provider.dart';
import 'package:open_pdf/utils/constants.dart';
import 'package:provider/provider.dart';

class DictionaryPage extends StatefulWidget {
  const DictionaryPage({
    super.key,
  });

  @override
  DictionaryPageState createState() => DictionaryPageState();
}

class DictionaryPageState extends State<DictionaryPage> {
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    final provider = context.read<DictionaryProvider>();
    await provider.fetchAllWords();
    provider.toggleClearButton(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dictionary',
          style: TextStyle(
            color: ColorConstants.amberColor,
          ),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.0),
        child: DictionaryPageColumn(),
      ),
    );
  }
}

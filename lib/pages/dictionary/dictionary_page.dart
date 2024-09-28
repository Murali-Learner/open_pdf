import 'package:flutter/material.dart';
import 'package:open_pdf/pages/dictionary/widgets/dictionary_column.dart';
import 'package:open_pdf/utils/constants.dart';

class DictionaryPage extends StatefulWidget {
  const DictionaryPage({
    super.key,
  });

  @override
  DictionaryPageState createState() => DictionaryPageState();
}

class DictionaryPageState extends State<DictionaryPage> {
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

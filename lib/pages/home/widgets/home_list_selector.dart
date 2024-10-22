import 'package:flutter/material.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:open_pdf/utils/enumerates.dart';
import 'package:open_pdf/utils/extensions/naming_extension.dart';
import 'package:provider/provider.dart';

class HomeListSelector extends StatefulWidget {
  const HomeListSelector({super.key});

  @override
  HomeListSelectorState createState() => HomeListSelectorState();
}

class HomeListSelectorState extends State<HomeListSelector> {
  @override
  Widget build(BuildContext context) {
    return Consumer<PdfProvider>(builder: (context, provider, _) {
      return DropdownButton<CheckList>(
        items: <CheckList>[
          CheckList.all,
          CheckList.local,
          CheckList.downloads,
        ].map((CheckList value) {
          return DropdownMenuItem<CheckList>(
            value: value,
            child: Text(value.name.toPascalCase()),
          );
        }).toList(),
        padding: const EdgeInsets.symmetric(
          horizontal: 4.0,
        ),
        underline: const SizedBox.shrink(),
        borderRadius: BorderRadius.circular(3),
        elevation: 1,
        value: provider.selectedCheckList,
        onChanged: (CheckList? checkValue) {
          provider.setSelectedCheckList(checkValue!);
        },
      );
    });
  }
}

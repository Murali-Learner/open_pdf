import 'package:flutter/material.dart';
import 'package:open_pdf/pages/home/widgets/home_pdf_grid.dart';
import 'package:open_pdf/pages/home/widgets/home_pdf_list.dart';
import 'package:open_pdf/pages/home/widgets/pop_up_menu_button.dart';
import 'package:open_pdf/pages/home/widgets/view_mode_button.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:open_pdf/utils/enumarates.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
import 'package:open_pdf/utils/extensions/spacer_extension.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PdfProvider provider;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    provider = context.read<PdfProvider>();
    await Future.delayed(Duration.zero).whenComplete(() async {
      await provider.handleIntent();
      provider.internetSubscription();
      await provider.askPermissions();
    });
  }

  @override
  void dispose() {
    super.dispose();
    provider.internetDispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Open PDF"),
        actions: const [PopupMenuButtonWidget()],
        elevation: 5.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Consumer<PdfProvider>(builder: (context, provider, _) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: context.theme.primaryColor.withOpacity(0.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const ViewModeButton(
                          icon: Icons.window,
                          viewMode: ViewMode.grid,
                        ),
                        10.hSpace,
                        const ViewModeButton(
                          icon: Icons.list,
                          viewMode: ViewMode.list,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
            10.vSpace,
            Expanded(
              child: Consumer<PdfProvider>(builder: (context, provider, _) {
                return provider.selectedViewMode == ViewMode.list
                    ? const HomePdfListView()
                    : HomePdfGridView(provider: provider);
              }),
            ),
          ],
        ),
      ),
    );
  }
}

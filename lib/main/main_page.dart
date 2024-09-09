import 'package:flutter/material.dart';
import 'package:open_pdf/main/custom_nav_bar.dart';
import 'package:open_pdf/pages/dictionary/dictionary_page.dart';
import 'package:open_pdf/pages/home/home_page.dart'; // Your HomePage
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
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
      body: Consumer<PdfProvider>(
        builder: (context, navigationProvider, _) {
          switch (navigationProvider.currentIndex) {
            case 1:
              return const DictionaryPage();
            case 0:
            default:
              return const HomePage(); // Only HomePage content
          }
        },
      ),
      bottomNavigationBar: Consumer<PdfProvider>(
        builder: (context, navigationProvider, _) {
          return CustomBottomNavigationBar(
            currentIndex: navigationProvider.currentIndex,
            onTap: (index) {
              navigationProvider.setCurrentIndex(index);
            },
          );
        },
      ),
    );
  }
}

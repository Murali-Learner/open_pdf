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
  late final PdfProvider pdfProvider;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    pdfProvider = context.read<PdfProvider>();

    await Future.delayed(Duration.zero).whenComplete(() async {
      await pdfProvider.handleIntent(context);
      pdfProvider.internetSubscription();
      await pdfProvider.askPermissions();
      // await showNotificationDialog();
    });
  }

  // Future<void> showNotificationDialog() async {
  //   final notificationPermission = await Permission.notification.isGranted;
  //   if (!notificationPermission) {
  //     showDialog(
  //         context: context,
  //         builder: (context) {
  //           return AlertDialog(
  //             content: NotificationPermissionDialog(
  //               onAllow: () async {
  //                 context.pop();
  //                 await pdfProvider.askPermissions();
  //               },
  //               onDeny: () {
  //                 context.pop();
  //               },
  //             ),
  //           );
  //         });
  //   }
  // }

  @override
  void dispose() {
    super.dispose();
    pdfProvider.internetDispose();
    pdfProvider.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<PdfProvider>(
        builder: (context, navigationProvider, _) {
          switch (navigationProvider.currentNavIndex) {
            case 1:
              return const DictionaryPage();
            case 0:
            default:
              return const HomePage();
          }
        },
      ),
      bottomNavigationBar: Consumer<PdfProvider>(
        builder: (context, provider, _) {
          return CustomBottomNavigationBar(
            currentIndex: provider.currentNavIndex,
            onTap: (index) {
              provider.clearSelectedFiles();
              provider.setCurrentNavIndex(index);
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:open_pdf/main/custom_nav_bar.dart';
import 'package:open_pdf/main/notification_permission_dialog.dart';
import 'package:open_pdf/pages/dictionary/dictionary_page.dart';
import 'package:open_pdf/pages/home/home_page.dart'; // Your HomePage
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
import 'package:permission_handler/permission_handler.dart';
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
      await showNotificationDialog();
    });
  }

  Future<void> showNotificationDialog() async {
    final notificationPermission = await Permission.notification.isGranted;
    if (!notificationPermission) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: NotificationPermissionDialog(
                onAllow: () async {
                  context.pop();
                  await provider.askPermissions();
                },
                onDeny: () {
                  context.pop();
                },
              ),
            );
          });
    }
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

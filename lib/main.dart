import 'package:flutter/material.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:open_pdf/helpers/hive_helper.dart';
import 'package:open_pdf/main/main_page.dart';
import 'package:open_pdf/providers/dictionary_provider.dart';
import 'package:open_pdf/providers/download_provider.dart';
import 'package:open_pdf/providers/pdf_control_provider.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:open_pdf/providers/theme_provider.dart';
import 'package:open_pdf/utils/theme_data.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await MediaStore.ensureInitialized();
  MediaStore.appFolder = "OpenPdf";

  HiveHelper hiveHelper = HiveHelper();
  await hiveHelper.initHive();

  // NotificationHelper notificationHelper = NotificationHelper();
  // notificationHelper.initializeNotifications();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PdfProvider()),
        ChangeNotifierProvider(create: (_) => DictionaryProvider()),
        ChangeNotifierProvider(create: (_) => PdfControlProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProxyProvider<PdfProvider, DownloadProvider>(
          create: (context) => DownloadProvider(
              Provider.of<PdfProvider>(context, listen: false)),
          update: (context, pdfProvider, downloadProvider) =>
              (downloadProvider ?? DownloadProvider(pdfProvider))
                ..pdfProvider = pdfProvider,
        ),
      ],
      child: Consumer<ThemeProvider>(builder: (context, provider, _) {
        return MaterialApp(
          title: 'Open PDF',
          debugShowCheckedModeBanner: false,
          theme: appTheme,
          // darkTheme: darkTheme,
          themeMode: provider.themeMode,
          home: const MainPage(),
        );
      }),
    );
  }
}

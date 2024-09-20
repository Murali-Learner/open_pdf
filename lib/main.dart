import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:open_pdf/helpers/hive_helper.dart';
import 'package:open_pdf/helpers/notication_helper.dart';
import 'package:open_pdf/main/main_page.dart';
import 'package:open_pdf/providers/dictionary_provider.dart';
import 'package:open_pdf/providers/pdf_control_provider.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:open_pdf/utils/theme_data.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await MediaStore.ensureInitialized();
  MediaStore.appFolder = "OpenPDF";

  HiveHelper hiveHelper = HiveHelper();
  await hiveHelper.initHive();

  NotificationHelper notificationHelper = NotificationHelper();
  notificationHelper.initializeNotifications();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PdfProvider()),
        ChangeNotifierProvider(create: (context) => DictionaryProvider()),
        ChangeNotifierProvider(create: (context) => PdfControlProvider()),
      ],
      child: MaterialApp(
        title: 'Open PDF',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        home: const MainPage(),
      ),
    );
  }
}

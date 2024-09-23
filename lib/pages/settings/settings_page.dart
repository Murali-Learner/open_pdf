import 'package:flutter/material.dart';
import 'package:open_pdf/providers/theme_provider.dart';
import 'package:open_pdf/utils/enumerates.dart';
import 'package:open_pdf/utils/extensions/spacer_extension.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final themeOptions = {
      AppTheme.light: 'Light Theme',
      AppTheme.dark: 'Dark Theme',
      AppTheme.system: 'System Default',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Appearance', context),
            10.vSpace,
            _buildThemeSelection(context, themeProvider, themeOptions),
            30.vSpace,
            // _buildSectionTitle('Other Settings', context),
            // ListTile(
            //   leading: const Icon(Icons.notifications_outlined),
            //   title: const Text('Notifications'),
            //   trailing: Switch(
            //     value: true,
            //     onChanged: (value) {},
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }

  Widget _buildThemeSelection(BuildContext context, ThemeProvider themeProvider,
      Map<AppTheme, String> themeOptions) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 12.0),
        child: Row(
          children: [
            const Icon(Icons.color_lens_outlined, size: 24),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                'Theme',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            DropdownButton<AppTheme>(
              value: _getCurrentAppTheme(themeProvider.themeMode),
              borderRadius: BorderRadius.circular(10),
              items: themeOptions.entries.map((entry) {
                return DropdownMenuItem<AppTheme>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (AppTheme? newTheme) {
                if (newTheme != null) {
                  themeProvider.setTheme(newTheme);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  AppTheme _getCurrentAppTheme(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return AppTheme.light;
      case ThemeMode.dark:
        return AppTheme.dark;
      case ThemeMode.system:
      default:
        return AppTheme.system;
    }
  }
}

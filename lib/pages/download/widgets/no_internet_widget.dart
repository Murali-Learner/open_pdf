import 'package:flutter/material.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
import 'package:provider/provider.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.signal_wifi_off,
            size: 100,
            color: context.theme.iconTheme.color,
          ),
          const SizedBox(height: 20),
          Text(
            'No Internet Connection',
            style: context.textTheme.bodyLarge,
          ),
          const SizedBox(height: 10),
          Text(
            'Please check your network settings.',
            style: context.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              context.read<PdfProvider>().internetSubscription();
            },
            child: Text('Retry', style: context.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

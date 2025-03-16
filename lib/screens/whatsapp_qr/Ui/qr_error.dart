import 'package:flutter/material.dart';
import 'package:phsyio_up/screens/whatsapp_qr/cubit/whatsapp_qr_cubit.dart'; // Update with your actual import path

class WhatsAppQRErrorWidget extends StatelessWidget {
  final String errorMessage;
  
  const WhatsAppQRErrorWidget({
    Key? key,
    required this.errorMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = WhatsappQrCubit.get(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'WhatsApp Connection Issue',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Unable to load WhatsApp QR code. You can try again or continue without this feature.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => cubit.refreshQRCode(context),
              child: Text('Try Again'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => cubit.skipWhatsAppFeature(context),
              child: Text('Skip WhatsApp Feature'),
            ),
          ],
        ),
      ),
    );
  }
}
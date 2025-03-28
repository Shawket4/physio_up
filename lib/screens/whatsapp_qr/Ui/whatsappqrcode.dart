// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:phsyio_up/components/app_bar.dart';
import 'package:phsyio_up/main.dart';
import 'package:phsyio_up/screens/whatsapp_qr/cubit/whatsapp_qr_cubit.dart';

class WhatsAppQRCode extends StatefulWidget {
  const WhatsAppQRCode({super.key});

  @override
  State<WhatsAppQRCode> createState() => _WhatsAppQRCodeState();
}

class _WhatsAppQRCodeState extends State<WhatsAppQRCode> {


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WhatsappQrCubit()..getQRCode(),
      child: BlocConsumer<WhatsappQrCubit, WhatsappQrState>(
        listener: (context, state) {
          // Optional: Handle state changes that require UI feedback
          if (state is RefreshingQrCodeFailure) {
            // Error handling is already in the cubit, so nothing needed here
          }
        },
        builder: (context, state) {
          final cubit = WhatsappQrCubit.get(context);
          
          return Scaffold(
            appBar: CustomAppBar(title: "WhatsApp Integration", actions: []),
            body: SafeArea(
              child: _buildBody(context, state, cubit),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildBody(BuildContext context, WhatsappQrState state, WhatsappQrCubit cubit) {
    // Loading states
    if (state is FetchingQrCodeLoading || state is WhatsappQrInitial) {
      return Center(
        child: Lottie.asset(
          "assets/lottie/Loading.json",
          height: 200,
          width: 200,
        ),
      );
    }
    
    // Error states
    if (state is FetchingQrCodeFailure || state is RefreshingQrCodeFailure) {
      return _buildErrorView(context, cubit);
    }
    
    // Success states (or any other state)
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                "assets/lottie/whatsapp_animation.json",
                height: 120,
                width: 120,
              ),
              const SizedBox(height: 24),
              Text(
                'Link WhatsApp to Physio-Up',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Scan this QR code with WhatsApp on your phone to enable messaging integration.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 32),

              // QR Code Container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    state is RefreshingQrCodeLoading
                        ? Container(
                            height: 260,
                            width: 260,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[100],
                            ),
                            child: Center(
                              child: Lottie.asset(
                                "assets/lottie/Loading.json",
                                height: 200,
                                width: 200,
                              ),
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              cubit.qrCodeBytes.data,
                              height: 260,
                              width: 260,
                              fit: BoxFit.cover,
                            ),
                          ),
                    const SizedBox(height: 16),

                    // Refresh button
                    TextButton.icon(
                      onPressed: state is RefreshingQrCodeLoading
                          ? null
                          : () => cubit.refreshQRCode(context),
                      icon: Icon(Icons.refresh),
                      label: Text('Refresh QR Code'),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Instructions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          child: Text('1',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Open WhatsApp on your phone',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          child: Text('2',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Tap Menu → Linked Devices → Link a Device',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          child: Text('3',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Point your phone camera at this QR code',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Skip WhatsApp Integration'),
                            content: Text(
                              'You can continue without WhatsApp integration, but you won\'t be able to send automatic messages to clients. You can set this up later from settings.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  cubit.skipWhatsAppFeature(context);
                                },
                                child: Text('Skip'),
                              ),
                            ],
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Theme.of(context).primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Skip for now'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Checking WhatsApp connection...'),
                          ),
                        );
                        Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (_) => MainWidget())
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('I\'ve scanned'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildErrorView(BuildContext context, WhatsappQrCubit cubit) {
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
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
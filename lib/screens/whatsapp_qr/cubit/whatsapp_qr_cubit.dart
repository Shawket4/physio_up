import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phsyio_up/components/dio_helper.dart';
import 'package:phsyio_up/main.dart';
import 'package:phsyio_up/router.dart';

part 'whatsapp_qr_state.dart';

class WhatsappQrCubit extends Cubit<WhatsappQrState> {
  WhatsappQrCubit() : super(WhatsappQrInitial());
  
  static WhatsappQrCubit get(context) => BlocProvider.of(context);
  
  bool isLoading = false;
  late Response<dynamic> qrCodeBytes;
  bool hasError = false;
  String errorMessage = '';
  
  Future<void> getQRCode() async {
    emit(FetchingQrCodeLoading());
    isLoading = true;
    
    try {
      qrCodeBytes = await getDataAsBytes("$ServerIP/api/protected/GetWhatsAppQRCode");
      isLoading = false;
      hasError = false;
      emit(FetchingQrCodeSuccess(qrCodeBytes));
    } catch (e) {
      isLoading = false;
      hasError = true;
      errorMessage = e.toString();
      emit(FetchingQrCodeFailure(errorMessage));
    }
  }
  
  void proceedToApp(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const RouterWidget())
    );
  }
  
  void skipWhatsAppFeature(BuildContext context) {
    // Skip WhatsApp QR code functionality and proceed to main app
    proceedToApp(context);
  }
  
  void refreshQRCode(BuildContext context) async {
    isLoading = true;
    emit(RefreshingQrCodeLoading());
    
    try {
      qrCodeBytes = await getDataAsBytes("$ServerIP/api/protected/GetWhatsAppQRCode");
      isLoading = false;
      hasError = false;
      emit(RefreshingQrCodeSuccess(qrCodeBytes));
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('QR code refreshed'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } catch (e) {
      isLoading = false;
      hasError = true;
      errorMessage = e.toString();
      emit(RefreshingQrCodeFailure(errorMessage));
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to refresh QR code'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }
}
part of 'whatsapp_qr_cubit.dart';

abstract class WhatsappQrState {}

class WhatsappQrInitial extends WhatsappQrState {}

// States for initial fetch
class FetchingQrCodeLoading extends WhatsappQrState {}

class FetchingQrCodeSuccess extends WhatsappQrState {
  final Response<dynamic> qrCodeBytes;
  FetchingQrCodeSuccess(this.qrCodeBytes);
}

class FetchingQrCodeFailure extends WhatsappQrState {
  final String error;
  FetchingQrCodeFailure(this.error);
}

// States for refresh action
class RefreshingQrCodeLoading extends WhatsappQrState {}

class RefreshingQrCodeSuccess extends WhatsappQrState {
  final Response<dynamic> qrCodeBytes;
  RefreshingQrCodeSuccess(this.qrCodeBytes);
}

class RefreshingQrCodeFailure extends WhatsappQrState {
  final String error;
  RefreshingQrCodeFailure(this.error);
}
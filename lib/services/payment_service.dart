import 'payment_service_stub.dart'
    if (dart.library.html) 'payment_service_web.dart';

class PaymentResult {
  const PaymentResult({
    required this.paymentId,
    this.orderId,
    this.signature,
  });

  final String paymentId;
  final String? orderId;
  final String? signature;
}

abstract class PaymentService {
  Future<PaymentResult> payWithRazorpay({
    required int amountInPaise,
    required String customerEmail,
    required String customerContact,
    required String description,
  });
}

PaymentService createPaymentService() => createPlatformPaymentService();

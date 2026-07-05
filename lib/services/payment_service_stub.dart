import 'payment_service.dart';

PaymentService createPlatformPaymentService() => _DemoPaymentService();

class _DemoPaymentService implements PaymentService {
  @override
  Future<PaymentResult> payWithRazorpay({
    required int amountInPaise,
    required String customerEmail,
    required String customerContact,
    required String description,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return PaymentResult(
      paymentId: 'demo_razorpay_${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}

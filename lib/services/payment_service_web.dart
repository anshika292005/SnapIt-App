// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

import 'payment_service.dart';

const _razorpayKeyId = 'rzp_test_T8hKxJEntWLdWq';

PaymentService createPlatformPaymentService() => _RazorpayWebPaymentService();

class _RazorpayWebPaymentService implements PaymentService {
  Future<void>? _scriptLoader;

  @override
  Future<PaymentResult> payWithRazorpay({
    required int amountInPaise,
    required String customerEmail,
    required String customerContact,
    required String description,
  }) async {
    await _ensureCheckoutScript();

    final completer = Completer<PaymentResult>();
    late final StreamSubscription<html.Event> successSubscription;
    late final StreamSubscription<html.Event> cancelSubscription;

    void cleanup() {
      successSubscription.cancel();
      cancelSubscription.cancel();
    }

    successSubscription =
        html.window.on['blinkit-razorpay-success'].listen((event) {
      if (completer.isCompleted) {
        return;
      }
      final detail = (event as html.CustomEvent).detail?.toString() ?? '{}';
      final data = jsonDecode(detail) as Map<String, dynamic>;
      cleanup();
      completer.complete(
        PaymentResult(
          paymentId: data['razorpay_payment_id'] as String? ?? 'paid',
          orderId: data['razorpay_order_id'] as String?,
          signature: data['razorpay_signature'] as String?,
        ),
      );
    });

    cancelSubscription = html.window.on['blinkit-razorpay-cancel'].listen((_) {
      if (completer.isCompleted) {
        return;
      }
      cleanup();
      completer.completeError('Payment cancelled');
    });

    final options = {
      'key': _razorpayKeyId,
      'amount': amountInPaise,
      'currency': 'INR',
      'name': 'Blinkit Grocery',
      'description': description,
      'prefill': {
        'email': customerEmail,
        'contact': customerContact,
      },
      'theme': {
        'color': '#0C831F',
      },
    };

    html.window.dispatchEvent(
      html.CustomEvent(
        'blinkit-razorpay-open',
        detail: jsonEncode(options),
      ),
    );

    return completer.future;
  }

  Future<void> _ensureCheckoutScript() {
    final existing = _scriptLoader;
    if (existing != null) {
      return existing;
    }

    final completer = Completer<void>();
    _scriptLoader = completer.future;

    final checkoutScript = html.ScriptElement()
      ..src = 'https://checkout.razorpay.com/v1/checkout.js'
      ..async = true;
    checkoutScript.onLoad.first.then((_) {
      _installBridge();
      completer.complete();
    });
    checkoutScript.onError.first.then(
      (_) => completer.completeError('Unable to load Razorpay checkout'),
    );
    html.document.head?.append(checkoutScript);

    return completer.future;
  }

  void _installBridge() {
    if (html.document.getElementById('blinkit-razorpay-bridge') != null) {
      return;
    }

    final bridgeScript = html.ScriptElement()
      ..id = 'blinkit-razorpay-bridge'
      ..text = '''
        window.addEventListener('blinkit-razorpay-open', function(event) {
          var options = JSON.parse(event.detail);
          options.handler = function(response) {
            window.dispatchEvent(new CustomEvent('blinkit-razorpay-success', {
              detail: JSON.stringify(response || {})
            }));
          };
          options.modal = {
            ondismiss: function() {
              window.dispatchEvent(new CustomEvent('blinkit-razorpay-cancel'));
            }
          };
          var checkout = new Razorpay(options);
          checkout.open();
        });
      ''';
    html.document.head?.append(bridgeScript);
  }
}

// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

import 'package:cloud_functions/cloud_functions.dart';

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
    final razorpayOrder = await _createRazorpayOrder(amountInPaise);
    await _ensureCheckoutScript();

    final completer = Completer<PaymentResult>();
    late final StreamSubscription<html.Event> successSubscription;
    late final StreamSubscription<html.Event> cancelSubscription;
    late final StreamSubscription<html.Event> failureSubscription;

    void cleanup() {
      successSubscription.cancel();
      cancelSubscription.cancel();
      failureSubscription.cancel();
    }

    successSubscription =
        html.window.on['snapit-razorpay-success'].listen((event) {
      if (completer.isCompleted) {
        return;
      }
      final detail = (event as html.CustomEvent).detail?.toString() ?? '{}';
      final data = jsonDecode(detail) as Map<String, dynamic>;
      cleanup();
      completer.complete(
        PaymentResult(
          paymentId: data['razorpay_payment_id'] as String? ?? '',
          orderId: data['razorpay_order_id'] as String?,
          signature: data['razorpay_signature'] as String?,
        ),
      );
    });

    cancelSubscription = html.window.on['snapit-razorpay-cancel'].listen((_) {
      if (completer.isCompleted) {
        return;
      }
      cleanup();
      completer.completeError('Payment cancelled');
    });

    failureSubscription =
        html.window.on['snapit-razorpay-failure'].listen((event) {
      if (completer.isCompleted) {
        return;
      }
      final detail = (event as html.CustomEvent).detail?.toString() ?? '{}';
      final data = jsonDecode(detail) as Map<String, dynamic>;
      final error = data['error'] as Map?;
      final description = error?['description'] as String?;
      final reason = error?['reason'] as String?;
      cleanup();
      completer.completeError(
        description?.trim().isNotEmpty == true
            ? description!
            : reason?.trim().isNotEmpty == true
                ? reason!
                : 'Payment failed',
      );
    });

    final options = {
      'key': razorpayOrder.keyId,
      'amount': razorpayOrder.amountInPaise,
      'currency': razorpayOrder.currency,
      'name': 'SnapIt Grocery',
      'description': description,
      'image': 'icons/Icon-192.png',
      'prefill': {
        'email': customerEmail,
        'contact': customerContact,
      },
      'theme': {
        'color': '#0C831F',
      },
    };

    if (razorpayOrder.orderId.isNotEmpty) {
      options['order_id'] = razorpayOrder.orderId;
    }

    html.window.dispatchEvent(
      html.CustomEvent('snapit-razorpay-open', detail: jsonEncode(options)),
    );

    return completer.future;
  }

  Future<_RazorpayOrder> _createRazorpayOrder(int amountInPaise) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-south1')
          .httpsCallable('createRazorpayOrder');
      final response = await callable.call<Map<String, dynamic>>({
        'amountInPaise': amountInPaise,
      });
      final data = Map<String, dynamic>.from(response.data);
      final orderId = data['orderId'] as String? ?? '';
      if (orderId.isEmpty) {
        throw 'Razorpay order id missing.';
      }
      return _RazorpayOrder(
        keyId: data['keyId'] as String? ?? '',
        orderId: orderId,
        amountInPaise: (data['amount'] as num?)?.toInt() ?? amountInPaise,
        currency: data['currency'] as String? ?? 'INR',
      );
    } on FirebaseFunctionsException {
      return _orderlessCheckout(amountInPaise);
    } catch (error) {
      if (error.toString().contains('Razorpay order id')) {
        throw error.toString();
      }
      return _orderlessCheckout(amountInPaise);
    }
  }

  _RazorpayOrder _orderlessCheckout(int amountInPaise) {
    return _RazorpayOrder(
      keyId: _razorpayKeyId,
      orderId: '',
      amountInPaise: amountInPaise,
      currency: 'INR',
    );
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
    if (html.document.getElementById('snapit-razorpay-bridge') != null) {
      return;
    }

    final bridgeScript = html.ScriptElement()
      ..id = 'snapit-razorpay-bridge'
      ..text = '''
        window.addEventListener('snapit-razorpay-open', function(event) {
          var options = JSON.parse(event.detail);
          options.handler = function(response) {
            window.dispatchEvent(new CustomEvent('snapit-razorpay-success', {
              detail: JSON.stringify(response || {})
            }));
          };
          options.modal = {
            ondismiss: function() {
              window.dispatchEvent(new CustomEvent('snapit-razorpay-cancel'));
            }
          };
          var checkout = new Razorpay(options);
          checkout.on('payment.failed', function(response) {
            window.dispatchEvent(new CustomEvent('snapit-razorpay-failure', {
              detail: JSON.stringify(response || {})
            }));
          });
          checkout.open();
        });
      ''';
    html.document.head?.append(bridgeScript);
  }
}

class _RazorpayOrder {
  const _RazorpayOrder({
    required this.keyId,
    required this.orderId,
    required this.amountInPaise,
    required this.currency,
  });

  final String keyId;
  final String orderId;
  final int amountInPaise;
  final String currency;
}

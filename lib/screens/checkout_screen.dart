import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../services/order_service.dart';
import '../services/payment_service.dart';
import '../theme/app_theme.dart';
import '../utils/top_message.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final PaymentService _paymentService = createPaymentService();
  final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  bool _isSubmitting = false;

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _confirmOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();
    final orderService = context.read<OrderService>();
    final user = auth.currentUser;

    if (user == null) {
      _showMessage('Please sign in before checkout.', TopMessageType.error);
      return;
    }

    if (cart.items.isEmpty) {
      _showMessage('Your cart is empty.', TopMessageType.error);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final payment = await _paymentService.payWithRazorpay(
        amountInPaise: (cart.totalPrice * 100).round(),
        customerEmail: user.email ?? '',
        customerContact: _phoneController.text.trim(),
        description: 'Blinkit grocery order',
      );

      await orderService.placeOrder(
        userId: user.uid,
        items: cart.items,
        total: cart.totalPrice,
        shippingAddress: _addressController.text.trim(),
        status: 'paid',
        paymentProvider: 'razorpay',
        paymentId: payment.paymentId,
        paymentOrderId: payment.orderId,
      );
      cart.clearCart();

      if (!mounted) {
        return;
      }

      Navigator.of(context).popUntil((route) => route.isFirst);
      _showMessage('Payment successful. Order placed.', TopMessageType.success);
    } catch (error) {
      _showMessage(
        error.toString().contains('cancelled')
            ? 'Payment cancelled.'
            : 'Payment failed. Please try again.',
        TopMessageType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showMessage(String message, TopMessageType type) {
    showTopMessage(context, message: message, type: type);
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.flash_on, color: AppColors.yellow),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delivery in 8 minutes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Pay securely with Razorpay before confirmation',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _CheckoutSection(
            title: 'Delivery details',
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _addressController,
                    minLines: 3,
                    maxLines: 5,
                    textInputAction: TextInputAction.newline,
                    decoration: const InputDecoration(
                      labelText: 'Complete address',
                      hintText: 'House no, street, area, city',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final address = value?.trim() ?? '';
                      if (address.isEmpty) {
                        return 'Shipping address is required.';
                      }
                      if (address.length < 10) {
                        return 'Enter a complete shipping address.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Mobile number',
                      hintText: '10 digit mobile number',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final phone = (value ?? '').replaceAll(RegExp(r'\D'), '');
                      if (phone.length < 10) {
                        return 'Enter a valid mobile number.';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          _CheckoutSection(
            title: 'Payment',
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    color: AppColors.offer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: AppColors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Razorpay',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'UPI, cards, wallets and netbanking',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.verified, color: AppColors.green),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _CheckoutSection(
            title: 'Order summary',
            child: Column(
              children: [
                ...cart.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text('x${item.quantity}'),
                        const SizedBox(width: 12),
                        Text(
                          _currencyFormat.format(
                            item.product.price * item.quantity,
                          ),
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 24),
                _SummaryRow(
                  label: 'Item total',
                  value: _currencyFormat.format(cart.totalPrice),
                ),
                const SizedBox(height: 8),
                const _SummaryRow(label: 'Delivery fee', value: 'FREE'),
                const Divider(height: 24),
                _SummaryRow(
                  label: 'To pay',
                  value: _currencyFormat.format(cart.totalPrice),
                  isTotal: true,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: _isSubmitting || cart.items.isEmpty ? null : _confirmOrder,
          icon: _isSubmitting
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.lock_outline),
          label: Text(
            _isSubmitting
                ? 'OPENING RAZORPAY...'
                : 'PAY ${_currencyFormat.format(cart.totalPrice)}',
          ),
        ),
      ),
    );
  }
}

class _CheckoutSection extends StatelessWidget {
  const _CheckoutSection({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  final String label;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final style = isTotal
        ? Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            )
        : Theme.of(context).textTheme.bodyMedium;

    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(value, style: style),
      ],
    );
  }
}

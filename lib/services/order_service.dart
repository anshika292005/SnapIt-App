import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_order.dart';
import '../models/cart_item.dart';

class OrderService {
  OrderService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _ordersCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('orders');
  }

  Future<String> placeOrder({
    required String userId,
    required List<CartItem> items,
    required double total,
    required String shippingAddress,
    String status = 'pending',
    String? paymentProvider,
    String? paymentId,
    String? paymentOrderId,
  }) async {
    final orderRef = _ordersCollection(userId).doc();
    final order = AppOrder(
      id: orderRef.id,
      userId: userId,
      items: items,
      total: total,
      status: status,
      timestamp: DateTime.now(),
      shippingAddress: shippingAddress,
      paymentProvider: paymentProvider,
      paymentId: paymentId,
      paymentOrderId: paymentOrderId,
    );

    await orderRef.set(order.toMap());
    return orderRef.id;
  }

  Stream<List<AppOrder>> streamOrders(String userId) {
    return _ordersCollection(userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return AppOrder.fromMap({
              ...data,
              'id': data['id'] ?? doc.id,
            });
          }).toList(),
        );
  }
}

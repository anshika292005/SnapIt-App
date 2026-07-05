import 'package:cloud_firestore/cloud_firestore.dart';

import 'cart_item.dart';

class AppOrder {
  const AppOrder({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.status,
    required this.timestamp,
    required this.shippingAddress,
    this.paymentProvider,
    this.paymentId,
    this.paymentOrderId,
  });

  final String id;
  final String userId;
  final List<CartItem> items;
  final double total;
  final String status;
  final DateTime timestamp;
  final String shippingAddress;
  final String? paymentProvider;
  final String? paymentId;
  final String? paymentOrderId;

  factory AppOrder.fromMap(Map<String, dynamic> map) {
    final rawItems = map['items'] as List? ?? [];

    return AppOrder(
      id: map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      items: rawItems
          .map(
            (item) =>
                CartItem.fromMap(Map<String, dynamic>.from(item as Map? ?? {})),
          )
          .toList(),
      total: (map['total'] as num?)?.toDouble() ?? 0,
      status: map['status'] as String? ?? '',
      timestamp: _dateTimeFromFirestoreValue(map['timestamp']),
      shippingAddress: map['shippingAddress'] as String? ?? '',
      paymentProvider: map['paymentProvider'] as String?,
      paymentId: map['paymentId'] as String?,
      paymentOrderId: map['paymentOrderId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'total': total,
      'status': status,
      'timestamp': Timestamp.fromDate(timestamp),
      'shippingAddress': shippingAddress,
      if (paymentProvider != null) 'paymentProvider': paymentProvider,
      if (paymentId != null) 'paymentId': paymentId,
      if (paymentOrderId != null) 'paymentOrderId': paymentOrderId,
    };
  }

  static DateTime _dateTimeFromFirestoreValue(Object? value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}

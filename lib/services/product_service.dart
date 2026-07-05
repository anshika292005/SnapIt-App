import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product.dart';

class ProductService {
  ProductService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<Product>> streamProducts() {
    return _firestore.collection('products').orderBy('name').snapshots().map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return Product.fromMap({
              ...data,
              'id': data['id'] ?? doc.id,
            });
          }).toList(),
        );
  }
}

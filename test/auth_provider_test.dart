import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ecommerce_app/providers/auth_provider.dart';

void main() {
  test('signs up, logs out, and logs back in', () async {
    final firebaseAuth = MockFirebaseAuth();
    final authProvider = AuthProvider(firebaseAuth: firebaseAuth);

    await authProvider.signUp('shopper@example.com', 'password123');

    expect(authProvider.currentUser, isNotNull);
    expect(authProvider.currentUser?.email, 'shopper@example.com');

    await authProvider.signOut();

    expect(authProvider.currentUser, isNull);

    await authProvider.signIn('shopper@example.com', 'password123');

    expect(authProvider.currentUser, isNotNull);
    expect(authProvider.currentUser?.email, 'shopper@example.com');
  });
}

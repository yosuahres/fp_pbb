import 'package:cloud_functions/cloud_functions.dart'; 
import 'package:flutter/foundation.dart' show kDebugMode; 
import 'package:flutter/material.dart'; 

class PaymentService {
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(region: 'asia-southeast2');

  Future<Map<String, dynamic>?> initiateShopeePayCheckout({
    required String orderId,
    required double amount,
    required String clientReturnUrl,
  }) async {
    try {
      if (kDebugMode) {
        _functions.useFunctionsEmulator('localhost', 5001);
      }

      final HttpsCallable callable = _functions.httpsCallable(
        'initiateShopeePayCheckout',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 30), 
        ),
      );

      final result = await callable.call<Map<String, dynamic>>({
        'orderId': orderId,
        'amount': amount.toInt(), 
        'clientReturnUrl': clientReturnUrl,
      });


      if (result.data['success'] == true) {
        return {
          'redirectUrlHttp': result.data['redirectUrlHttp'],
          'redirectUrlApp': result.data['redirectUrlApp'],
        };
      } else {
        return null;
      }
    } on FirebaseFunctionsException catch (e) {
      throw Exception("Firebase Error: ${e.message ?? 'Failed to connect to payment service.'}");
    } catch (e) {
      debugPrint('PaymentService: Generic error initiating ShopeePay: $e');
      throw Exception("Payment Error: ${e.toString()}");
    }
  }
}
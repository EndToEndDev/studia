import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/paypal_config.dart';

class PayPalService {
  final String _clientId = kPayPalClientId;
  final String _clientSecret = kPayPalSecret;
  final bool _useSandbox = kPayPalUseSandbox;

  String get _apiBase => _useSandbox
      ? 'https://api-m.sandbox.paypal.com'
      : 'https://api-m.paypal.com';

  Future<String> _getAccessToken() async {
    final uri = Uri.parse('$_apiBase/v1/oauth2/token');
    final encoded = base64Encode(utf8.encode('$_clientId:$_clientSecret'));

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Basic $encoded',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: 'grant_type=client_credentials',
    );

    if (response.statusCode != 200) {
      throw Exception('PayPal auth failed: ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return json['access_token'] as String;
  }

  Future<PayPalOrder> createOrder({
    required double amount,
    required String currency,
    required String description,
  }) async {
    final accessToken = await _getAccessToken();
    final uri = Uri.parse('$_apiBase/v2/checkout/orders');

    final body = jsonEncode({
      'intent': 'CAPTURE',
      'purchase_units': [
        {
          'amount': {
            'currency_code': currency,
            'value': amount.toStringAsFixed(2),
          },
          'description': description,
        }
      ],
      'application_context': {
        'brand_name': kPayPalBrandName,
        'landing_page': 'NO_PREFERENCE',
        'user_action': 'PAY_NOW',
        'return_url': kPayPalReturnUrl,
        'cancel_url': kPayPalCancelUrl,
      },
    });

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode != 201) {
      throw Exception('PayPal order creation failed: ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final orderId = json['id'] as String;
    final approveLink = (json['links'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .firstWhere((link) => link['rel'] == 'approve')['href'] as String;

    return PayPalOrder(orderId: orderId, approvalUrl: approveLink);
  }

  Future<Map<String, dynamic>> captureOrder(String orderId) async {
    final accessToken = await _getAccessToken();
    final uri = Uri.parse('$_apiBase/v2/checkout/orders/$orderId/capture');

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('PayPal capture failed: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}

class PayPalOrder {
  final String orderId;
  final String approvalUrl;

  PayPalOrder({required this.orderId, required this.approvalUrl});
}

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dotenv/dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

const _stripeApiBase = 'https://api.stripe.com/v1';

void main(List<String> args) async {
  final environment = DotEnv(includePlatformEnvironment: true)
    ..load();

  final stripeSecretKey = environment['STRIPE_SECRET_KEY'];
  if (stripeSecretKey == null || stripeSecretKey.isEmpty) {
    stderr.writeln('Missing STRIPE_SECRET_KEY in environment. Use .env or env vars.');
    exit(1);
  }

  final app = Router();

  app.get('/config', (Request request) {
    return _json({
      'publishableKey': environment['STRIPE_PUBLISHABLE_KEY'] ?? '',
      'mode': environment['STRIPE_MODE'] ?? 'test',
    });
  });

  app.post('/create-payment-intent', (Request request) async {
    final payload = await _readJson(request);
    final amount = _toAmount(payload['amount']);
    final currency = payload['currency']?.toString().toLowerCase() ?? 'usd';
    final metadata = payload['metadata'] as Map<String, dynamic>?;

    final body = {
      'amount': amount.toString(),
      'currency': currency,
      'automatic_payment_methods[enabled]': 'true',
    };

    if (metadata != null) {
      metadata.forEach((key, value) {
        body['metadata[$key]'] = value.toString();
      });
    }

    final response = await _stripePost('/payment_intents', body, stripeSecretKey);
    return _responseFromStripe(response);
  });

  app.post('/create-checkout-session', (Request request) async {
    final payload = await _readJson(request);
    final amount = _toAmount(payload['amount']);
    final currency = payload['currency']?.toString().toLowerCase() ?? 'usd';
    final successUrl = payload['success_url']?.toString() ?? '';
    final cancelUrl = payload['cancel_url']?.toString() ?? '';
    final description = payload['description']?.toString() ?? 'Tutoring session';

    if (successUrl.isEmpty || cancelUrl.isEmpty) {
      return _json({'error': 'success_url and cancel_url are required'}, 400);
    }

    final body = {
      'payment_method_types[]': 'card',
      'mode': 'payment',
      'success_url': successUrl,
      'cancel_url': cancelUrl,
      'line_items[0][price_data][currency]': currency,
      'line_items[0][price_data][product_data][name]': description,
      'line_items[0][price_data][unit_amount]': amount.toString(),
      'line_items[0][quantity]': '1',
    };

    final response = await _stripePost('/checkout/sessions', body, stripeSecretKey);
    return _responseFromStripe(response);
  });

  // Background Check Management Endpoints
  app.get('/tutor-profiles', (Request request) {
    // Mock response - in production this would query the database
    return _json({
      'tutors': [
        {
          'userId': 101,
          'bio': 'Experienced math tutor helping students of all levels.',
          'hourlyRate': 30.0,
          'yearsExperience': 5,
          'verified': true,
          'avgRating': 4.8,
          'totalReviews': 24,
          'backgroundCheckStatus': 'Completed',
          'backgroundCheckDate': DateTime.now().toIso8601String(),
          'verificationDocument': null,
        }
      ]
    });
  });

  app.get('/tutor-profiles/<tutorId|[0-9]+>', (Request request, String tutorId) {
    // Mock response - in production this would query the database
    final id = int.tryParse(tutorId) ?? 0;
    return _json({
      'userId': id,
      'bio': 'Experienced math tutor helping students of all levels.',
      'hourlyRate': 30.0,
      'yearsExperience': 5,
      'verified': true,
      'avgRating': 4.8,
      'totalReviews': 24,
      'backgroundCheckStatus': 'Completed',
      'backgroundCheckDate': DateTime.now().toIso8601String(),
      'verificationDocument': null,
    });
  });

  app.post('/tutor-profiles/<tutorId|[0-9]+>/background-check',
      (Request request, String tutorId) async {
    final payload = await _readJson(request);
    final id = int.tryParse(tutorId) ?? 0;

    return _json({
      'success': true,
      'message': 'Background check status updated',
      'tutorId': id,
      'backgroundCheckStatus': payload['backgroundCheckStatus'] ?? 'Pending',
      'backgroundCheckDate': DateTime.now().toIso8601String(),
      'verificationDocument': payload['verificationDocument'],
    });
  });

  app.get('/tutor-profiles/background-check/status/<status>',
      (Request request, String status) {
    // Mock response - in production this would query by status
    return _json({
      'status': status,
      'tutors': [
        {
          'userId': 101,
          'bio': 'Experienced math tutor helping students of all levels.',
          'hourlyRate': 30.0,
          'yearsExperience': 5,
          'verified': true,
          'avgRating': 4.8,
          'totalReviews': 24,
          'backgroundCheckStatus': status,
          'backgroundCheckDate': DateTime.now().toIso8601String(),
          'verificationDocument': null,
        }
      ]
    });
  });

  app.post('/webhook', (Request request) async {
    final signatureHeader = request.headers['stripe-signature'];
    final payload = await request.read().expand((bytes) => bytes).toList();
    final payloadString = utf8.decode(payload);

    if (signatureHeader == null || signatureHeader.isEmpty) {
      return _json({'error': 'Missing Stripe-Signature header'}, 400);
    }

    final webhookSecret = environment['STRIPE_WEBHOOK_SECRET'];
    if (webhookSecret == null || webhookSecret.isEmpty) {
      return _json({'error': 'Missing STRIPE_WEBHOOK_SECRET environment variable'}, 500);
    }

    if (!verifyStripeSignature(payloadString, signatureHeader, webhookSecret)) {
      return _json({'error': 'Invalid webhook signature'}, 400);
    }

    final event = jsonDecode(payloadString) as Map<String, dynamic>;
    final eventType = event['type']?.toString();

    // Add custom event handling here.
    if (eventType == 'checkout.session.completed') {
      // The checkout session was successfully completed.
    }

    return Response.ok(jsonEncode({'received': true}), headers: {'content-type': 'application/json'});
  });

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(_corsMiddleware)
      .addHandler(app);

  final port = int.tryParse(Platform.environment['PORT'] ?? '8080') ?? 8080;
  final server = await serve(handler, InternetAddress.anyIPv4, port);
  stdout.writeln('Stripe backend listening on http://${server.address.host}:${server.port}');
}

Future<Map<String, dynamic>> _readJson(Request request) async {
  final body = await request.readAsString();
  if (body.isEmpty) return <String, dynamic>{};
  return jsonDecode(body) as Map<String, dynamic>;
}

Response _json(Object data, [int statusCode = 200]) => Response(
      statusCode,
      body: jsonEncode(data),
      headers: {'content-type': 'application/json'},
    );

Future<http.Response> _stripePost(String path, Map<String, String> body, String secretKey) {
  return http.post(
    Uri.parse('$_stripeApiBase$path'),
    headers: {
      'Authorization': 'Basic ${base64Encode(utf8.encode('$secretKey:'))}',
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: body,
  );
}

Response _responseFromStripe(http.Response response) {
  final jsonBody = jsonDecode(response.body);
  return Response(
    response.statusCode,
    body: jsonEncode(jsonBody),
    headers: {'content-type': 'application/json'},
  );
}

Middleware get _corsMiddleware {
  return (Handler innerHandler) {
    return (Request request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: _corsHeaders);
      }

      final response = await innerHandler(request);
      return response.change(headers: {
        ...response.headers,
        ..._corsHeaders,
      });
    };
  };
}

const Map<String, String> _corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept, Authorization, Stripe-Signature',
};

int _toAmount(Object? amountValue) {
  if (amountValue is int) return amountValue;
  if (amountValue is double) return (amountValue * 100).round();
  if (amountValue is String) {
    final parsed = double.tryParse(amountValue);
    if (parsed == null) throw ArgumentError('Invalid amount value');
    return (parsed * 100).round();
  }
  throw ArgumentError('Unsupported amount type');
}

bool verifyStripeSignature(String payload, String header, String secret) {
  final expected = _parseStripeSignature(header);
  if (expected == null) return false;

  final timestamp = expected.timestamp;
  final signatures = expected.signatures;
  final signedPayload = '$timestamp.$payload';
  final computed = Hmac(sha256, utf8.encode(secret)).convert(utf8.encode(signedPayload)).toString();

  final isSignatureValid = signatures.any((sig) => _constantTimeCompare(sig, computed));
  if (!isSignatureValid) return false;

  final now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
  const toleranceSeconds = 300;
  return (now - timestamp).abs() <= toleranceSeconds;
}

bool _constantTimeCompare(String a, String b) {
  if (a.length != b.length) return false;
  var result = 0;
  for (var i = 0; i < a.length; i++) {
    result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
  }
  return result == 0;
}

StripeSignature? _parseStripeSignature(String header) {
  final parts = header.split(',');
  var timestamp = -1;
  final signatures = <String>[];

  for (final part in parts) {
    final kv = part.split('=');
    if (kv.length != 2) continue;
    final key = kv[0].trim();
    final value = kv[1].trim();
    if (key == 't') {
      timestamp = int.tryParse(value) ?? -1;
    } else if (key == 'v1') {
      signatures.add(value);
    }
  }

  if (timestamp < 0 || signatures.isEmpty) return null;
  return StripeSignature(timestamp: timestamp, signatures: signatures);
}

class StripeSignature {
  final int timestamp;
  final List<String> signatures;
  StripeSignature({required this.timestamp, required this.signatures});
}

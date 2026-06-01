import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../config/paypal_config.dart';
import '../database/database_helper.dart';
import '../models/session.dart';
import '../services/paypal_service.dart';

class PayPalCheckoutScreen extends StatefulWidget {
  final double amount;
  final String currency;
  final String description;
  final int studentId;
  final int tutorId;
  final int subjectId;

  const PayPalCheckoutScreen({
    super.key,
    required this.amount,
    required this.currency,
    required this.description,
    required this.studentId,
    required this.tutorId,
    required this.subjectId,
  });

  @override
  State<PayPalCheckoutScreen> createState() => _PayPalCheckoutScreenState();
}

class _PayPalCheckoutScreenState extends State<PayPalCheckoutScreen> {
  final PayPalService _payPalService = PayPalService();
  late final WebViewController _webViewController;

  String? _errorMessage;
  bool _isLoading = true;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) => _navigationDelegate(request),
          onWebResourceError: (error) {
            if (mounted) {
              setState(() {
                _errorMessage = error.description;
              });
            }
          },
        ),
      );
    _startCheckout();
  }

  Future<void> _startCheckout() async {
    try {
      final order = await _payPalService.createOrder(
        amount: widget.amount,
        currency: widget.currency,
        description: widget.description,
      );

      setState(() {
        _isLoading = false;
      });

      _webViewController.loadRequest(Uri.parse(order.approvalUrl));
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleApproval(String orderId) async {
    if (_isCapturing) return;
    setState(() {
      _isCapturing = true;
    });

    try {
      final captureResponse = await _payPalService.captureOrder(orderId);
      final status = captureResponse['status'] as String?;

      if (status != 'COMPLETED' && status != 'APPROVED') {
        throw Exception('PayPal payment not completed. Status: $status');
      }

      final session = Session(
        studentId: widget.studentId,
        tutorId: widget.tutorId,
        subjectId: widget.subjectId,
        startDateTime: DateTime.now().toIso8601String(),
        endDateTime: DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
        status: 'booked',
        notes: widget.description,
        meetingProvider: 'PayPal',
        meetingLink: null,
        meetingId: orderId,
      );

      await DatabaseHelper.instance.createSession(session);

      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Payment Completed'),
            content: Text('Your PayPal payment has been captured. Order ID: $orderId'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isCapturing = false;
      });
    }
  }

  NavigationDecision _navigationDelegate(NavigationRequest request) {
    final uri = Uri.parse(request.url);

    if (uri.origin == Uri.parse(kPayPalReturnUrl).origin &&
        uri.path == Uri.parse(kPayPalReturnUrl).path) {
      final token = uri.queryParameters['token'];
      if (token != null) {
        _handleApproval(token);
      }
      return NavigationDecision.prevent;
    }

    if (uri.origin == Uri.parse(kPayPalCancelUrl).origin &&
        uri.path == Uri.parse(kPayPalCancelUrl).path) {
      Navigator.of(context).pop(false);
      return NavigationDecision.prevent;
    }

    return NavigationDecision.navigate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PayPal Checkout'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Checkout failed:\n\n\n$_errorMessage',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                )
              : Stack(
                  children: [
                    WebViewWidget(
                      controller: _webViewController,
                    ),
                    if (_isCapturing)
                      const Positioned.fill(
                        child: ColoredBox(
                          color: Colors.black54,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }
}

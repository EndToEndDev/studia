import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../config/stripe_config.dart';
import '../services/stripe_service.dart';

class StripeCheckoutScreen extends StatefulWidget {
  final double amount;
  final String currency;
  final String description;

  const StripeCheckoutScreen({
    super.key,
    required this.amount,
    required this.currency,
    required this.description,
  });

  @override
  State<StripeCheckoutScreen> createState() => _StripeCheckoutScreenState();
}

class _StripeCheckoutScreenState extends State<StripeCheckoutScreen> {
  final StripeService _stripeService = StripeService();
  late final WebViewController _controller;
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) => _navigationDelegate(request),
          onWebResourceError: (error) {
            if (mounted) {
              setState(() {
                _errorMessage = error.description;
                _isLoading = false;
              });
            }
          },
        ),
      );
    _createSession();
  }

  Future<void> _createSession() async {
    try {
      final checkoutUrl = await _stripeService.createCheckoutSession(
        amount: widget.amount,
        currency: widget.currency,
        description: widget.description,
      );

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      _controller.loadRequest(Uri.parse(checkoutUrl));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  NavigationDecision _navigationDelegate(NavigationRequest request) {
    final uri = Uri.parse(request.url);

    if (uri.origin == Uri.parse(kStripeSuccessUrl).origin &&
        uri.path == Uri.parse(kStripeSuccessUrl).path) {
      if (!mounted) return NavigationDecision.prevent;
      Navigator.of(context).pop(true);
      return NavigationDecision.prevent;
    }

    if (uri.origin == Uri.parse(kStripeCancelUrl).origin &&
        uri.path == Uri.parse(kStripeCancelUrl).path) {
      if (!mounted) return NavigationDecision.prevent;
      Navigator.of(context).pop(false);
      return NavigationDecision.prevent;
    }

    return NavigationDecision.navigate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stripe Checkout'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Checkout error:\n\n$_errorMessage',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : WebViewWidget(controller: _controller),
    );
  }
}

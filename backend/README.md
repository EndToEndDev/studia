# Stripe Payment Backend

This backend is built to support a Stripe front-end integration for tutor session payments.

## Features

- `POST /create-payment-intent` — creates a Stripe PaymentIntent with automatic payment methods enabled.
- `POST /create-checkout-session` — creates a Stripe Checkout Session for one-time payments.
- `POST /webhook` — receives and verifies Stripe webhook events.
- `GET /config` — returns Stripe public key and mode for frontend configuration.

## Setup

1. Copy `.env.example` to `.env`.
2. Set your Stripe secret key and webhook secret.
3. Run:

```bash
cd backend
dart pub get
dart run bin/server.dart
```

## Example request

```bash
curl -X POST http://localhost:8080/create-payment-intent \
  -H "Content-Type: application/json" \
  -d '{"amount": 30.00, "currency": "usd", "metadata": {"tutor_id": "101"}}'
```

## Frontend integration

Use `client_secret` from `/create-payment-intent` with Stripe.js or the Checkout Session URL from `/create-checkout-session`.

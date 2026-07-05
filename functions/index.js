const admin = require('firebase-admin');
const { HttpsError, onCall } = require('firebase-functions/v2/https');
const { defineSecret } = require('firebase-functions/params');
const Stripe = require('stripe');

admin.initializeApp();

const stripeSecretKey = defineSecret('STRIPE_SECRET_KEY');

exports.createPaymentIntent = onCall(
  {
    region: 'asia-south1',
    secrets: [stripeSecretKey],
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Sign in before checkout.');
    }

    const amount = Number(request.data?.amount);
    if (!Number.isFinite(amount) || amount <= 0) {
      throw new HttpsError('invalid-argument', 'A valid amount is required.');
    }

    const amountInPaise = Math.round(amount * 100);
    if (amountInPaise < 5000) {
      throw new HttpsError(
        'invalid-argument',
        'Order total must be at least ₹50.',
      );
    }

    const stripe = new Stripe(stripeSecretKey.value());
    const paymentIntent = await stripe.paymentIntents.create({
      amount: amountInPaise,
      currency: 'inr',
      automatic_payment_methods: { enabled: true },
      metadata: {
        uid: request.auth.uid,
      },
    });

    return {
      clientSecret: paymentIntent.client_secret,
      paymentIntentId: paymentIntent.id,
      amount: paymentIntent.amount,
      currency: paymentIntent.currency,
    };
  },
);

const admin = require('firebase-admin');
const { HttpsError, onCall } = require('firebase-functions/v2/https');
const { defineSecret } = require('firebase-functions/params');
const Stripe = require('stripe');

admin.initializeApp();

const stripeSecretKey = defineSecret('STRIPE_SECRET_KEY');
const razorpayKeySecret = defineSecret('RAZORPAY_KEY_SECRET');
const razorpayKeyId = process.env.RAZORPAY_KEY_ID || 'rzp_test_T8hKxJEntWLdWq';

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

exports.createRazorpayOrder = onCall(
  {
    region: 'asia-south1',
    secrets: [razorpayKeySecret],
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Sign in before checkout.');
    }

    const amountInPaise = Number(request.data?.amountInPaise);
    if (!Number.isInteger(amountInPaise) || amountInPaise <= 0) {
      throw new HttpsError(
        'invalid-argument',
        'A valid amount in paise is required.',
      );
    }

    const authToken = Buffer.from(
      `${razorpayKeyId}:${razorpayKeySecret.value()}`,
    ).toString('base64');

    const response = await fetch('https://api.razorpay.com/v1/orders', {
      method: 'POST',
      headers: {
        Authorization: `Basic ${authToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        amount: amountInPaise,
        currency: 'INR',
        receipt: `snapit_${request.auth.uid}_${Date.now()}`.slice(0, 40),
        notes: {
          uid: request.auth.uid,
        },
      }),
    });

    const order = await response.json();
    if (!response.ok) {
      throw new HttpsError(
        'internal',
        order?.error?.description || 'Unable to create Razorpay order.',
      );
    }

    return {
      keyId: razorpayKeyId,
      orderId: order.id,
      amount: order.amount,
      currency: order.currency,
    };
  },
);

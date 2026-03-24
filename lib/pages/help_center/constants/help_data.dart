import 'package:flutter/material.dart';
import '../models/help_article.dart';
import '../models/help_category.dart';

const List<HelpCategory> kHelpCategories = [
  HelpCategory(
      id: 'account', title: 'Account', icon: Icons.person_outline_rounded),
  HelpCategory(
      id: 'payments', title: 'Payments', icon: Icons.credit_card_outlined),
  HelpCategory(id: 'trips', title: 'Trips', icon: Icons.route_outlined),
  HelpCategory(id: 'safety', title: 'Safety', icon: Icons.shield_outlined),
  HelpCategory(
      id: 'app', title: 'App & Settings', icon: Icons.settings_outlined),
];

const List<HelpArticle> kHelpArticles = [
  // Account
  HelpArticle(
    id: 'a1',
    categoryId: 'account',
    title: 'Do I have to use my real email to sign up?',
    summary: 'Why a valid email matters for your account.',
    body:
        'You need to use a real email to register. This ensures you can receive ride receipts, reset your password, and access your student benefits if applicable. Using fake emails may block your account.',
  ),
  HelpArticle(
    id: 'a2',
    categoryId: 'account',
    title: 'Can someone else log in using my account?',
    summary: 'Account sharing rules.',
    body:
        'Sharing your account is not allowed. Each account is personal, tied to your payment method and trips. If another person uses your account, it may be suspended or blocked.',
  ),
  HelpArticle(
    id: 'a3',
    categoryId: 'account',
    title: 'Can I delete my account with an active trip?',
    summary: 'Rules for account deletion.',
    body:
        'Accounts with active or pending trips cannot be deleted. Wait until all trips are completed and payments settled before deleting your account.',
  ),

  // Payments
  HelpArticle(
    id: 'p1',
    categoryId: 'payments',
    title: 'Can I pay with cash or only cards?',
    summary: 'Moviroo payment rules.',
    body:
        'Moviroo only accepts card payments (Visa, Mastercard, AmEx) or digital wallets like Apple Pay and Google Pay. Cash is not supported.',
  ),
  HelpArticle(
    id: 'p2',
    categoryId: 'payments',
    title: 'Can I tip in cash?',
    summary: 'Tipping rules.',
    body:
        'All tips must be added through the app using a card or wallet. Cash tips are not tracked by Moviroo and are discouraged.',
  ),
  HelpArticle(
    id: 'p3',
    categoryId: 'payments',
    title: 'Why was my card declined?',
    summary: 'Understanding payment issues.',
    body:
        'Cards can be declined if they are expired, have insufficient funds, or are blocked by the bank. Make sure your card supports online payments.',
  ),

  // Trips
  HelpArticle(
    id: 't1',
    categoryId: 'trips',
    title: 'Can I smoke or eat in the car?',
    summary: 'Rules during the ride.',
    body:
        'Smoking or consuming alcohol in the car is not allowed. Eating and drinking lightly may be permitted, but check with your driver first and avoid strong odors or mess.',
  ),
  HelpArticle(
    id: 't2',
    categoryId: 'trips',
    title: 'Can I bring my pet?',
    summary: 'Pet policy.',
    body:
        'Small pets are allowed if they are in carriers. Large pets require prior approval from the driver and must follow safety guidelines.',
  ),
  HelpArticle(
    id: 't3',
    categoryId: 'trips',
    title: 'Can I change my destination mid-trip?',
    summary: 'Route modification rules.',
    body:
        'You can request a destination change in the app. The driver may accept it depending on traffic and route conditions. Fare adjustments may apply.',
  ),
  HelpArticle(
    id: 't4',
    categoryId: 'trips',
    title: 'What happens if my driver cancels?',
    summary: 'Cancellation rules.',
    body:
        'If your driver cancels, Moviroo automatically searches for another nearby driver. You will not be charged a cancellation fee.',
  ),

  // Safety
  HelpArticle(
    id: 's1',
    categoryId: 'safety',
    title: 'How can I share my ride with someone?',
    summary: 'Real-time tracking.',
    body:
        'During a trip, tap the shield icon → "Share trip status" and choose a contact. They can follow your location until the ride ends.',
  ),
  HelpArticle(
    id: 's2',
    categoryId: 'safety',
    title: 'What if I feel unsafe during a ride?',
    summary: 'Emergency rules.',
    body:
        'Press the red emergency button in the app to contact local authorities. Moviroo’s safety team is notified immediately.',
  ),
  HelpArticle(
    id: 's3',
    categoryId: 'safety',
    title: 'What if the driver drives too fast?',
    summary: 'Reporting unsafe behavior.',
    body:
        'If you notice reckless driving, use the app to report the trip immediately. Moviroo reviews safety reports and may suspend drivers violating rules.',
  ),

  // App & Settings
  HelpArticle(
    id: 'ap1',
    categoryId: 'app',
    title: 'Can I use the app at night without straining my eyes?',
    summary: 'Appearance settings.',
    body:
        'You can enable dark mode in Settings → Appearance. This only changes the theme; all trip and payment functions remain normal.',
  ),
  HelpArticle(
    id: 'ap2',
    categoryId: 'app',
    title: 'The app stopped working during my ride — what should I do?',
    summary: 'Technical issues.',
    body:
        'If the app freezes or crashes, restart it. Your trip continues automatically. Make sure your payment method is valid and follow all ride rules.',
  ),
];
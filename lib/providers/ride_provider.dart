import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/models/offer_model.dart';
import '../core/models/ride_model.dart';
import '../core/notifications/notification_service.dart';
import '../services/dispatch_service.dart';

/// Manages pending offers and assigned/completed rides for the driver.
class RideProvider extends ChangeNotifier {
  final DispatchService _dispatch = DispatchService();

  List<OfferModel> _pendingOffers = [];
  List<RideModel> _allRides = [];
  bool _loading = false;
  bool _ridesLoading = false;
  String? _error;
  OfferModel? _activeOffer; // offer currently being reviewed by driver

  Timer? _pollTimer;

  // ── Getters ───────────────────────────────────────────────────────────────
  List<OfferModel> get pendingOffers => _pendingOffers;
  bool get loading => _loading;
  bool get ridesLoading => _ridesLoading;
  String? get error => _error;
  OfferModel? get activeOffer => _activeOffer;

  // Categorised ride lists derived from _allRides
  List<RideModel> get upcomingRides => _allRides
      .where(
        (r) =>
            r.status == 'ASSIGNED' ||
            r.status == 'EN_ROUTE_TO_PICKUP' ||
            r.status == 'ARRIVED' ||
            r.status == 'IN_TRIP',
      )
      .toList();

  List<RideModel> get completedRides =>
      _allRides.where((r) => r.status == 'COMPLETED').toList();

  List<RideModel> get cancelledRides =>
      _allRides.where((r) => r.status == 'CANCELLED').toList();

  // ── Polling ───────────────────────────────────────────────────────────────
  /// Start background polling for pending offers every [intervalSec] seconds.
  /// Call this when the driver goes online.
  void startPolling({int intervalSec = 8}) {
    if (_pollTimer != null) return; // already polling
    _pollTimer = Timer.periodic(Duration(seconds: intervalSec), (_) {
      _silentPollOffers();
    });
    // Immediate first fetch
    _silentPollOffers();
    // Register FCM token so backend can push ride offers
    _registerFcmToken();
  }

  /// Stop background polling. Call this when the driver goes offline.
  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _silentPollOffers() async {
    try {
      final offers = await _dispatch.getPendingOffers();
      // Only notify if something changed
      final changed =
          offers.length != _pendingOffers.length ||
          offers.any((o) => !_pendingOffers.any((p) => p.id == o.id));
      if (changed) {
        _pendingOffers = offers;
        notifyListeners();
      }
    } catch (_) {
      // Silent — polling should never crash the UI
    }
  }

  /// Register the device FCM token with the backend for push notifications
  Future<void> _registerFcmToken() async {
    try {
      final token = await NotificationService.instance.getToken();
      if (token != null && token.isNotEmpty) {
        await _dispatch.registerFcmToken(token);
        debugPrint('✅ FCM token registered with backend');
      }
    } catch (e) {
      debugPrint('⚠️ FCM token registration failed: $e');
    }

    // Listen for token refresh and update backend
    NotificationService.instance.onTokenRefresh((newToken) async {
      try {
        await _dispatch.registerFcmToken(newToken);
        debugPrint('✅ FCM token refreshed with backend');
      } catch (_) {}
    });

    // When a RIDE_OFFER push arrives, immediately fetch offers
    NotificationService.instance.onRideOfferReceived = () {
      _silentPollOffers();
    };

    // When a ride update push arrives (cancel, status change), refresh rides
    NotificationService.instance.onRideUpdate = (type, data) {
      _silentPollOffers();
      loadDriverRides();
    };
  }

  // ── Fetch pending offers ──────────────────────────────────────────────────
  Future<void> loadPendingOffers() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _pendingOffers = await _dispatch.getPendingOffers();
    } on Exception catch (e) {
      _error = 'Could not load offers. $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ── Accept ────────────────────────────────────────────────────────────────
  Future<bool> acceptOffer(String offerId) async {
    _loading = true;
    notifyListeners();
    try {
      await _dispatch.acceptOffer(offerId);
      _pendingOffers.removeWhere((o) => o.id == offerId);
      _activeOffer = null;
      _loading = false;
      notifyListeners();
      loadDriverRides(); // refresh so accepted ride shows in Upcoming
      return true;
    } on Exception catch (e) {
      _error = 'Could not accept offer. $e';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Reject ────────────────────────────────────────────────────────────────
  Future<bool> rejectOffer(String offerId, {String? reason}) async {
    _loading = true;
    notifyListeners();
    try {
      await _dispatch.rejectOffer(offerId, reason: reason);
      _pendingOffers.removeWhere((o) => o.id == offerId);
      _activeOffer = null;
      _loading = false;
      notifyListeners();
      return true;
    } on Exception catch (e) {
      _error = 'Could not reject offer. $e';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  void setActiveOffer(OfferModel? offer) {
    _activeOffer = offer;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ── Load all driver rides (upcoming/completed/cancelled) ──────────────
  Future<void> loadDriverRides() async {
    _ridesLoading = true;
    _error = null;
    notifyListeners();
    try {
      _allRides = await _dispatch.getDriverRides();
    } on Exception catch (e) {
      _error = 'Could not load rides. $e';
    } finally {
      _ridesLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}

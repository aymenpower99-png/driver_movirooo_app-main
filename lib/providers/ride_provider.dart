import 'package:flutter/foundation.dart';
import '../core/models/offer_model.dart';
import '../core/models/ride_model.dart';
import '../services/dispatch_service.dart';

/// Manages pending offers and assigned/completed rides for the driver.
class RideProvider extends ChangeNotifier {
  final DispatchService _dispatch = DispatchService();

  List<OfferModel> _pendingOffers  = [];
  List<RideModel>  _completedRides = [];
  bool             _loading        = false;
  String?          _error;
  OfferModel?      _activeOffer;   // offer currently being reviewed by driver

  // ── Getters ───────────────────────────────────────────────────────────────
  List<OfferModel> get pendingOffers  => _pendingOffers;
  List<RideModel>  get completedRides => _completedRides;
  bool             get loading        => _loading;
  String?          get error          => _error;
  OfferModel?      get activeOffer    => _activeOffer;

  // ── Fetch pending offers ──────────────────────────────────────────────────
  Future<void> loadPendingOffers() async {
    _loading = true;
    _error   = null;
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
      return true;
    } on Exception catch (e) {
      _error   = 'Could not accept offer. $e';
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
      _error   = 'Could not reject offer. $e';
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
}

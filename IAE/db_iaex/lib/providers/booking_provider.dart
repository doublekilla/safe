import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../core/services/api_client.dart';

/// Court booking state management
class BookingProvider extends ChangeNotifier {
  final ApiClient _api;
  List<Booking> _venues = [];
  Booking? _selectedBooking;
  bool _isLoading = false;

  BookingProvider({required ApiClient api}) : _api = api;

  List<Booking> get venues => _venues;
  Booking? get selectedBooking => _selectedBooking;
  bool get isLoading => _isLoading;

  Future<void> loadVenues({String? sport}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final params = <String, String>{};
      if (sport != null && sport != 'all') params['sport'] = sport;
      final res = await _api.get('/venues', queryParams: params.isNotEmpty ? params : null);
      if (res.isSuccess && res.data is List) {
        _venues = (res.data as List).map((e) => Booking.fromJson(e)).toList();
      }
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  void setSelectedBooking(Booking booking) {
    _selectedBooking = booking;
    notifyListeners();
  }

  Future<bool> confirmBooking(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api.post('/court-bookings', body: data);
      if (res.isSuccess) { _isLoading = false; notifyListeners(); return true; }
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
    return false;
  }
}

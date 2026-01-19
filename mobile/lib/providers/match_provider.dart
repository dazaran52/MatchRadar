import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class MatchProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  List<User> _nearbyUsers = [];
  List<User> get nearbyUsers => _nearbyUsers;

  bool _isMatch = false;
  bool get isMatch => _isMatch;

  Future<void> fetchUsers(double lat, double lng, int myId) async {
    _nearbyUsers = await _api.scanRadar(myId, lat, lng);
    notifyListeners();
  }

  Future<bool> swipeRight(int fromId, int toId) async {
    bool match = await _api.likeUser(fromId, toId);
    if (match) {
      _isMatch = true;
      notifyListeners();
      // Reset match overlay after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        _isMatch = false;
        notifyListeners();
      });
    }
    return match;
  }
}

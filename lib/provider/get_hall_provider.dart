import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:movie_booking_flutter_backend/constant/api_const.dart';

class GetHallProvider with ChangeNotifier {
  List<dynamic> _halls = [];
  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  // Getters
  List<dynamic> get halls => _halls;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;

  // Fetch Halls Method
  Future<void> fetchHalls() async {
    // Reset states
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      // Construct API URL
      final Uri hallUrl = Uri.parse(
        '${ApiConstant.protocol}${ApiConstant.baseUrl}${ApiConstant.getHall}',
      );

      // HTTP GET request
      final response = await http.get(hallUrl);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data.containsKey('halls') && data['halls'] is List) {
          _halls = data['halls'];
          _successMessage = 'Halls loaded successfully';
        } else {
          _error = 'No halls data found';
        }
      } else {
        _error = 'Error: ${response.statusCode} - ${response.reasonPhrase}';
      }
    } catch (e) {
      _error = 'Network Error: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify listeners of any final state
    }
  }

  // Clear messages
  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }

  // Reset provider state
  void resetState() {
    _halls = [];
    _isLoading = false;
    _error = null;
    _successMessage = null;
    notifyListeners();
  }
}

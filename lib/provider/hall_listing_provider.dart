import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:movie_booking_flutter_backend/constant/api_const.dart';
class HallListingProvider with ChangeNotifier {
  List<dynamic> _hallData = [];
  bool _isLoading = false;
  String _error = '';

  List<dynamic> get hallData => _hallData;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchHallData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${ApiConstant.protocol}${ApiConstant.baseUrl}${ApiConstant.getHall}'), // Replace with your actual API endpoint
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        _hallData = [responseData]; // Wrap in a list if single object
        _isLoading = false;
        notifyListeners();
      } else {
        _error = 'Failed to load hall data';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = 'An error occurred: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }
}
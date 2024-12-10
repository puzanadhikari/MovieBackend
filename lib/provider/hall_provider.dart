import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:movie_booking_flutter_backend/constant/api_const.dart';
import 'dart:convert';

class HallProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> postHallData(BuildContext context, Map hallData) async {
    // Initialize loading state
    _setLoadingState(true);
    _setError(null);

    try {
      final response = await http.post(
        Uri.parse('${ApiConstant.protocol}${ApiConstant.baseUrl}${ApiConstant.addHall}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(hallData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse the response if needed
        final responseBody = json.decode(response.body);

        // Show success toast
        _showToast("Hall added successfully", Color(0xFFFCC434));

        // Navigate back to the previous screen
        Navigator.of(context).pop();

        // Reset loading state
        _setLoadingState(false);
        return true;
      } else {
        // Handle error response
        _setError('Failed to post hall data: ${response.body}');
        _setLoadingState(false);
        return false;
      }
    } catch (e) {
      // Catch network or JSON errors
      _setError('An error occurred: $e');
      _setLoadingState(false);
      return false;
    }
  }

  void _setLoadingState(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }

  void _showToast(String message, Color bgColor) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: bgColor,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
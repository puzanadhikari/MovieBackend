import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:movie_booking_flutter_backend/constant/api_const.dart';

class SignUpProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> signUp({
    required String name,
    required String dateOfBirth,
    required String address,
    required String email,
    required String phone,
    required String password,
    required String profileImage,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final url = '${ApiConstant.protocol}${ApiConstant.baseUrl}${ApiConstant.signup}';
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': name,
          'dob': dateOfBirth,
          'address': address,
          'email': email,
          'phone': phone,
          'password': password,
          'photo': profileImage,
        }),
      );

      switch (response.statusCode) {
        case 200:
        case 201:
          _showToast("Sign Up Successful!!!", isError: false);
          return true;

        case 400:
        // Bad request - validation errors
          final errorBody = _parseErrorResponse(response);
          _errorMessage = errorBody['message'] ?? 'Invalid sign-up details';
          _showToast(_errorMessage!);
          return false;

        case 409:
        // Conflict - user already exists
          _errorMessage = "An account with this email already exists";
          _showToast(_errorMessage!);
          return false;

        case 422:
        // Unprocessable entity - validation failed
          final errorBody = _parseErrorResponse(response);
          _errorMessage = errorBody['message'] ?? 'Validation failed';
          _showToast(_errorMessage!);
          return false;

        case 500:
        case 502:
        case 503:
        case 504:
        // Server errors
          _errorMessage = "Server error. Please try again later.";
          _showToast(_errorMessage!);
          return false;

        default:
        // Unexpected status code
          _errorMessage = "An unexpected error occurred. Status code: ${response.statusCode}";
          _showToast(_errorMessage!);
          return false;
      }
    } catch (error) {
      log("Sign Up Error: $error");
      _errorMessage = "Network error. Please check your connection.";
      _showToast(_errorMessage!);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Map<String, dynamic> _parseErrorResponse(http.Response response) {
    try {
      return json.decode(response.body);
    } catch (e) {
      return {'message': 'Unable to parse error message'};
    }
  }

  void _showToast(String message, {bool isError = true}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: isError ? Colors.red : Color(0xFFFCC434),
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
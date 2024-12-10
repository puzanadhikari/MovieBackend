import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:movie_booking_flutter_backend/constant/api_const.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginProvider with ChangeNotifier {
  bool isLoading = false;

  Future<bool> login(String email, String password, BuildContext context) async {
    isLoading = true;
    notifyListeners();

    try {
      final url = '${ApiConstant.protocol}${ApiConstant.baseUrl}${ApiConstant.login}';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      switch (response.statusCode) {
        case 200:
        case 201:
          _showToast("Login successful", isError: false);
          return true;

        case 400:
          final errorBody = _parseErrorResponse(response);
          _showToast(errorBody['message'] ?? "Invalid credentials");
          return false;

        case 401:
          _showToast("Authentication failed. Please check your credentials");
          return false;

        case 403:
          _showToast("Access denied. Please contact support.");
          return false;

        case 404:
          _showToast("User not found. Please check your email.");
          return false;

        case 500:
        case 502:
        case 503:
        case 504:
          _showToast("Server error. Please try again later.");
          return false;

        default:
          _showToast("An unexpected error occurred. Status code: ${response.statusCode}");
          return false;
      }
    } on TimeoutException {
      _showToast("Connection timed out. Please check your internet.");
      return false;
    } on http.ClientException {
      _showToast("Network error. Please check your connection.");
      return false;
    } catch (error) {
      log("Unexpected Login Error: $error");
      _showToast("An unexpected error occurred. Please try again.");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Map<String, dynamic> _parseErrorResponse(http.Response response) {
    try {
      return json.decode(response.body);
    } catch (e) {
      return {'message': 'Unknown error occurred'};
    }
  }

  void _showToast(String message, {bool isError = true}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: isError ? Colors.red : Color(0xFFFCC434),
      textColor: Colors.white,
    );
  }
}
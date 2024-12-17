import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:movie_booking_flutter_backend/constant/api_const.dart';

class AddHallProvider with ChangeNotifier {
  bool _isLoading = false;
  int? _statusCode;

  bool get isLoading => _isLoading;

  int? get statusCode => _statusCode;

  Future<void> submitHall(
      Map<String, dynamic> hallData, BuildContext context) async {
    _isLoading = true;
    _statusCode = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(
            '${ApiConstant.protocol}${ApiConstant.baseUrl}${ApiConstant.addHall}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(hallData),
      );

      _statusCode = response.statusCode;
      _isLoading = false;
      notifyListeners();
      String message;
      Color backgroundColor;
      // Comprehensive error handling for different status codes
      switch (response.statusCode) {
        case 200:
        case 201:
          message = "Hall added successfully!";
          backgroundColor = Colors.green;
          Navigator.pop(context);
          break;
        case 400:
          final errorBody = json.decode(response.body);
          message = errorBody['message'] ?? "Bad Request: Invalid data";
          backgroundColor = Colors.orange;
          break;
        case 401:
          message = "Unauthorized: Authentication required";
          backgroundColor = Colors.red;
          break;
        case 403:
          message = "Forbidden: Insufficient permissions";
          backgroundColor = Colors.red;
          break;
        case 404:
          message = "Not Found: Resource unavailable";
          backgroundColor = Colors.red;
          break;
        case 500:
          message = "Server Error: Internal server problem";
          backgroundColor = Colors.red;
          break;
        case 502:
          message = "Bad Gateway: Server temporarily unavailable";
          backgroundColor = Colors.red;
          break;
        case 503:
          message = "Service Unavailable: Server overloaded";
          backgroundColor = Colors.red;
          break;
        default:
          message = "Error: Unexpected status code ${response.statusCode}";
          backgroundColor = Colors.red;
      }

      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: backgroundColor,
        textColor: Colors.white,
      );
    } catch (e) {
      _statusCode = null;
      _isLoading = false;
      Fluttertoast.showToast(
        msg: "Error: ${e.toString()}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );

      // Network or other exceptions
      Fluttertoast.showToast(
        msg: "Network Error: ${e.toString()}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }
}

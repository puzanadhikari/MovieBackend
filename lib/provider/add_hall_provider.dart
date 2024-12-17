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

  Future<void> submitHall(Map<String, dynamic> hallData, BuildContext context) async {
    _isLoading = true;
    _statusCode = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${ApiConstant.protocol}${ApiConstant.baseUrl}${ApiConstant.addHall}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(hallData),
      );

      _statusCode = response.statusCode;
      _isLoading = false;
      notifyListeners();

      // Check response status and show appropriate toast
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success case
        Fluttertoast.showToast(
          msg: "Hall added successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        // Navigate back
        Navigator.pop(context);
      } else {
        // Error case
        Fluttertoast.showToast(
          msg: "Failed to add hall. Status code: ${response.statusCode}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      _statusCode = null;
      _isLoading = false;
      notifyListeners();

      // Error toast for network or other exceptions
      Fluttertoast.showToast(
        msg: "Error: ${e.toString()}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }
}
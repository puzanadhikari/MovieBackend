import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:movie_booking_flutter_backend/constant/api_const.dart';
import 'dart:convert';

class UsersProvider with ChangeNotifier {
  List<dynamic> _users = [];
  bool _isLoading = false;
  String _error = '';

  List<dynamic> get users => _users;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchUsers() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final url = '${ApiConstant.protocol}${ApiConstant.baseUrl}${ApiConstant.getUsers}';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        _users = json.decode(response.body);
      } else {
        _error = 'Failed to load users';
      }
    } catch (e) {
      _error = 'An error occurred: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
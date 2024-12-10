import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:movie_booking_flutter_backend/constant/api_const.dart';

class GetMovieProvider extends ChangeNotifier {
  List<dynamic> _nowShowingMovies = [];
  List<dynamic> _upcomingMovies = [];
  bool _isLoading = false;
  String _error = '';

  List<dynamic> get nowShowingMovies => _nowShowingMovies;
  List<dynamic> get upcomingMovies => _upcomingMovies;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchMovies(String status) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // Construct the full URL
      final url = Uri.parse(
          '${ApiConstant.protocol}${ApiConstant.baseUrl}${ApiConstant.getMovie}?status=$status'
      );
      developer.log('Fetching movies URL: $url', name: 'MovieProvider');

      // Add headers if needed
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        // Add any additional headers like authorization if required
        // 'Authorization': 'Bearer YOUR_TOKEN_HERE',
      };

      // Make the HTTP GET request
      final response = await http.get(
        url,
        headers: headers,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Connection timed out. Please check your internet connection.');
        },
      );

      developer.log('Response status code: ${response.statusCode}', name: 'MovieProvider');
      developer.log('Response body: ${response.body}', name: 'MovieProvider');

      // Handle different status codes
      switch (response.statusCode) {
        case 200:
        // Successful response
          final dynamic responseData = json.decode(response.body);

          // Handle different possible response structures
          List<dynamic> movieData;
          if (responseData is Map && responseData.containsKey('data')) {
            // If response is a Map with 'data' key
            movieData = responseData['data'];
          } else if (responseData is List) {
            // If response is directly a List
            movieData = responseData;
          } else {
            // Handle unexpected response format
            throw FormatException('Unexpected data format');
          }

          // Update movies based on status
          if (status == 'Now Showing') {
            _nowShowingMovies = movieData;
          } else if (status == 'Upcoming') {
            _upcomingMovies = movieData;
          }
          break;

        case 400:
          _error = 'Bad Request. Please check your input.';
          break;
        case 401:
          _error = 'Unauthorized. Please log in again.';
          break;
        case 403:
          _error = 'Access Forbidden. You do not have permission.';
          break;
        case 404:
          _error = 'Movies not found. Please try again later.';
          break;
        case 500:
          _error = 'Server error. Please try again later.';
          break;
        case 502:
          _error = 'Bad Gateway. Server is temporarily unavailable.';
          break;
        case 503:
          _error = 'Service Unavailable. Please try again later.';
          break;
        case 504:
          _error = 'Gateway Timeout. Please check your connection.';
          break;
        default:
          _error = 'An unexpected error occurred. Status code: ${response.statusCode}';
      }

      // Log any error
      if (_error.isNotEmpty) {
        developer.log(_error, name: 'MovieProvider');
      }
    } catch (e) {
      // Handle any unexpected exceptions
      _error = _getErrorMessage(e);
      developer.log(_error, name: 'MovieProvider', error: e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper method to generate user-friendly error messages
  String _getErrorMessage(dynamic error) {
    if (error is TimeoutException) {
      return 'Connection timed out. Please check your internet connection.';
    } else if (error is FormatException) {
      return 'Unable to process the data. Please try again.';
    } else if (error is http.ClientException) {
      return 'Network error. Please check your connection.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }
}

// Custom exception for timeout
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => message;
}
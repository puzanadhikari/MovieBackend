import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:movie_booking_flutter_backend/constant/api_const.dart';

class MovieProvider with ChangeNotifier {
  // Movie Details
  String _title = '';
  String _description = '';
  String _director = '';
  String _trailerLink = '';
  String _language = 'English';
  String _status = 'Upcoming';
  DateTime? _releaseDate;
  final List<String> _genres = [];
  final List<String> _leadCast = [];
  final List<String> _selectedFormats = [];
  final Map<DateTime, List<TimeOfDay>> _showtimes = {};
  File? _posterFile;

  // Getters
  String get title => _title;
  String get description => _description;
  String get director => _director;
  String get trailerLink => _trailerLink;
  String get language => _language;
  String get status => _status;
  DateTime? get releaseDate => _releaseDate;
  List<String> get genres => _genres;
  List<String> get leadCast => _leadCast;
  List<String> get selectedFormats => _selectedFormats;
  Map<DateTime, List<TimeOfDay>> get showtimes => _showtimes;
  File? get posterFile => _posterFile;

  // Setters
  void setTitle(String title) {
    _title = title;
    notifyListeners();
  }

  void setDescription(String description) {
    _description = description;
    notifyListeners();
  }

  void setDirector(String director) {
    _director = director;
    notifyListeners();
  }

  void setTrailerLink(String trailerLink) {
    _trailerLink = trailerLink;
    notifyListeners();
  }

  void setLanguage(String language) {
    _language = language;
    notifyListeners();
  }

  void setStatus(String status) {
    _status = status;
    notifyListeners();
  }

  void setReleaseDate(DateTime releaseDate) {
    _releaseDate = releaseDate;
    notifyListeners();
  }

  void addGenre(String genre) {
    if (!_genres.contains(genre)) {
      _genres.add(genre);
      notifyListeners();
    }
  }

  void removeGenre(String genre) {
    _genres.remove(genre);
    notifyListeners();
  }

  void addCastMember(String castMember) {
    if (!_leadCast.contains(castMember)) {
      _leadCast.add(castMember);
      notifyListeners();
    }
  }

  void removeCastMember(String castMember) {
    _leadCast.remove(castMember);
    notifyListeners();
  }

  void toggleFormat(String format) {
    if (_selectedFormats.contains(format)) {
      _selectedFormats.remove(format);
    } else {
      _selectedFormats.add(format);
    }
    notifyListeners();
  }

  void addShowtime(DateTime date, TimeOfDay time) {
    if (_showtimes[date] == null) {
      _showtimes[date] = [];
    }
    if (!_showtimes[date]!.contains(time)) {
      _showtimes[date]!.add(time);
      notifyListeners();
    }
  }

  void removeShowtime(DateTime date, TimeOfDay time) {
    if (_showtimes[date] != null) {
      _showtimes[date]!.remove(time);
      if (_showtimes[date]!.isEmpty) {
        _showtimes.remove(date);
      }
      notifyListeners();
    }
  }

  // Pick image for the movie poster
  Future<void> pickImage() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _posterFile = File(pickedFile.path);
        notifyListeners();
      }
    } catch (e) {
      log('Error picking image: $e');
    }
  }

  // Submit movie data
  Future<bool> submitMovie(BuildContext context) async {
    // Validate required fields
    if (!_validateMovieData()) {
      _showToast('Please fill all required fields', isError: true);
      return false;
    }

    try {
      // Encode image to base64
      final bytes = await _posterFile!.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Prepare the movie data
      final movieData = _prepareMovieData(base64Image);

      // Submit movie data
      final movieSubmissionUrl = '${ApiConstant.protocol}${ApiConstant.baseUrl}${ApiConstant.addMovie}';
      final response = await http.post(
        Uri.parse(movieSubmissionUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(movieData),
      );

      // Handle response based on status code
      return _handleMovieSubmissionResponse(response, context);
    } catch (e) {
      _showToast('Network error: $e', isError: true);
      return false;
    }
  }

  bool _validateMovieData() {
    return _title.isNotEmpty &&
        _description.isNotEmpty &&
        _director.isNotEmpty &&
        _releaseDate != null &&
        _posterFile != null &&
        _genres.isNotEmpty &&
        _leadCast.isNotEmpty;
  }

  Map<String, dynamic> _prepareMovieData(String base64Image) {
    return {
      "photo": base64Image,
      "title": _title,
      "description": _description,
      "director": _director,
      "language": _language,
      "format": _selectedFormats.isEmpty ? ["2D"] : _selectedFormats,
      "genre": _genres,
      "link": _trailerLink,
      "status": _status,
      "cast": _leadCast,
      "date": _showtimes.keys
          .map((date) => DateFormat('yyyy-MM-dd').format(date))
          .toList(),
      "dateTime": _showtimes.entries.expand((entry) {
        return entry.value.map((time) => {
          "date": DateFormat('yyyy-MM-dd').format(entry.key),
          "time": "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}"
        });
      }).toList(),
      "releaseDate": DateFormat('yyyy-MM-dd').format(_releaseDate!)
    };
  }

  bool _handleMovieSubmissionResponse(http.Response response, BuildContext context) {
    switch (response.statusCode) {
      case 200: // OK
      case 201: // Created
        _showToast('Movie added successfully!', isError: false);
        resetMovie();
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        return true;

      case 400: // Bad Request
        _showToast('Invalid movie data. Please check your inputs.', isError: true);
        return false;

      case 401: // Unauthorized
        _showToast('Authentication failed. Please log in again.', isError: true);
        return false;

      case 403: // Forbidden
        _showToast('You do not have permission to add movies.', isError: true);
        return false;

      case 404: // Not Found
        _showToast('Movie submission endpoint not found.', isError: true);
        return false;

      case 409: // Conflict
        _showToast('A movie with similar details already exists.', isError: true);
        return false;

      case 422: // Unprocessable Entity
        _showToast('Unable to process movie data. Check your inputs.', isError: true);
        return false;

      case 500: // Internal Server Error
        _showToast('Server error. Please try again later.', isError: true);
        return false;

      case 502: // Bad Gateway
        _showToast('Bad gateway. Server is down.', isError: true);
        return false;

      case 503: // Service Unavailable
        _showToast('Service temporarily unavailable. Try again later.', isError: true);
        return false;

      case 504: // Gateway Timeout
        _showToast('Request timed out. Check your network connection.', isError: true);
        return false;

      default:
        _showToast('Unexpected error: ${response.statusCode}', isError: true);
        return false;
    }
  }

  void _showToast(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: isError ? Colors.red : Color(0xFFFCC434),
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  // Reset all fields
  void resetMovie() {
    _title = '';
    _description = '';
    _director = '';
    _trailerLink = '';
    _language = 'English';
    _releaseDate = null;
    _genres.clear();
    _leadCast.clear();
    _selectedFormats.clear();
    _showtimes.clear();
    _posterFile = null;
    notifyListeners();
  }
}
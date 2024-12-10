import 'package:flutter/material.dart';
import 'package:movie_booking_flutter_backend/provider/movie_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class CreateMovies extends StatefulWidget {
  const CreateMovies({Key? key}) : super(key: key);

  @override
  _CreateMoviesState createState() => _CreateMoviesState();
}

class _CreateMoviesState extends State<CreateMovies> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _directorController = TextEditingController();
  final TextEditingController _castController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  final TextEditingController _trailerLinkController = TextEditingController();
  final TextEditingController _releaseDateController = TextEditingController();

  final List<String> _languages = [
    'English',
    'Spanish',
    'Hindi',
    'French',
    'Mandarin'
  ];

  final List<String> _status = [
    'Upcoming',
    'Now Showing',
  ];

  // Input decoration helper method
  InputDecoration _inputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: Colors.white54),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white24),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFFCC434)),
        borderRadius: BorderRadius.circular(10),
      ),
      filled: true,
      fillColor: Colors.grey[900],
    );
  }

  Future<void> _selectReleaseDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );

    if (pickedDate != null) {
      setState(() {
        _releaseDateController.text =
            DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  // Submit movie method
  Future<void> _submitMovie() async {
    if (_formKey.currentState!.validate()) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        // Get the provider
        final movieProvider =
            Provider.of<MovieProvider>(context, listen: false);

        // Set all the values
        movieProvider.setTitle(_titleController.text.trim());
        movieProvider.setDescription(_descriptionController.text.trim());
        movieProvider.setDirector(_directorController.text.trim());
        movieProvider.setTrailerLink(_trailerLinkController.text.trim());

        // Set release date - parse the date string to DateTime
        movieProvider.setReleaseDate(
            DateFormat('dd/MM/yyyy').parse(_releaseDateController.text));

        // Submit the movie
        bool success = await movieProvider.submitMovie(context);

        if (success) {
          _formKey.currentState!.reset();
          _titleController.clear();
          _descriptionController.clear();
          _directorController.clear();
          _trailerLinkController.clear();
          _releaseDateController.clear();
        } else {
        }
      } catch (e) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MovieProvider>(
      builder: (context, movieProvider, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: const Text(
              'Create Movie',
              style: TextStyle(color: Color(0xFFFCC434)),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFFCC434)),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overscroll) {
              overscroll.disallowIndicator();
              return false;
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Movie Poster Upload
                    GestureDetector(
                      onTap: () => movieProvider.pickImage(),
                      child: Container(
                        height: 400,
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          border: Border.all(color: Colors.white24),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: movieProvider.posterFile != null
                            ? Image.file(movieProvider.posterFile!,
                                fit: BoxFit.cover)
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.cloud_upload,
                                    color: Color(0xFFFCC434),
                                    size: 50,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Upload Movie Poster',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Movie Title
                    TextFormField(
                      controller: _titleController,
                      decoration: _inputDecoration('Movie Title'),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter movie title' : null,
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: _inputDecoration('Description'),
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                      validator: (value) => value!.isEmpty
                          ? 'Please enter movie description'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Director
                    TextFormField(
                      controller: _directorController,
                      decoration: _inputDecoration('Director'),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter director name' : null,
                    ),
                    const SizedBox(height: 16),

                    // Trailer Link
                    TextFormField(
                      controller: _trailerLinkController,
                      decoration: _inputDecoration('Trailer Link'),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),

                    // Language Dropdown
                    DropdownButtonFormField<String>(
                      value: movieProvider.language,
                      dropdownColor: Colors.black,
                      decoration: _inputDecoration('Movie Language'),
                      items: _languages.map((language) {
                        return DropdownMenuItem(
                          value: language,
                          child: Text(
                            language,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        movieProvider.setLanguage(value!);
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: movieProvider.status,
                      dropdownColor: Colors.black,
                      decoration: _inputDecoration('Status'),
                      items: _status.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(
                            status,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        movieProvider.setStatus(value!);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Release Date
                    TextFormField(
                      controller: _releaseDateController,
                      decoration: _inputDecoration('Release Date'),
                      style: const TextStyle(color: Colors.white),
                      readOnly: true,
                      onTap: _selectReleaseDate,
                      validator: (value) =>
                          value!.isEmpty ? 'Please select release date' : null,
                    ),
                    const SizedBox(height: 16),

                    // Formats Multiselect
                    const Text(
                      'Movie Formats',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Wrap(
                      spacing: 8.0,
                      children: ['2D', '3D', 'IMAX', '4DX'].map((format) {
                        return FilterChip(
                          label: Text(format),
                          selected:
                              movieProvider.selectedFormats.contains(format),
                          onSelected: (bool selected) {
                            movieProvider.toggleFormat(format);
                          },
                          backgroundColor: Colors.grey[900],
                          selectedColor: const Color(0xFFFCC434),
                          labelStyle: TextStyle(
                            color: movieProvider.selectedFormats.contains(format)
                                ? Colors.black
                                : Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Showtimes
                    const Text(
                      'Showtimes',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    ElevatedButton(
                      onPressed: () => _showAddShowtimeDialog(movieProvider),
                      child: const Text('Add Showtime'),
                    ),
                    const SizedBox(height: 8),

                    // Display Added Showtimes
                    Column(
                      children: movieProvider.showtimes.entries.map((entry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('dd/MM/yyyy').format(entry.key),
                              style: const TextStyle(color: Colors.white),
                            ),
                            Wrap(
                              spacing: 8.0,
                              children: entry.value.map((time) {
                                return Chip(
                                  label: Text(time.format(context)),
                                  deleteIcon: const Icon(Icons.close),
                                  onDeleted: () => movieProvider.removeShowtime(
                                      entry.key, time),
                                );
                              }).toList(),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Genres
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _genreController,
                            decoration: _inputDecoration('Genre'),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Color(0xFFFCC434)),
                          onPressed: () {
                            if (_genreController.text.isNotEmpty) {
                              movieProvider
                                  .addGenre(_genreController.text.trim());
                              _genreController.clear();
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Display Added Genres
                    Wrap(
                      spacing: 8.0,
                      children: movieProvider.genres.map((genre) {
                        return Chip(
                          label: Text(genre),
                          deleteIcon: const Icon(Icons.close),
                          onDeleted: () => movieProvider.removeGenre(genre),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Lead Cast
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _castController,
                            decoration: _inputDecoration('Lead Cast Member'),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Color(0xFFFCC434)),
                          onPressed: () {
                            if (_castController.text.isNotEmpty) {
                              movieProvider
                                  .addCastMember(_castController.text.trim());
                              _castController.clear();
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Display Added Cast Members
                    Wrap(
                      spacing: 8.0,
                      children: movieProvider.leadCast.map((member) {
                        return Chip(
                          label: Text(member),
                          deleteIcon: const Icon(Icons.close),
                          onDeleted: () => movieProvider.removeCastMember(member),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _submitMovie,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFCC434),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Submit Movie',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Showtime dialog method
  void _showAddShowtimeDialog(MovieProvider movieProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        DateTime selectedDate = DateTime.now();
        TimeOfDay selectedTime = TimeOfDay.now();

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Showtime'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Date Picker
                  ElevatedButton(
                    onPressed: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2025),
                      );

                      if (pickedDate != null) {
                        setState(() {
                          selectedDate = pickedDate;
                        });
                      }
                    },
                    child: Text(
                        'Select Date: ${DateFormat('dd/MM/yyyy').format(selectedDate)}'),
                  ),

                  // Time Picker
                  ElevatedButton(
                    onPressed: () async {
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );

                      if (pickedTime != null) {
                        setState(() {
                          selectedTime = pickedTime;
                        });
                      }
                    },
                    child: Text('Select Time: ${selectedTime.format(context)}'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    // Add showtime via provider
                    movieProvider.addShowtime(selectedDate, selectedTime);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    // Dispose of controllers to prevent memory leaks
    _titleController.dispose();
    _descriptionController.dispose();
    _directorController.dispose();
    _castController.dispose();
    _genreController.dispose();
    _trailerLinkController.dispose();
    _releaseDateController.dispose();
    super.dispose();
  }
}

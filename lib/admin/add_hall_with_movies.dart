import 'package:flutter/material.dart';
import 'package:movie_booking_flutter_backend/provider/get_movie_provider.dart';
import 'package:movie_booking_flutter_backend/provider/hall_provider.dart';
import 'package:provider/provider.dart';

class AddHallWithMovies extends StatefulWidget {
  const AddHallWithMovies({Key? key}) : super(key: key);

  @override
  _AddHallWithMoviesState createState() => _AddHallWithMoviesState();
}

class _AddHallWithMoviesState extends State<AddHallWithMovies> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _audiCapacityController = TextEditingController();
  final TextEditingController _audiDateController = TextEditingController();
  final TextEditingController _audiTimeController = TextEditingController();
  final List<String> _audiNames = ['Audi 1', 'Audi 2', 'Audi 3', 'Audi 4'];
  String? _selectedAudiName;
  dynamic _selectedMovie;
  final List<Map<String, dynamic>> _audiList = [];

  @override
  void initState() {
    super.initState();
    // Removed initial movie fetching
  }

  void _addAudi() {
    if (_selectedAudiName != null &&
        _audiCapacityController.text.isNotEmpty &&
        _audiDateController.text.isNotEmpty &&
        _audiTimeController.text.isNotEmpty) {
      setState(() {
        _audiList.add({
          'name': _selectedAudiName,
          'capacity': _audiCapacityController.text,
          'dateTime': [
            {
              'date': _audiDateController.text,
              'time': _audiTimeController.text,
            }
          ],
        });
        _selectedAudiName = null;
        _audiCapacityController.clear();
        _audiDateController.clear();
        _audiTimeController.clear();
      });
    }
  }

  void _submitHallData() {
    if (_formKey.currentState!.validate()) {
      final hallData = {
        'name': _nameController.text,
        'location': _locationController.text,
        'movieId': _selectedMovie['_id'],
        'audi': _audiList,
      };

      Provider.of<HallProvider>(context, listen: false)
          .postHallData(context, hallData);
    }
  }

  // Custom input decoration
  InputDecoration _inputDecoration(String labelText, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white24),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFFCC434), width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(10),
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white12,
    );
  }

  // Date Picker Method
  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.white,
              onPrimary: Colors.black,
              surface: Colors.black,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.black,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text =
        "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  // Time Picker Method
  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.white,
              onPrimary: Colors.black,
              surface: Colors.black,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.black,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text =
        "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Color(0xFFFCC434)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFFCC434)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Hall Registration',
          style: TextStyle(color: Color(0xFFFCC434)),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer2<HallProvider, GetMovieProvider>(
        builder: (context, hallProvider, movieProvider, child){
          return hallProvider.isLoading
              ? const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          )
              : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hall Details Section
                  _buildSectionTitle('Hall Details'),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _nameController,
                    decoration: _inputDecoration('Hall Name'),
                    style: const TextStyle(color: Colors.white),
                    validator: (value) =>
                    value!.isEmpty ? 'Enter hall name' : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _locationController,
                    decoration: _inputDecoration('Location'),
                    style: const TextStyle(color: Colors.white),
                    validator: (value) =>
                    value!.isEmpty ? 'Enter location' : null,
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<dynamic>(
                    decoration: _inputDecoration('Select Movie'),
                    value: _selectedMovie,
                    onTap: () {
                      // Fetch movies only when the dropdown is tapped
                      if (movieProvider.nowShowingMovies.isEmpty) {
                        movieProvider.fetchMovies('Now Showing');
                      }
                    },
                    items: movieProvider.nowShowingMovies.map((movie) {
                      return DropdownMenuItem<dynamic>(
                        value: movie,
                        child: Text(
                          movie['title'] ?? 'Unknown Movie',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (dynamic newValue) {
                      setState(() {
                        _selectedMovie = newValue;
                      });
                    },
                    dropdownColor: Colors.black,
                    style: const TextStyle(color: Colors.white),
                    validator: (value) =>
                    value == null ? 'Please select a movie' : null,
                  ),

                  const SizedBox(height: 20),
                  _buildSectionTitle('Audi Details'),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    decoration: _inputDecoration('Select Audi'),
                    value: _selectedAudiName,
                    items: _audiNames.map((String audi) {
                      return DropdownMenuItem<String>(
                        value: audi,
                        child: Text(
                          audi,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedAudiName = newValue;
                      });
                    },
                    dropdownColor: Colors.black,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _audiCapacityController,
                    decoration: _inputDecoration('Audi Capacity'),
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _audiDateController,
                          decoration: _inputDecoration('Audi Date',
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.calendar_today,
                                    color: Colors.white70),
                                onPressed: () => _selectDate(
                                    context, _audiDateController),
                              )),
                          style: const TextStyle(color: Colors.white),
                          readOnly: true,
                          onTap: () =>
                              _selectDate(context, _audiDateController),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _audiTimeController,
                          decoration: _inputDecoration('Audi Time',
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.access_time,
                                    color: Colors.white70),
                                onPressed: () => _selectTime(
                                    context, _audiTimeController),
                              )),
                          style: const TextStyle(color: Colors.white),
                          readOnly: true,
                          onTap: () =>
                              _selectTime(context, _audiTimeController),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle,
                            color: Colors.white, size: 40),
                        onPressed: _addAudi,
                      )
                    ],
                  ),

                  // Added Audis
                  const SizedBox(height: 10),
                  _buildAddedItemsList(_audiList, (audi) {
                    setState(() {
                      _audiList.remove(audi);
                    });
                  }, 'No audis added'),

                  // Submit Button
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitHallData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFCC434),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Submit Hall',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ),

                  // Error Display
                  if (hallProvider.error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        hallProvider.error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFFFCC434),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Generic Added Items List Builder
  Widget _buildAddedItemsList(List<Map<String, dynamic>> items,
      void Function(dynamic) onDelete, String emptyMessage) {
    return items.isEmpty
        ? Center(
      child: Text(
        emptyMessage,
        style: const TextStyle(color: Colors.white54),
      ),
    )
        : Column(
      children: items.map((item) {
        // For DateTime items
        if (item.containsKey('date') && item.containsKey('time')) {
          return _buildListTile(
            title: '${item['date']} at ${item['time']}',
            onDelete: () => onDelete(item),
          );
        }
        // For Audi items
        return _buildListTile(
          title: '${item['name']} (Capacity: ${item['capacity']})',
          subtitle:
          'Date: ${item['dateTime'][0]['date']} Time: ${item['dateTime'][0]['time']}',
          onDelete: () => onDelete(item),
        );
      }).toList(),
    );
  }

  // List Tile Builder
  Widget _buildListTile(
      {required String title,
        String? subtitle,
        required VoidCallback onDelete}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: subtitle != null
            ? Text(
          subtitle,
          style: const TextStyle(color: Colors.white70),
        )
            : null,
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
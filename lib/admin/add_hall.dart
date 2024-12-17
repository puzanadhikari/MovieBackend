import 'package:flutter/material.dart';
import 'package:movie_booking_flutter_backend/provider/add_hall_provider.dart';
import 'package:provider/provider.dart';

class AddHall extends StatefulWidget {
  const AddHall({super.key});

  @override
  State<AddHall> createState() => _AddHallState();
}

class _AddHallState extends State<AddHall> {
  final _formKey = GlobalKey<FormState>();

  // Hall details controllers
  final TextEditingController _hallNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  // List to manage multiple audi details
  List<AudiDetails> _auditList = [];

  @override
  void initState() {
    super.initState();
    // Add one audi details by default when the page loads
    _auditList.add(AudiDetails());
  }

  @override
  Widget build(BuildContext context) {
    final hallProvider = Provider.of<AddHallProvider>(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Add Hall',
          style: TextStyle(
            color: Color(0xFFFCC434),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hall Name and Location
                _buildTextField(
                  controller: _hallNameController,
                  label: 'Hall Name',
                  hint: 'Enter hall name',
                  icon: Icons.stadium,
                ),
                SizedBox(height: 16),
                _buildTextField(
                  controller: _locationController,
                  label: 'Location',
                  hint: 'Enter hall location',
                  icon: Icons.location_on,
                ),
                SizedBox(height: 24),

                // Audi Section Title
                Text(
                  'Audi Details',
                  style: TextStyle(
                    color: Color(0xFFFCC434),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),

                // Dynamic Audi List
                ..._auditList.asMap().entries.map((entry) {
                  int index = entry.key;
                  AudiDetails audi = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Card(
                      color: Colors.grey[900],
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Color(0xFFFCC434), width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Audi ${index + 1}',
                                  style: TextStyle(
                                    color: Color(0xFFFCC434),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // Only show delete button if there's more than one audi
                                if (_auditList.length > 1)
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        _auditList.removeAt(index);
                                      });
                                    },
                                  ),
                              ],
                            ),
                            SizedBox(height: 8),
                            _buildTextField(
                              controller: audi.nameController,
                              label: 'Audi Name',
                              hint: 'Enter audi name',
                              icon: Icons.room,
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: audi.capacityController,
                                    label: 'Capacity',
                                    hint: 'Total seats',
                                    icon: Icons.people,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    controller: audi.rowsController,
                                    label: 'Rows',
                                    hint: 'Number of rows',
                                    icon: Icons.table_rows,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            _buildTextField(
                              controller: audi.columnsController,
                              label: 'Columns',
                              hint: 'Number of columns',
                              icon: Icons.table_chart,
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),

                // Add Audi Button
                ElevatedButton(
                  onPressed: _addAudi,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFCC434),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Add Another Audi',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 16),

                ElevatedButton(
                  onPressed: hallProvider.isLoading ? null : () {
                    if (_formKey.currentState!.validate()) {
                      // Prepare hall data
                      Map<String, dynamic> hallData = {
                        "name": _hallNameController.text,
                        "location": _locationController.text,
                        "audi": _auditList.map((audi) => {
                          "name": audi.nameController.text,
                          "capacity": audi.capacityController.text,
                          "row": int.parse(audi.rowsController.text),
                          "col": int.parse(audi.columnsController.text)
                        }).toList()
                      };

                      // Submit to provider with context
                      hallProvider.submitHall(hallData, context);
                    }
                  },
                  child: hallProvider.isLoading
                      ? CircularProgressIndicator()
                      : Text('Submit Hall'),
                ),

                if (hallProvider.statusCode != null)
                  Text('Status Code: ${hallProvider.statusCode}'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // TextField builder method (remains the same as in previous version)
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Color(0xFFFCC434)),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Color(0xFFFCC434)),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0xFFFCC434), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0xFFFCC434), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0xFFFCC434), width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  // Method to add a new Audi
  void _addAudi() {
    setState(() {
      _auditList.add(AudiDetails());
    });
  }


  @override
  void dispose() {
    // Dispose of all controllers
    _hallNameController.dispose();
    _locationController.dispose();

    // Dispose of all audi controllers
    for (var audi in _auditList) {
      audi.dispose();
    }

    super.dispose();
  }
}

// Class to manage individual Audi details
class AudiDetails {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController capacityController = TextEditingController();
  final TextEditingController rowsController = TextEditingController();
  final TextEditingController columnsController = TextEditingController();

  void dispose() {
    nameController.dispose();
    capacityController.dispose();
    rowsController.dispose();
    columnsController.dispose();
  }
}
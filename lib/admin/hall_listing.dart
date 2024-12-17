import 'package:flutter/material.dart';
import 'package:movie_booking_flutter_backend/provider/hall_listing_provider.dart';
import 'package:provider/provider.dart';
class HallListing extends StatefulWidget {
  const HallListing({super.key});

  @override
  State<HallListing> createState() => _HallListingState();
}

class _HallListingState extends State<HallListing> {
  @override
  void initState() {
    super.initState();
    // Fetch data when the widget is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HallListingProvider>(context, listen: false).fetchHallData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Hall Listings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<HallListingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          }

          if (provider.error.isNotEmpty) {
            return Center(
              child: Text(
                provider.error,
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          if (provider.hallData.isEmpty) {
            return Center(
              child: Text(
                'No halls found',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return ListView.builder(
            itemCount: provider.hallData.length,
            itemBuilder: (context, index) {
              final hall = provider.hallData[index];
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.grey.shade900,
                        Colors.grey.shade800,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hall['name'] ?? 'Unnamed Hall',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Location: ${hall['location'] ?? 'Unknown'}',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 15),
                        Text(
                          'Auditoriums',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 10),
                        // Auditorium List
                        if (hall['audi'] != null)
                          ...hall['audi'].map<Widget>((audi) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    audi['name'] ?? 'Unnamed Audi',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    'Capacity: ${audi['capacity'] ?? 'N/A'}',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                          )),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:movie_booking_flutter_backend/admin/add_hall_with_movies.dart';
import 'package:movie_booking_flutter_backend/provider/get_hall_provider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class HallWithMovies extends StatefulWidget {
  const HallWithMovies({super.key});

  @override
  State<HallWithMovies> createState() => _HallWithMoviesState();
}

class _HallWithMoviesState extends State<HallWithMovies> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GetHallProvider>(context, listen: false).fetchHalls();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFFCC434)),
          onPressed: () => Navigator.pop(context),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFFCC434)),
        title: const Text(
          'Movie Halls',
          style: TextStyle(
            color: Color(0xFFFCC434),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: _buildFloatingActionButton(context),
      body: Consumer<GetHallProvider>(
        builder: (context, hallProvider, child) {
          if (hallProvider.isLoading) {
            return _buildShimmerLoading();
          }

          if (hallProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red.shade700,
                    size: 80,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Error: ${hallProvider.error}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (hallProvider.halls.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.theater_comedy,
                    color: Colors.red.shade700,
                    size: 80,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No halls found',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: hallProvider.halls.length,
            itemBuilder: (context, index) {
              final hall = hallProvider.halls[index];
              return HallListItem(hall: hall);
            },
          );
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade900,
          highlightColor: Colors.grey.shade800,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hall Name Shimmer
                  Container(
                    width: 200,
                    height: 30,
                    color: Colors.grey.shade800,
                  ),
                  const SizedBox(height: 10),

                  // Location Shimmer
                  Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        color: Colors.grey.shade800,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 150,
                        height: 20,
                        color: Colors.grey.shade800,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Auditoriums Shimmer
                  Container(
                    width: 100,
                    height: 22,
                    color: Colors.grey.shade800,
                  ),
                  const SizedBox(height: 8),

                  // Audi Details Shimmer
                  ...List.generate(
                      2,
                      (index) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
                                  color: Colors.grey.shade800,
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 180,
                                  height: 18,
                                  color: Colors.grey.shade800,
                                ),
                              ],
                            ),
                          )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFCC434),
            Color(0xFFFF6B6B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddHallWithMovies()));
        },
        icon: const Icon(Icons.add, color: Colors.black, size: 30),
        label: const Text(
          'Add Hall',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        highlightElevation: 0,
      ),
    );
  }
}

class HallListItem extends StatelessWidget {
  final dynamic hall;

  const HallListItem({super.key, required this.hall});

  @override
  Widget build(BuildContext context) {
    // Group audis by name
    Map<String, List<dynamic>> groupedAudis = {};
    for (var audi in hall['audi'] ?? []) {
      final audiName = audi['name'];
      if (groupedAudis.containsKey(audiName)) {
        groupedAudis[audiName]!.addAll(audi['dateTime']);
      } else {
        groupedAudis[audiName] = audi['dateTime'] ?? [];
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade900,
            Colors.black87,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hall Name
            Text(
              hall['name'] ?? 'Unnamed Hall',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 10),

            // Location
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.red.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  hall['location'] ?? 'Unknown Location',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Audi Information with Grouped Date and Time
            const Text(
              'Auditoriums',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            // Display unique audis with grouped dates and times
            ...groupedAudis.entries.map<Widget>((entry) {
              String audiName = entry.key;
              List<dynamic> dateTimes = entry.value;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Audi Name and Capacity
                    Row(
                      children: [
                        Icon(Icons.theater_comedy,
                            color: Colors.red.shade700, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          audiName,
                          style: TextStyle(
                            color: Colors.grey.shade300,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),

                    // List of Dates and Times for this Audi
                    ...dateTimes.map<Widget>((dateTime) => Padding(
                          padding: const EdgeInsets.only(left: 30, top: 4),
                          child: Row(
                            children: [
                              Icon(Icons.date_range,
                                  color: Colors.grey.shade500, size: 16),
                              const SizedBox(width: 5),
                              Text(
                                '${dateTime['date']} at ${dateTime['time']}',
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

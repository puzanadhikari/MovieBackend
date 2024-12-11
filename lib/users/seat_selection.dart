import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:movie_booking_flutter_backend/users/configuration_page.dart';

class SeatSelectionPage extends StatefulWidget {
  final Map<String, dynamic> movieDetails;

  const SeatSelectionPage({Key? key, required this.movieDetails}) : super(key: key);

  @override
  _SeatSelectionPageState createState() => _SeatSelectionPageState();
}

class _SeatSelectionPageState extends State<SeatSelectionPage> {
  late int totalCapacity;
  late List<String> rows;
  Map<String, List<bool>> seatStatus = {};
  List<String> selectedSeats = [];

  @override
  void initState() {
    super.initState();
    _initializeSeatLayout();
  }

  void _initializeSeatLayout() {
    // Parse capacity from movie details
    totalCapacity = int.tryParse(widget.movieDetails['capacity'] ?? '0') ?? 0;

    // Generate seat layout based on capacity
    if (totalCapacity <= 60) {
      rows = ['A', 'B', 'C', 'D'];
      seatStatus = {
        'A': List.generate(8, (_) => false),
        'B': List.generate(8, (_) => false),
        'C': List.generate(8, (_) => false),
        'D': List.generate(8, (_) => false),
      };
    }
    else if (totalCapacity <= 100) {
      rows = ['A', 'B', 'C', 'D', 'E', 'F'];
      seatStatus = {
        'A': List.generate(10, (_) => false),
        'B': List.generate(10, (_) => false),
        'C': List.generate(10, (_) => false),
        'D': List.generate(10, (_) => false),
        'E': List.generate(10, (_) => false),
        'F': List.generate(10, (_) => false),
      };
    } else {
      rows = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
      seatStatus = {
        'A': List.generate(12, (_) => false),
        'B': List.generate(12, (_) => false),
        'C': List.generate(12, (_) => false),
        'D': List.generate(12, (_) => false),
        'E': List.generate(12, (_) => false),
        'F': List.generate(12, (_) => false),
        'G': List.generate(12, (_) => false),
        'H': List.generate(12, (_) => false),
      };
    }
  }

  void _toggleSeat(String row, int seatNumber) {
    setState(() {
      seatStatus[row]![seatNumber] = !seatStatus[row]![seatNumber];

      String seatId = '$row${seatNumber + 1}';
      if (seatStatus[row]![seatNumber]) {
        selectedSeats.add(seatId);
      } else {
        selectedSeats.remove(seatId);
      }
    });
    log("Seat Status: ${seatStatus[row]![seatNumber]}");
  }

  @override
  Widget build(BuildContext context) {
    // Responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 600;

    // Dynamic seat sizing
    double seatSize = isSmallScreen
        ? 20
        : isMediumScreen
        ? 25
        : 30;

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text(
          'Select Seats',
          style: TextStyle(
            color: const Color(0xFFFCC434),
            fontSize: screenWidth > 600 ? 20 : 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFFCC434)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Movie and Show Details Header
                    Padding(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.movieDetails['movie']['title'] ?? 'Movie',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.06,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${widget.movieDetails['hall']} | '
                                '${widget.movieDetails['audi']} | '
                                '${widget.movieDetails['date']} | '
                                '${widget.movieDetails['time']}',
                            style: TextStyle(
                              color: const Color(0xFFFCC434),
                              fontSize: screenWidth * 0.04,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Screen Indicator with More Space
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.02,
                        horizontal: screenWidth * 0.1,
                      ),
                      child: Container(
                        width: double.infinity,
                        height: 15,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text(
                            'SCREEN',
                            style: TextStyle(
                              color: Color(0xFFFCC434),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Space Between Screen and Seats
                    SizedBox(height: screenHeight * 0.2),

                    // Seat Layout
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                        ),
                        child: Column(
                          children: [
                            Column(
                              children: rows.map((row) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Row Label
                                      Text(
                                        row,
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontWeight: FontWeight.bold,
                                          fontSize: screenWidth * 0.04,
                                        ),
                                      ),
                                      const SizedBox(width: 16),

                                      // Seats
                                      ...List.generate(
                                        seatStatus[row]!.length,
                                            (index) => GestureDetector(
                                          onTap: () => _toggleSeat(row, index),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                            child: Container(
                                              width: seatSize,
                                              height: seatSize,
                                              decoration: BoxDecoration(
                                                color: seatStatus[row]![index]
                                                    ? Colors.green // Changed to green
                                                    : Colors.white12,
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: seatStatus[row]![index]
                                                      ? Colors.transparent
                                                      : Colors.white24,
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '${index + 1}',
                                                  style: TextStyle(
                                                    color: seatStatus[row]![index]
                                                        ? Colors.white
                                                        : Colors.white70,
                                                    fontSize: screenWidth * 0.02,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Selected Seats and Proceed Button
                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      decoration: const BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: SafeArea(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Selected Seats
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Selected Seats',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: screenWidth * 0.035,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    selectedSeats.isEmpty
                                        ? 'No seats selected'
                                        : selectedSeats.join(', '),
                                    style: TextStyle(
                                      color: const Color(0xFFFCC434),
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),

                            // Proceed Button
                            ElevatedButton(
                              onPressed: selectedSeats.isNotEmpty
                                  ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PaymentConfirmationPage(
                                      movieDetails: widget.movieDetails,
                                      selectedSeats: selectedSeats,
                                    ),
                                  ),
                                );
                              }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFCC434),
                                disabledBackgroundColor: Colors.white24,
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.05,
                                  vertical: screenWidth * 0.03,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Proceed',
                                style: TextStyle(
                                  color: selectedSeats.isNotEmpty
                                      ? Colors.black
                                      : Colors.white54,
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenWidth * 0.04,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
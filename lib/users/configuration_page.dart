import 'dart:developer';

import 'package:flutter/material.dart';

class PaymentConfirmationPage extends StatefulWidget {
  final Map<String, dynamic> movieDetails;
  final List<String> selectedSeats;

  const PaymentConfirmationPage({
    Key? key,
    required this.movieDetails,
    required this.selectedSeats
  }) : super(key: key);

  @override
  _PaymentConfirmationPageState createState() => _PaymentConfirmationPageState();
}

class _PaymentConfirmationPageState extends State<PaymentConfirmationPage> {
  final List<String> _paymentMethods = [
    'assets/esewa.png',
    'assets/khalti.png',
    'assets/imepay.png',
  ];

  int? _selectedPaymentMethod;

  double _calculateTotalPrice() {
    int seatCount = widget.selectedSeats.length;
    return seatCount * 12.50; // Assuming $12.50 per ticket
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final totalPrice = _calculateTotalPrice();

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text(
          'Confirm Booking',
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(15),
                ),
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
                    SizedBox(height: screenHeight * 0.02),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${widget.movieDetails['hall']} | '
                                '${widget.movieDetails['audi']}',
                            style: TextStyle(
                              color: const Color(0xFFFCC434),
                              fontSize: screenWidth * 0.04,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      '${widget.movieDetails['date']} | ${widget.movieDetails['time']}',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: screenWidth * 0.035,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              // Seats and Price Section
              Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Seats',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: screenWidth * 0.04,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      widget.selectedSeats.join(', '),
                      style: TextStyle(
                        color: const Color(0xFFFCC434),
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Tickets',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: screenWidth * 0.035,
                          ),
                        ),
                        Text(
                          '${widget.selectedSeats.length}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.04,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Price per Ticket',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: screenWidth * 0.035,
                          ),
                        ),
                        Text(
                          '\$12.50',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.04,
                          ),
                        ),
                      ],
                    ),
                    Divider(color: Colors.white24, height: screenHeight * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Price',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: const Color(0xFFFCC434),
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Method',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(_paymentMethods.length, (index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedPaymentMethod = index;
                            });
                            log("$_selectedPaymentMethod");
                          },
                          child: Container(
                            width: screenWidth * 0.22,
                            height: screenWidth * 0.14,
                            decoration: BoxDecoration(
                              color: _selectedPaymentMethod == index
                                  ? const Color(0xFFFCC434).withOpacity(0.2)
                                  : Colors.white10,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _selectedPaymentMethod == index
                                    ? const Color(0xFFFCC434)
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Image.asset(
                              _paymentMethods[index],
                              fit: BoxFit.contain,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedPaymentMethod != null
                      ? () {}
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFCC434),
                    disabledBackgroundColor: Colors.white24,
                    padding: EdgeInsets.symmetric(
                      vertical: screenWidth * 0.04,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Pay Now',
                    style: TextStyle(
                      color: _selectedPaymentMethod != null
                          ? Colors.black
                          : Colors.white54,
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.045,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
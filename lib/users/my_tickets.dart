import 'package:flutter/material.dart';

class MyTickets extends StatefulWidget {
  const MyTickets({super.key});

  @override
  _MyTicketsState createState() => _MyTicketsState();
}

class _MyTicketsState extends State<MyTickets> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tickets'),
      ),
      body: const Center(
        child: Text('My Tickets Page'),
      ),
    );
  }
}
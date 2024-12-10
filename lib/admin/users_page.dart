import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../provider/users_provider.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UsersProvider>(context, listen: false).fetchUsers();
    });
  }

  String _formatDOB(dynamic dob) {
    if (dob == null) return 'N/A';

    try {
      // If it's already a DateTime or String
      if (dob is DateTime) {
        return DateFormat('dd MMM yyyy').format(dob);
      }

      // If it's a timestamp or int
      if (dob is int) {
        final DateTime date = DateTime.fromMillisecondsSinceEpoch(dob);
        return DateFormat('dd MMM yyyy').format(date);
      }

      // If it's a string that can be parsed
      return DateFormat('dd MMM yyyy').format(DateTime.parse(dob));
    } catch (e) {
      return 'Invalid Date';
    }
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[900]!,
            highlightColor: Colors.grey[850]!,
            child: Card(
              color: Colors.grey[900],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(radius: 40, backgroundColor: Colors.grey[800]),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(4, (_) =>
                            Container(
                              width: double.infinity,
                              height: 10,
                              color: Colors.white,
                              margin: const EdgeInsets.symmetric(vertical: 5),
                            )
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: const Text(
          'Users',
          style: TextStyle(color: Color(0xFFFCC434), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        //give another icon for the back button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFFCC434)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<UsersProvider>(
        builder: (context, usersProvider, child) {
          if (usersProvider.isLoading) {
            return _buildShimmerLoading();
          }

          if (usersProvider.error.isNotEmpty) {
            return Center(
              child: Text(
                'Error: ${usersProvider.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (usersProvider.users.isEmpty) {
            return const Center(
              child: Text(
                'No users found',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overscroll) {
              overscroll.disallowIndicator();
              return false;
            },
            child: ListView.builder(
              itemCount: usersProvider.users.length,
              itemBuilder: (context, index) {
                final user = usersProvider.users[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Card(
                    color: Colors.grey[900],
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey[800],
                            backgroundImage: user['photo'] != null
                                ? MemoryImage(base64Decode(user['photo']))
                                : null,
                            child: user['photo'] == null
                                ? const Icon(Icons.person, color: Colors.white, size: 40)
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user['username'] ?? 'N/A',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildInfoRow(Icons.email, user['email'] ?? 'N/A'),
                                _buildInfoRow(Icons.phone, user['phone'] ?? 'N/A'),
                                _buildInfoRow(
                                    Icons.cake,
                                    _formatDOB(user['dob'])
                                ),
                                _buildInfoRow(Icons.location_on, user['address'] ?? 'N/A'),
                              ],
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
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MovieDetailsPage extends StatelessWidget {
  final dynamic movie;

  const MovieDetailsPage({Key? key, required this.movie}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Decode base64 image if present
    ImageProvider? imageProvider;
    if (movie['photo'] != null && movie['photo'] is String) {
      try {
        // Remove data URI prefix if present
        String base64Image = movie['photo'];
        if (base64Image.contains(',')) {
          base64Image = base64Image.split(',')[1];
        }

        // Decode base64 to Uint8List
        final bytes = base64Decode(base64Image);
        imageProvider = MemoryImage(bytes);
      } catch (e) {
        imageProvider = null;
      }
    }

    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFFCC434)),
                onPressed: () => Navigator.pop(context),
              ),
              expandedHeight: 450.0,
              floating: false,
              pinned: true,
              backgroundColor: Colors.black87,
              flexibleSpace: FlexibleSpaceBar(
                background: imageProvider != null
                    ? Image(
                  image: imageProvider,
                  width: double.infinity,
                  fit: BoxFit.fill,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[800],
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    );
                  },
                )
                    : CachedNetworkImage(
                  imageUrl: movie['photo'] ?? '',
                  width: double.infinity,
                  fit: BoxFit.fill,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[800],
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFCC434),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[800],
                    child: const Center(
                      child: Icon(
                        Icons.error,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Movie Title
                  Text(
                    movie['title'] ?? 'Unknown Title',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Movie Metadata Row
                  Row(
                    children: [
                      _buildMetadataChip(
                        movie['language'] ?? 'Unknown',
                        Icons.language,
                      ),
                      const SizedBox(width: 8),
                      _buildMetadataChip(
                        movie['format'] != null
                            ? movie['format'].join(', ')
                            : 'Unknown Format',
                        Icons.format_size,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Detailed Information Section
                  _buildSectionTitle('Movie Details'),

                  // Genre
                  _buildDetailRow(
                    'Genre',
                    movie['genre'] != null
                        ? movie['genre'].join(', ')
                        : 'Unknown Genre',
                  ),

                  // Cast
                  _buildDetailRow(
                    'Cast',
                    movie['cast'] != null
                        ? movie['cast'].join(', ')
                        : 'Unknown Cast',
                  ),

                  // Release Date
                  _buildDetailRow(
                    'Release Date',
                    movie['releaseDate'] ?? 'Unknown Date',
                  ),

                  // Description (now at the end)
                  if (movie['description'] != null) ...[
                    const SizedBox(height: 16),
                    _buildSectionTitle('Synopsis'),
                    Text(
                      movie['description'],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: const Color(0xFFFCC434),
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFFCC434),
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
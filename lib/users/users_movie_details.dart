import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movie_booking_flutter_backend/provider/get_hall_provider.dart';
import 'package:provider/provider.dart';
// Assuming you have this provider import

class UserMovieDetail extends StatefulWidget {
  final dynamic movie;

  const UserMovieDetail({Key? key, required this.movie}) : super(key: key);

  @override
  _UserMovieDetailState createState() => _UserMovieDetailState();
}

class _UserMovieDetailState extends State<UserMovieDetail> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Fetch halls when the page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GetHallProvider>(context, listen: false).fetchHalls();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Decode base64 image if present
    ImageProvider? imageProvider;
    if (widget.movie['photo'] != null && widget.movie['photo'] is String) {
      try {
        // Remove data URI prefix if present
        String base64Image = widget.movie['photo'];
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
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFFCC434)),
                  onPressed: () => Navigator.pop(context),
                ),
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                backgroundColor: Colors.black87,
                flexibleSpace: FlexibleSpaceBar(
                  background: imageProvider != null
                      ? Image(
                    image: imageProvider,
                    width: double.infinity,
                    fit: BoxFit.contain,
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
                    imageUrl: widget.movie['photo'] ?? '',
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
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    indicatorColor: const Color(0xFFFCC434),
                    labelColor: const Color(0xFFFCC434),
                    unselectedLabelColor: Colors.white70,
                    tabs: const [
                      Tab(text: 'Show Times'),
                      Tab(text: 'Movie Details'),
                    ],
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              // Show Times Tab
              _buildShowTimesTab(),

              // Movie Details Tab
              _buildMovieDetailsTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShowTimesTab() {
    return Consumer<GetHallProvider>(
      builder: (context, hallProvider, child) {
        if (hallProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFFCC434),
            ),
          );
        }

        if (hallProvider.error != null) {
          return Center(
            child: Text(
              hallProvider.error!,
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        if (hallProvider.halls.isEmpty) {
          return const Center(
            child: Text(
              'No show times available',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        // Build your show times list
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: hallProvider.halls.length,
          itemBuilder: (context, index) {
            final hall = hallProvider.halls[index];
            return _buildHallShowtimeCard(hall);
          },
        );
      },
    );
  }

  Widget _buildHallShowtimeCard(dynamic hall) {
    return Card(
      color: Colors.white12,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hall['name'] ?? 'Unknown Hall',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: (hall['showTimes'] as List?)?.map<Widget>((time) {
                return _buildShowTimeChip(time);
              }).toList() ??
                  [
                    const Text(
                      'No show times available',
                      style: TextStyle(color: Colors.white70),
                    )
                  ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShowTimeChip(String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFCC434).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        time,
        style: const TextStyle(
          color: Color(0xFFFCC434),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMovieDetailsTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Movie Title
            Text(
              widget.movie['title'] ?? 'Unknown Title',
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
                  widget.movie['language'] ?? 'Unknown',
                  Icons.language,
                ),
                const SizedBox(width: 8),
                _buildMetadataChip(
                  widget.movie['format'] != null
                      ? widget.movie['format'].join(', ')
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
              widget.movie['genre'] != null
                  ? widget.movie['genre'].join(', ')
                  : 'Unknown Genre',
            ),

            // Cast
            _buildDetailRow(
              'Cast',
              widget.movie['cast'] != null
                  ? widget.movie['cast'].join(', ')
                  : 'Unknown Cast',
            ),

            // Release Date
            _buildDetailRow(
              'Release Date',
              widget.movie['releaseDate'] ?? 'Unknown Date',
            ),

            // Description
            if (widget.movie['description'] != null) ...[
              const SizedBox(height: 16),
              _buildSectionTitle('Synopsis'),
              Text(
                widget.movie['description'],
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Reuse existing helper methods from the original implementation
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

// Custom SliverPersistentHeaderDelegate for TabBar
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.black87,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
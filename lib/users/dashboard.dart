import 'dart:convert';
import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:movie_booking_flutter_backend/provider/get_movie_provider.dart';
import 'package:movie_booking_flutter_backend/users/users_movie_details.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  int _currentNowShowingIndex = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchMovies();
    });
  }

  void _fetchMovies() {
    final movieProvider = Provider.of<GetMovieProvider>(context, listen: false);
    movieProvider.fetchMovies('Now Showing');
    movieProvider.fetchMovies('Upcoming');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Deep dark background
      body: SafeArea(
        child: RefreshIndicator(
          color: Colors.white,
          backgroundColor: const Color(0xFF1E1E1E),
          onRefresh: () async {
            _fetchMovies();
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(), // Add bounce effect
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverToBoxAdapter(child: _buildSearchBar()),
              SliverToBoxAdapter(child: _buildSectionTitle('Now Playing')),
              SliverToBoxAdapter(child: _buildNowShowingMovies()),
              SliverToBoxAdapter(child: _buildSectionTitle('Coming Soon')),
              SliverToBoxAdapter(child: _buildUpcomingMovies()),
              const SliverToBoxAdapter(child: SizedBox(height: 20)), // Add bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, Pujan 👋',
                style: TextStyle(
                  color: Colors.grey[300],
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Explore Movies',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  letterSpacing: 0.7,
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2C),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 6,
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                color: Colors.grey[300],
                size: 26,
              ),
              onPressed: () {
                // Implement notification logic
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 6,
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Search for movies...',
            hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
            prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 24),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(15),
          ),
          onChanged: (value) {
            // Implement search functionality
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          GestureDetector(
            onTap: () {
              // Implement view all functionality
            },
            child: Row(
              children: const [
                Text(
                  'View All',
                  style: TextStyle(
                    color: Color(0xFFFCC434),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 5),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFFFCC434),
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNowShowingMovies() {
    return Consumer<GetMovieProvider>(
      builder: (context, movieProvider, child) {
        if (movieProvider.isLoading) {
          return _buildNowShowingShimmer();
        }

        final nowShowingMovies = movieProvider.nowShowingMovies;

        if (nowShowingMovies.isEmpty) {
          return const Center(
            child: Text(
              'No movies available',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return CarouselSlider.builder(
          itemCount: nowShowingMovies.length,
          options: CarouselOptions(
            height: 470,
            viewportFraction: 0.65,
            enlargeCenterPage: true,
            enlargeFactor: 0.25,
            enableInfiniteScroll: true,
            autoPlay: false,
            onPageChanged: (index, reason) {
              setState(() {
                _currentNowShowingIndex = index;
              });
            },
          ),
          itemBuilder: (context, index, realIndex) {
            final movie = nowShowingMovies[index];
            return _buildNowShowingMovieCard(movie, index == _currentNowShowingIndex);
          },
        );
      },
    );
  }

  Widget _buildNowShowingMovieCard(dynamic movie, bool isFocused) {
    ImageProvider? imageProvider;
    try {
      if (movie['photo'] != null && movie['photo'] is String) {
        String base64Image = movie['photo'];
        if (base64Image.contains(',')) {
          base64Image = base64Image.split(',')[1];
        }
        final bytes = base64Decode(base64Image);
        imageProvider = MemoryImage(bytes);
      }
    } catch (e) {
      log('Error decoding base64 image: $e');
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserMovieDetail(movie: movie),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: isFocused ? 280 : 240,
        height: isFocused ? 400 : 350,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),

        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: imageProvider != null
                    ? Image(
                  image: imageProvider,
                  fit: BoxFit.cover,
                  width: double.infinity,
                )
                    : CachedNetworkImage(
                  imageUrl: movie['photo'] ?? '',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(color: Colors.white70),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Text(
                    movie['title'] ?? 'Unknown Title',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: isFocused ? FontWeight.bold : FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    movie['genre'] != null
                        ? movie['genre'].join(', ')
                        : 'Unknown Genre',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                      fontWeight: isFocused ? FontWeight.w500 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingMovies() {
    return Consumer<GetMovieProvider>(
      builder: (context, movieProvider, child) {
        if (movieProvider.isLoading) {
          return _buildUpcomingShimmer();
        }

        final upcomingMovies = movieProvider.upcomingMovies;

        if (upcomingMovies.isEmpty) {
          return const Center(
            child: Text(
              'No upcoming movies',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return SizedBox(
          height: 320,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: upcomingMovies.length,
            itemBuilder: (context, index) {
              final movie = upcomingMovies[index];
              return _buildUpcomingMovieCard(movie);
            },
          ),
        );
      },
    );
  }

  Widget _buildUpcomingMovieCard(dynamic movie) {
    ImageProvider? imageProvider;
    try {
      if (movie['photo'] != null && movie['photo'] is String) {
        String base64Image = movie['photo'];
        if (base64Image.contains(',')) {
          base64Image = base64Image.split(',')[1];
        }
        final bytes = base64Decode(base64Image);
        imageProvider = MemoryImage(bytes);
      }
    } catch (e) {
      log('Error decoding base64 image: $e');
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserMovieDetail(movie: movie),
          ),
        );
      },
      child: Container(
        height: 230,
        width: 180,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  imageProvider != null
                      ? Image(
                    image: imageProvider,
                    height: 230,
                    width: 180,
                    fit: BoxFit.cover,
                  )
                      : CachedNetworkImage(
                    imageUrl: movie['photo'] ?? '',
                    height: 230,
                    width: 180,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(color: Colors.white70),
                    ),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Coming Soon',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              movie['title'] ?? 'Unknown Title',
              style: const TextStyle(
                color: Color(0xFFFCC434),
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.movie_outlined, color: Colors.grey[400], size: 16),
                Text(
                  movie['genre'] != null
                      ? movie['genre'].join(', ')
                      : 'Unknown Genre',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.calendar_month_outlined, color: Colors.grey[400], size: 16),
                Text(
                  movie['releaseDate'] ?? 'No realease date',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Shimmer loading widgets
  Widget _buildNowShowingShimmer() {
    return CarouselSlider.builder(
        itemCount: 5,
        options: CarouselOptions(
        height: 450,
        viewportFraction: 0.7,
        enlargeCenterPage: true,
    ),
    itemBuilder: (context, index, realIndex) {
    return Container(
    width: 280,
    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.grey.shade900,
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade800,
        highlightColor: Colors.grey.shade700,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: Colors.grey.shade900,
          ),
        ),
      ),
    );
    },
    );
  }

  Widget _buildUpcomingShimmer() {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 180,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade800,
                  highlightColor: Colors.grey.shade700,
                  child: Container(
                    height: 230,
                    width: 180,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade800,
                  highlightColor: Colors.grey.shade700,
                  child: Container(
                    height: 20,
                    width: 150,
                    color: Colors.grey.shade900,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
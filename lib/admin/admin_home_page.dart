import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:movie_booking_flutter_backend/admin/hall_listing.dart';
import 'package:movie_booking_flutter_backend/admin/hall_with_movies.dart';
import 'package:movie_booking_flutter_backend/admin/movie_detail_page.dart';
import 'package:movie_booking_flutter_backend/provider/get_movie_provider.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movie_booking_flutter_backend/admin/create_movie.dart';
import 'package:movie_booking_flutter_backend/admin/users_page.dart';
import 'package:movie_booking_flutter_backend/auth/login.dart';
import 'package:shimmer/shimmer.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Fetch initial movies when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchMoviesForCurrentTab();
    });

    // Add listener to fetch movies when tab changes
    _tabController.addListener(_handleTabChange);
  }

  void _fetchMoviesForCurrentTab() {
    final movieProvider = Provider.of<GetMovieProvider>(context, listen: false);

    // Fetch movies based on the current tab
    if (_tabController.index == 0) {
      movieProvider.fetchMovies('Now Showing');
    } else {
      movieProvider.fetchMovies('Upcoming');
    }
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      _fetchMoviesForCurrentTab();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFFCC434)),
        title: const Text(
          'Movies',
          style: TextStyle(
            color: Color(0xFFFCC434),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFFCC434)),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white24,
          ),
          labelColor: const Color(0xFFFCC434),
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(
              child: Text(
                'Now Showing',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Tab(
              child: Text(
                'Upcoming',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: buildDrawer(context),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMovieTab(isNowShowing: true),
          _buildMovieTab(isNowShowing: false),
        ],
      ),
    );
  }

  Widget _buildMovieTab({required bool isNowShowing}) {
    return Consumer<GetMovieProvider>(
      builder: (context, movieProvider, child) {
        if (movieProvider.isLoading) {
          return const MovieShimmerGrid();
        }

        if (movieProvider.error.isNotEmpty) {
          return Center(
            child: Text(
              movieProvider.error,
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        final movies = isNowShowing
            ? movieProvider.nowShowingMovies
            : movieProvider.upcomingMovies;

        return LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
            return NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (overscroll) {
                overscroll.disallowIndicator();
                return false;
              },
              child: GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 0.6,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  return _buildMovieCard(movies[index]);
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMovieCard(dynamic movie) {
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
        log('Error decoding base64 image: $e');
        imageProvider = null;
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailsPage(movie: movie),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey[900],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(15)),
              child: imageProvider != null
                  ? Image(
                image: imageProvider,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 250,
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
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white70,
                  ),
                ),
                errorWidget: (context, url, error) =>
                const Icon(Icons.error),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      movie['title'] ?? 'Unknown Title',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    // Genre with overflow handling
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final genreText = movie['genre'] != null
                            ? movie['genre'].join(', ')
                            : 'Unknown Genre';
                        return Text(
                          genreText,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
                    const SizedBox(height: 5),
                    // Cast with overflow handling
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final castText = movie['cast'] != null
                            ? movie['cast'].join(', ')
                            : 'Unknown Cast';
                        return Text(
                          castText,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black87,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.white12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Admin Dashboard',
                  style: TextStyle(
                    color: Color(0xFFFCC434),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Welcome, Admin!',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            icon: Icons.movie_creation_outlined,
            title: 'Movies',
            onTap: () => navigateToPage(context, const CreateMovies()),
          ),
          _buildDrawerItem(
            icon: Icons.other_houses,
            title: 'Add Hall',
            onTap: () => navigateToPage(context, const HallListing()),
          ),
          _buildDrawerItem(
            icon: Icons.local_movies_rounded,
            title: 'Movies in Hall',
            onTap: () => navigateToPage(context, const HallWithMovies()),
          ),
          _buildDrawerItem(
            icon: Icons.person,
            title: 'Users',
            onTap: () => navigateToPage(context, const UsersPage()),
          ),
          const Divider(color: Colors.white24),
          _buildDrawerItem(
            icon: Icons.settings,
            title: 'Settings',
            onTap: () {
              // TODO: Add settings page navigation
            },
          ),
          _buildDrawerItem(
            icon: Icons.info,
            title: 'About',
            onTap: () {
              // TODO: Add about page navigation
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Color(0xFFFCC434))),
      onTap: onTap,
    );
  }

  void navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}
class MovieShimmerGrid extends StatelessWidget {
  const MovieShimmerGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive grid count
        int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.65,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: crossAxisCount * 2, // Adjust item count based on grid
          itemBuilder: (context, index) {
            return _buildShimmerMovieCard();
          },
        );
      },
    );
  }

  Widget _buildShimmerMovieCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade800,
            Colors.grey.shade900,
          ],
        ),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade700,
        highlightColor: Colors.grey.shade600,
        period: const Duration(milliseconds: 1500),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Placeholder
                  Container(
                    height: 20,
                    width: double.infinity,
                    color: Colors.black26,
                    margin: const EdgeInsets.only(bottom: 8),
                  ),

                  // Genre Placeholder
                  Container(
                    height: 15,
                    width: 120,
                    color: Colors.black26,
                    margin: const EdgeInsets.only(bottom: 6),
                  ),

                  // Cast Placeholder
                  Container(
                    height: 15,
                    width: 180,
                    color: Colors.black26,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
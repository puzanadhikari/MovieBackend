import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movie_booking_flutter_backend/users/seat_selection.dart';
import 'package:provider/provider.dart';
import 'package:movie_booking_flutter_backend/provider/get_hall_provider.dart';

class UserMovieDetail extends StatefulWidget {
  final dynamic movie;

  const UserMovieDetail({Key? key, required this.movie}) : super(key: key);

  @override
  _UserMovieDetailState createState() => _UserMovieDetailState();
}

class _UserMovieDetailState extends State<UserMovieDetail>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  dynamic selectedHall;
  String? selectedDate;
  String? selectedShowTime;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GetHallProvider>(context, listen: false)
          .fetchHalls()
          .then((_) => _setDefaultSelections());
    });
  }

  void _setDefaultSelections() {
    final hallProvider = Provider.of<GetHallProvider>(context, listen: false);
    if (hallProvider.halls.isNotEmpty) {
      setState(() {
        selectedHall = hallProvider.halls.first;
        selectedDate = _getUniqueAndSortedDates(selectedHall).first;
      });
    }
  }

  List<String> _getUniqueAndSortedDates(dynamic hall) {
    Set<String> uniqueDates = {};
    for (var audi in hall['audi']) {
      for (var dateTime in audi['dateTime']) {
        uniqueDates.add(dateTime['date']);
      }
    }
    return uniqueDates.toList()..sort();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  ImageProvider? _getImageProvider() {
    if (widget.movie['photo'] != null && widget.movie['photo'] is String) {
      try {
        String base64Image = widget.movie['photo'].contains(',')
            ? widget.movie['photo'].split(',')[1]
            : widget.movie['photo'];
        return MemoryImage(base64Decode(base64Image));
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = _getImageProvider();
    return Scaffold(
      backgroundColor: Colors.black87,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildAppBar(context, imageProvider),
          _buildTabBar(),
        ],
        body: _buildTabBarView(),
      ),
    );
  }

  SliverAppBar _buildAppBar(
      BuildContext context, ImageProvider? imageProvider) {
    return SliverAppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFFCC434)),
        onPressed: () => Navigator.pop(context),
      ),
      expandedHeight: 250,
      floating: false,
      pinned: true,
      backgroundColor: Colors.black87,
      flexibleSpace: FlexibleSpaceBar(
        background: imageProvider != null
            ? Image(image: imageProvider, fit: BoxFit.cover)
            : CachedNetworkImage(
                imageUrl: widget.movie['photo'] ?? '',
                fit: BoxFit.cover,
                placeholder: (_, __) => const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFCC434)),
                ),
              ),
      ),
    );
  }

  SliverPersistentHeader _buildTabBar() {
    return SliverPersistentHeader(
      pinned: true,
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
    );
  }

  TabBarView _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildShowTimesTab(),
        _buildMovieDetailsTab(),
      ],
    );
  }

  Widget _buildShowTimesTab() {
    return Consumer<GetHallProvider>(
      builder: (context, hallProvider, _) {
        if (hallProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFCC434)),
          );
        }

        if (hallProvider.error != null) {
          return Center(
              child: Text(hallProvider.error!,
                  style: const TextStyle(color: Colors.white)));
        }

        if (hallProvider.halls.isEmpty) {
          return const Center(
              child: Text('No show times available',
                  style: TextStyle(color: Colors.white)));
        }

        return widget.movie['status'] == "Now Showing" ? Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHallDropdown(hallProvider),
              const SizedBox(height: 16),
              if (selectedHall != null) ...[
                const Text('Select Date',
                    style: TextStyle(
                        color: Color(0xFFFCC434),
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                _buildDateSelection(),
              ],
              const SizedBox(height: 16),
              if (selectedDate != null) _buildShowTimes(),
            ],
          ),
        ): Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.upcoming,
                  color: const Color(0xFFFCC434),
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  'Coming Soon',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Stay tuned for show times',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHallDropdown(GetHallProvider hallProvider) {
    return DropdownButtonFormField<dynamic>(
      value: selectedHall,
      decoration: InputDecoration(
        fillColor: Colors.white12,
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color(0xFFFCC434).withOpacity(0.5)),
        ),
      ),
      hint: const Text('Select Cinema Hall', style: TextStyle(color: Colors.white70)),
      dropdownColor: Colors.black87,
      isExpanded: true,
      items: hallProvider.halls.map((hall) {
        return DropdownMenuItem(
          value: hall,
          child: Text(hall['name'] ?? 'Unknown Hall',
              style: const TextStyle(color: Colors.white)),
        );
      }).toList(),
      onChanged: (selectedHall) {
        setState(() {
          this.selectedHall = selectedHall;
          selectedDate = _getUniqueAndSortedDates(selectedHall).first;
        });
      },
    );
  }

  Widget _buildDateSelection() {
    final dates = _getUniqueAndSortedDates(selectedHall);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: dates.map((date) {
              DateTime parsedDate = DateTime.parse(date);
              bool isSelected = selectedDate == date;

              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: GestureDetector(
                  onTap: () => setState(() => selectedDate = date),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFCC434).withOpacity(0.2)
                          : Colors.white12,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFFCC434) : Colors.white24,
                        width: 2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFFFCC434).withOpacity(0.3),
                                blurRadius: 10,
                                spreadRadius: 2,
                              )
                            ]
                          : [],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getWeekday(parsedDate.weekday),
                          style: TextStyle(
                            color:
                                isSelected ? const Color(0xFFFCC434) : Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          parsedDate.day.toString(),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getMonth(parsedDate.month),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildShowTimes() {
    final showTimes = _getShowTimesForSelectedDateAndHall();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Shows',
          style: TextStyle(
            color: Color(0xFFFCC434),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            children: showTimes.map((showTime) {
              return GestureDetector(
                onTap: () {
                  setState(() => selectedShowTime = showTime['time']);
               log("Selected show time: ${showTime['time']}, "
                   "hall: ${selectedHall['name']}, date: ${selectedDate}"
                   ", audi: ${showTime['audiName']}, capacity: ${showTime['capacity']}");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SeatSelectionPage(
                        movieDetails: {
                          'movie': widget.movie,
                          'hall': selectedHall['name'],
                          'date': selectedDate,
                          'time': showTime['time'],
                          'audi': showTime['audiName'],
                          'capacity': showTime['capacity']
                        },
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFCC434).withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        showTime['audiName'] ?? 'Audi',
                        style: TextStyle(
                          color: const Color(0xFFFCC434).withOpacity(0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        showTime['time']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  List<Map<String, String>> _getShowTimesForSelectedDateAndHall() {
    List<Map<String, String>> showTimes = [];
    for (var audi in selectedHall['audi']) {
      for (var dateTime in audi['dateTime']) {
        if (dateTime['date'] == selectedDate) {
          showTimes.add({'time': dateTime['time'], 'audiName': audi['name'],
          'capacity': audi['capacity'].toString()});
        }
      }
    }
    return showTimes.toSet().toList()
      ..sort((a, b) => a['time']!.compareTo(b['time']!));
  }

  String _getWeekday(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  String _getMonth(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
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

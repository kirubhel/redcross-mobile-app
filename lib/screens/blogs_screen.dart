import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/language_provider.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';
import '../utils/app_theme.dart';

class BlogsScreen extends StatefulWidget {
  const BlogsScreen({super.key});

  @override
  State<BlogsScreen> createState() => _BlogsScreenState();
}

class _BlogsScreenState extends State<BlogsScreen> {
  List<dynamic> _blogs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBlogs();
  }

  // Sample demo blogs
  List<dynamic> _getSampleBlogs() {
    return [
      {
        '_id': '1',
        'title': 'Outstanding Volunteer of the Year 2024',
        'description':
            'We are thrilled to recognize our dedicated volunteer who has contributed over 500 hours of service this year, helping communities in need across Ethiopia.',
        'user': {'name': 'Alemayehu Bekele', 'email': 'alemayehu@example.com'},
        'issuedDate':
            DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'metrics': {'hoursVolunteered': 520, 'activitiesCompleted': 45},
        'imageUrl': 'assets/images/slide4-scaled.jpg',
      },
      {
        '_id': '2',
        'title': 'Community Health Champion Award',
        'description':
            'Recognizing exceptional efforts in providing health services to rural communities. This volunteer conducted 30 health awareness campaigns reaching over 2,000 people.',
        'user': {'name': 'Meron Tesfaye', 'email': 'meron@example.com'},
        'issuedDate':
            DateTime.now().subtract(const Duration(days: 12)).toIso8601String(),
        'metrics': {'hoursVolunteered': 380, 'activitiesCompleted': 30},
        'imageUrl': 'assets/images/slide5-scaled.jpg',
      },
      {
        '_id': '3',
        'title': 'Disaster Response Hero',
        'description':
            'In recognition of outstanding service during recent natural disasters. This volunteer was instrumental in coordinating emergency relief efforts, helping over 500 families.',
        'user': {'name': 'Yonas Tadesse', 'email': 'yonas@example.com'},
        'issuedDate':
            DateTime.now().subtract(const Duration(days: 20)).toIso8601String(),
        'metrics': {'hoursVolunteered': 450, 'activitiesCompleted': 38},
        'imageUrl': 'assets/images/slide3-scaled.png',
      },
      {
        '_id': '4',
        'title': 'Youth Leadership Excellence',
        'description':
            'Celebrating young volunteers who have shown exceptional leadership in organizing youth programs and community engagement activities.',
        'user': {'name': 'Sara Mohammed', 'email': 'sara@example.com'},
        'issuedDate':
            DateTime.now().subtract(const Duration(days: 8)).toIso8601String(),
        'metrics': {'hoursVolunteered': 320, 'activitiesCompleted': 28},
        'imageUrl': 'assets/images/slide4-scaled.jpg',
      },
    ];
  }

  Future<void> _loadBlogs() async {
    // Simulate API delay for demo
    await Future.delayed(const Duration(milliseconds: 300));

    // Always use sample data for demo
    if (mounted) {
      setState(() {
        _blogs = _getSampleBlogs();
        _isLoading = false;
      });
    }

    // Uncomment below to try API first, then fallback to sample data
    /*
    try {
      final result = await ApiService.get(
        ApiConfig.recognitionUrl,
        queryParams: {'featured': 'true'},
      );
      if (result['success'] == true &&
          mounted &&
          (result['data']?['items'] ?? []).isNotEmpty) {
        setState(() {
          _blogs = result['data']['items'] ?? [];
          _isLoading = false;
        });
      } else {
        // Use sample data for demo
        setState(() {
          _blogs = _getSampleBlogs();
          _isLoading = false;
        });
      }
    } catch (e) {
      // Use sample data for demo
      setState(() {
        _blogs = _getSampleBlogs();
        _isLoading = false;
      });
    }
    */
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isAmharic = languageProvider.currentLanguage == 'am';
    final isOromo = languageProvider.currentLanguage == 'or';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isAmharic
              ? 'መሸለም ብሎግ'
              : isOromo
                  ? 'Blog Mallattoo'
                  : 'Recognition Blog',
        ),
        backgroundColor: AppTheme.primaryRed,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadBlogs,
              child: _blogs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.emoji_events,
                              size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            isAmharic
                                ? 'እስካሁን ምንም መሸለም የለም'
                                : isOromo
                                    ? 'Mallattoo hin jiru'
                                    : 'No recognitions yet',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _blogs.length,
                      itemBuilder: (context, index) {
                        final blog = _blogs[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header with image or gradient
                              Container(
                                height: 180,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                ),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // Image or gradient background
                                    blog['imageUrl'] != null
                                        ? ClipRRect(
                                            borderRadius:
                                                const BorderRadius.only(
                                              topLeft: Radius.circular(16),
                                              topRight: Radius.circular(16),
                                            ),
                                            child: Image.asset(
                                              blog['imageUrl'],
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        AppTheme.primaryRed,
                                                        AppTheme.darkRed
                                                      ],
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                    ),
                                                  ),
                                                  child: const Center(
                                                    child: Icon(
                                                      Icons.emoji_events,
                                                      color: Colors.white,
                                                      size: 60,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          )
                                        : Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  AppTheme.primaryRed,
                                                  AppTheme.darkRed
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                            ),
                                            child: const Center(
                                              child: Icon(
                                                Icons.emoji_events,
                                                color: Colors.white,
                                                size: 60,
                                              ),
                                            ),
                                          ),
                                    // Dark overlay for text readability
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.3),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 12,
                                      right: 12,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.9),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: const Text(
                                          'FEATURED',
                                          style: TextStyle(
                                            color: AppTheme.primaryRed,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Content
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      blog['title'] ?? 'Recognition',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      blog['description'] ?? '',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                        height: 1.5,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 16),
                                    // User info and date
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: AppTheme.primaryRed,
                                          child: Text(
                                            blog['user']?['name']?[0]
                                                    ?.toUpperCase() ??
                                                'U',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                blog['user']?['name'] ??
                                                    'Anonymous',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              if (blog['issuedDate'] != null)
                                                Text(
                                                  DateFormat('MMM dd, yyyy')
                                                      .format(DateTime.parse(
                                                          blog['issuedDate'])),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Metrics if available
                                    if (blog['metrics'] != null) ...[
                                      const SizedBox(height: 16),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[50],
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            if (blog['metrics']
                                                    ['hoursVolunteered'] !=
                                                null)
                                              _MetricItem(
                                                icon: Icons.access_time,
                                                value:
                                                    '${blog['metrics']['hoursVolunteered']}',
                                                label: isAmharic
                                                    ? 'ሰዓታት'
                                                    : isOromo
                                                        ? 'Sa\'a'
                                                        : 'Hours',
                                              ),
                                            if (blog['metrics']
                                                    ['activitiesCompleted'] !=
                                                null)
                                              _MetricItem(
                                                icon: Icons.check_circle,
                                                value:
                                                    '${blog['metrics']['activitiesCompleted']}',
                                                label: isAmharic
                                                    ? 'እንቅስቃሴዎች'
                                                    : isOromo
                                                        ? 'Hojiiwwan'
                                                        : 'Activities',
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _MetricItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryRed, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryRed,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

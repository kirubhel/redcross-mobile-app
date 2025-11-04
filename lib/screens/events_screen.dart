import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/language_provider.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';
import '../utils/app_theme.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List<dynamic> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  // Sample demo events
  List<dynamic> _getSampleEvents() {
    return [
      {
        '_id': '1',
        'title': 'Community Health Fair 2024',
        'description':
            'Join us for a comprehensive health fair offering free medical checkups, vaccinations, and health education workshops for the community.',
        'date': DateTime.now().add(const Duration(days: 5)).toIso8601String(),
        'location': 'Addis Ababa, Meskel Square',
        'imageUrl': 'assets/images/slide4-scaled.jpg',
      },
      {
        '_id': '2',
        'title': 'Blood Donation Drive',
        'description':
            'Help save lives! We need your support for our monthly blood donation drive. All donors receive refreshments and a certificate of appreciation.',
        'date': DateTime.now().add(const Duration(days: 10)).toIso8601String(),
        'location': 'Red Cross Headquarters, Addis Ababa',
        'imageUrl': 'assets/images/slide5-scaled.jpg',
      },
      {
        '_id': '3',
        'title': 'Disaster Preparedness Training',
        'description':
            'Learn essential skills for disaster response and community resilience. This training covers first aid, emergency planning, and evacuation procedures.',
        'date': DateTime.now().add(const Duration(days: 15)).toIso8601String(),
        'location': 'Regional Office, Dire Dawa',
        'imageUrl': 'assets/images/slide3-scaled.png',
      },
      {
        '_id': '4',
        'title': 'Youth Volunteer Summit',
        'description':
            'Annual gathering for young volunteers to network, share experiences, and participate in leadership workshops. Open to all youth volunteers.',
        'date': DateTime.now().add(const Duration(days: 20)).toIso8601String(),
        'location': 'Hawassa, Sidama Region',
        'imageUrl': 'assets/images/slide4-scaled.jpg',
      },
      {
        '_id': '5',
        'title': 'Clean Water Initiative Launch',
        'description':
            'Help us launch our new clean water initiative in rural communities. Volunteers needed for water point installation and hygiene education.',
        'date': DateTime.now().add(const Duration(days: 25)).toIso8601String(),
        'location': 'Gondar, Amhara Region',
        'imageUrl': 'assets/images/slide5-scaled.jpg',
      },
    ];
  }

  Future<void> _loadEvents() async {
    // Simulate API delay for demo
    await Future.delayed(const Duration(milliseconds: 300));

    // Always use sample data for demo
    if (mounted) {
      setState(() {
        _events = _getSampleEvents();
        _isLoading = false;
      });
    }

    // Uncomment below to try API first, then fallback to sample data
    /*
    try {
      final result = await ApiService.get(ApiConfig.eventsUrl);
      if (result['success'] == true &&
          mounted &&
          (result['data']?['items'] ?? result['items'] ?? []).isNotEmpty) {
        setState(() {
          _events = result['data']?['items'] ?? result['items'] ?? [];
          _isLoading = false;
        });
      } else {
        // Use sample data for demo
        setState(() {
          _events = _getSampleEvents();
          _isLoading = false;
        });
      }
    } catch (e) {
      // Use sample data for demo
      setState(() {
        _events = _getSampleEvents();
        _isLoading = false;
      });
    }
    */
  }

  Future<void> _joinEvent(String eventId) async {
    try {
      final result = await ApiService.post(
        '${ApiConfig.apiUrl}/register',
        {'type': 'event', 'refId': eventId},
      );
      if (result['success'] == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully joined event!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to join: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
              ? 'በዓላት'
              : isOromo
                  ? 'Hojiiwwan'
                  : 'Events',
        ),
        backgroundColor: AppTheme.primaryRed,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadEvents,
              child: _events.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.event, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            isAmharic
                                ? 'እስካሁን ምንም በዓላት የሉም'
                                : isOromo
                                    ? 'Hojiiwwan hin jiru'
                                    : 'No events available',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _events.length,
                      itemBuilder: (context, index) {
                        final event = _events[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: InkWell(
                            onTap: () {
                              // Show event details
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Event header with image
                                Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                    ),
                                  ),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      // Background image or gradient
                                      event['imageUrl'] != null
                                          ? ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(16),
                                                topRight: Radius.circular(16),
                                              ),
                                              child: Image.asset(
                                                event['imageUrl'],
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Container(
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          AppTheme.primaryRed,
                                                          AppTheme.darkRed
                                                        ],
                                                        begin:
                                                            Alignment.topLeft,
                                                        end: Alignment
                                                            .bottomRight,
                                                      ),
                                                    ),
                                                    child: const Center(
                                                      child: Icon(
                                                        Icons.event,
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
                                                  Icons.event,
                                                  color: Colors.white,
                                                  size: 60,
                                                ),
                                              ),
                                            ),
                                      // Dark overlay
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black.withOpacity(0.6),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Content overlay
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                event['title'] ?? 'Event',
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  shadows: [
                                                    Shadow(
                                                      offset: Offset(1, 1),
                                                      blurRadius: 3,
                                                      color: Colors.black54,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (event['date'] != null) ...[
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.calendar_today,
                                                      color: Colors.white,
                                                      size: 16,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      DateFormat('MMM dd, yyyy')
                                                          .format(
                                                              DateTime.parse(
                                                                  event[
                                                                      'date'])),
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.white
                                                            .withOpacity(0.95),
                                                        shadows: const [
                                                          Shadow(
                                                            offset:
                                                                Offset(1, 1),
                                                            blurRadius: 2,
                                                            color:
                                                                Colors.black54,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Event content
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (event['description'] != null)
                                        Text(
                                          event['description'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                            height: 1.5,
                                          ),
                                        ),
                                      if (event['location'] != null) ...[
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Icon(Icons.location_on,
                                                size: 16,
                                                color: Colors.grey[600]),
                                            const SizedBox(width: 4),
                                            Text(
                                              event['location'],
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: () => _joinEvent(
                                              event['_id'] ?? event['id']),
                                          icon: const Icon(Icons.person_add,
                                              size: 18),
                                          label: Text(
                                            isAmharic
                                                ? 'በፈቃደኛ ይሁኑ'
                                                : isOromo
                                                    ? 'Hawwaasa ta\'i'
                                                    : 'Volunteer',
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppTheme.primaryRed,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}

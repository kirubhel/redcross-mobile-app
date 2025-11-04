import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import '../../utils/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      final result = await ApiService.get(ApiConfig.reportsUrl + '/dashboard');
      if (result['success'] == true && mounted) {
        setState(() {
          _stats = result['data'];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final isAmharic = languageProvider.currentLanguage == 'am';
    final isOromo = languageProvider.currentLanguage == 'or';

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadDashboard,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome card
            Card(
              color: AppTheme.primaryRed,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAmharic
                          ? 'እንኳን ደህና መጡ ${user?.name ?? ""}'
                          : isOromo
                              ? 'Baga nagaan dhufte ${user?.name ?? ""}'
                              : 'Welcome, ${user?.name ?? ""}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isAmharic
                          ? 'የኢትዮጵያ ቀይ መስቀል ማኅበር'
                          : isOromo
                              ? 'Red Cross Ethiopia'
                              : 'Ethiopian Red Cross Society',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Stats grid
            if (_stats != null) ...[
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _StatCard(
                    title: isAmharic ? 'እንቅስቃሴዎች' : isOromo ? 'Hojiiwwan' : 'Activities',
                    value: '${_stats!['totalActivities'] ?? 0}',
                    icon: Icons.work,
                    color: Colors.blue,
                  ),
                  _StatCard(
                    title: isAmharic ? 'ስልጠናዎች' : isOromo ? 'Ogeessisa' : 'Trainings',
                    value: '${_stats!['totalTrainings'] ?? 0}',
                    icon: Icons.school,
                    color: Colors.green,
                  ),
                  _StatCard(
                    title: isAmharic ? 'በዓላት' : isOromo ? 'Hojiiwwan' : 'Events',
                    value: '${_stats!['totalEvents'] ?? 0}',
                    icon: Icons.event,
                    color: Colors.orange,
                  ),
                  _StatCard(
                    title: isAmharic ? 'መሸለም' : isOromo ? 'Mallattoo' : 'Recognition',
                    value: '${_stats!['totalRecognition'] ?? 0}',
                    icon: Icons.emoji_events,
                    color: Colors.purple,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../auth/login_screen.dart';
import 'dashboard_screen.dart';
import 'events_screen.dart';
import 'hubs_screen.dart';
import 'activities_screen.dart';
import 'training_screen.dart';
import 'recognition_screen.dart';
import 'payments_screen.dart';
import 'profile_screen.dart';
import 'communication_screen.dart';
import 'reports_screen.dart';
import '../../utils/app_theme.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const EventsScreen(),
    const ActivitiesScreen(),
    const TrainingScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final isAdmin = user?.isAdmin ?? false;
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isAmharic = languageProvider.currentLanguage == 'am';
    final isOromo = languageProvider.currentLanguage == 'or';

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: AppTheme.primaryRed),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Text(
                      user?.name[0].toUpperCase() ?? 'U',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryRed,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?.name ?? 'User',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    user?.role ?? '',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: Text(isAmharic
                  ? 'ዳሽቦርድ'
                  : isOromo
                      ? 'Daashibooridii'
                      : 'Dashboard'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.event),
              title: Text(isAmharic
                  ? 'በዓላት'
                  : isOromo
                      ? 'Hojiiwwan'
                      : 'Events'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const EventsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.hub),
              title: Text(isAmharic
                  ? 'ሃብሎች'
                  : isOromo
                      ? 'Habilli'
                      : 'Hubs'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const HubsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.work),
              title: Text(isAmharic
                  ? 'የሥራ እንቅስቃሴዎች'
                  : isOromo
                      ? 'Hojiiwwan'
                      : 'Activities'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.school),
              title: Text(isAmharic
                  ? 'ስልጠና'
                  : isOromo
                      ? 'Ogeessisa'
                      : 'Training'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 3);
              },
            ),
            ListTile(
              leading: const Icon(Icons.emoji_events),
              title: Text(isAmharic
                  ? 'መሸለም'
                  : isOromo
                      ? 'Mallattoo'
                      : 'Recognition'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const RecognitionScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title: Text(isAmharic
                  ? 'ክፍያዎች'
                  : isOromo
                      ? 'Maallaqa'
                      : 'Payments'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const PaymentsScreen()));
              },
            ),
            if (isAdmin) ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.message),
                title: Text(isAmharic
                    ? 'መግባባር'
                    : isOromo
                        ? 'Waliin haasawa'
                        : 'Communication'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CommunicationScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.analytics),
                title: Text(isAmharic
                    ? 'ሪፖርቶች'
                    : isOromo
                        ? 'Ripooriti'
                        : 'Reports'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ReportsScreen()));
                },
              ),
            ],
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(isAmharic
                  ? 'መገለጫ'
                  : isOromo
                      ? 'Odeeffannoo'
                      : 'Profile'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 4);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(isAmharic
                  ? 'ውጣ'
                  : isOromo
                      ? 'Ba\'i'
                      : 'Logout'),
              onTap: () async {
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text(
          _currentIndex == 0
              ? (isAmharic
                  ? 'ዳሽቦርድ'
                  : isOromo
                      ? 'Daashibooridii'
                      : 'Dashboard')
              : _currentIndex == 2
                  ? (isAmharic
                      ? 'የሥራ እንቅስቃሴዎች'
                      : isOromo
                          ? 'Hojiiwwan'
                          : 'Activities')
                  : _currentIndex == 3
                      ? (isAmharic
                          ? 'ስልጠና'
                          : isOromo
                              ? 'Ogeessisa'
                              : 'Training')
                      : (isAmharic
                          ? 'መገለጫ'
                          : isOromo
                              ? 'Odeeffannoo'
                              : 'Profile'),
        ),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryRed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard),
            label: isAmharic
                ? 'ዳሽቦርድ'
                : isOromo
                    ? 'Daashibooridii'
                    : 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.event),
            label: isAmharic
                ? 'በዓላት'
                : isOromo
                    ? 'Hojiiwwan'
                    : 'Events',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.work),
            label: isAmharic
                ? 'እንቅስቃሴዎች'
                : isOromo
                    ? 'Hojiiwwan'
                    : 'Activities',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.school),
            label: isAmharic
                ? 'ስልጠና'
                : isOromo
                    ? 'Ogeessisa'
                    : 'Training',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: isAmharic
                ? 'መገለጫ'
                : isOromo
                    ? 'Odeeffannoo'
                    : 'Profile',
          ),
        ],
      ),
    );
  }
}

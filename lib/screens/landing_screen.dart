import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';
import '../utils/app_theme.dart';
import 'auth/login_screen.dart';
import 'donation_screen.dart';
import 'register/register_screen.dart';
import 'hub_request_screen.dart';
import 'blogs_screen.dart';
import 'events_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  int _currentSlide = 0;
  int _currentIndex = 0;
  List<dynamic> _blogs = [];
  PageController _pageController = PageController();
  final PageController _bottomNavController = PageController();

  final List<String> _slides = [
    'assets/images/slide4-scaled.jpg',
    'assets/images/slide5-scaled.jpg',
    'assets/images/slide3-scaled.png',
  ];

  final List<Map<String, String>> _slideTexts = [
    {
      'title_en': 'WE LIVE FOR HUMANITY!',
      'title_am': 'ለሰብዓዊነት እንኖራለን!',
      'title_or': 'Jireenyaf jiraanna!',
      'subtitle_en': 'Join us in making a difference',
      'subtitle_am': 'ለውጥ ለማምጣት እኛን ይቀላቀሉ',
      'subtitle_or': 'Fooyya\'i godhachuuf nu waliin maaqaa',
    },
    {
      'title_en': 'SERVING COMMUNITIES',
      'title_am': 'ማህበረሰቦችን ማገልገል',
      'title_or': 'Hawaasota tajaajila',
      'subtitle_en': 'Together we can make a lasting impact',
      'subtitle_am': 'አንድ ላይ ዘላቂ ለውጥ ማምጣት እንችላለን',
      'subtitle_or': 'Waliin jijjiiramaa dhaamsaa taasisuu danda\'na',
    },
    {
      'title_en': 'VOLUNTEER WITH US',
      'title_am': 'እኛን ይቀላቀሉ',
      'title_or': 'Nu waliin maaqaa',
      'subtitle_en': 'Be part of the change',
      'subtitle_am': 'የለውጡ አካል ይሁኑ',
      'subtitle_or': 'Jijjiiramaa keessatti hirmaadhaa',
    },
  ];

  final List<Map<String, dynamic>> _stats = [
    {'number': '6.1M+', 'label': 'Members', 'icon': '👥'},
    {'number': '50K+', 'label': 'Volunteers', 'icon': '🤝'},
    {'number': '444', 'label': 'Ambulances', 'icon': '🚑'},
    {'number': '75', 'label': 'Essential Drug Program', 'icon': '💊'},
  ];

  @override
  void initState() {
    super.initState();
    _loadBlogs();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bottomNavController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _pageController.hasClients) {
        setState(() {
          _currentSlide = (_currentSlide + 1) % _slides.length;
        });
        _pageController.animateToPage(
          _currentSlide,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _startAutoSlide();
      }
    });
  }

  Future<void> _loadBlogs() async {
    try {
      final result = await ApiService.get(
        ApiConfig.recognitionUrl,
        queryParams: {'featured': 'true'},
      );
      if (result['success'] == true && mounted) {
        setState(() {
          _blogs = result['data']['items'] ?? [];
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isAmharic = languageProvider.currentLanguage == 'am';
    final isOromo = languageProvider.currentLanguage == 'or';

    return Scaffold(
      body: PageView(
        controller: _bottomNavController,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        children: [
          _buildHomePage(isAmharic, isOromo),
          const BlogsScreen(),
          const EventsScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
            _bottomNavController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          selectedItemColor: AppTheme.primaryRed,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: isAmharic
                  ? 'መነሻ'
                  : isOromo
                      ? 'Mana'
                      : 'Home',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.emoji_events),
              label: isAmharic
                  ? 'ብሎግ'
                  : isOromo
                      ? 'Blog'
                      : 'Blogs',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.event),
              label: isAmharic
                  ? 'በዓላት'
                  : isOromo
                      ? 'Hojiiwwan'
                      : 'Events',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomePage(bool isAmharic, bool isOromo) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 0,
                floating: true,
                pinned: true,
                backgroundColor: AppTheme.primaryRed,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/logo.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.favorite,
                            color: AppTheme.primaryRed, size: 20);
                      },
                    ),
                  ),
                ),
                title: Text(
                  isAmharic
                      ? 'የኢትዮጵያ ቀይ መስቀል'
                      : isOromo
                          ? 'Red Cross Ethiopia'
                          : 'Ethiopian Red Cross',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                actions: [
                  // Language selector
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.language, color: Colors.white),
                    onSelected: (value) {
                      languageProvider.setLanguage(value);
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'en',
                        child: Row(
                          children: [
                            if (languageProvider.currentLanguage == 'en')
                              const Icon(Icons.check,
                                  color: AppTheme.primaryRed),
                            const SizedBox(width: 8),
                            const Text('English'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'am',
                        child: Row(
                          children: [
                            if (languageProvider.currentLanguage == 'am')
                              const Icon(Icons.check,
                                  color: AppTheme.primaryRed),
                            const SizedBox(width: 8),
                            const Text('አማርኛ'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'or',
                        child: Row(
                          children: [
                            if (languageProvider.currentLanguage == 'or')
                              const Icon(Icons.check,
                                  color: AppTheme.primaryRed),
                            const SizedBox(width: 8),
                            const Text('Oromiffa'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.login),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                  ),
                ],
              ),

              // Hero Section with Image Carousel
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 500,
                  child: Stack(
                    children: [
                      // Image Carousel
                      PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() => _currentSlide = index);
                        },
                        itemCount: _slides.length,
                        itemBuilder: (context, index) {
                          final slideText = _slideTexts[index];
                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                _slides[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: AppTheme.primaryRed,
                                    child: const Center(
                                      child: Icon(Icons.image,
                                          size: 100, color: Colors.white),
                                    ),
                                  );
                                },
                              ),
                              // Dark overlay
                              Container(
                                color: Colors.black.withOpacity(0.4),
                              ),
                              // Slide text overlay - positioned at top
                              Positioned(
                                top: 80,
                                left: 0,
                                right: 0,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        isAmharic
                                            ? slideText['title_am'] ?? ''
                                            : isOromo
                                                ? slideText['title_or'] ?? ''
                                                : slideText['title_en'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          shadows: [
                                            Shadow(
                                              offset: Offset(2, 2),
                                              blurRadius: 4,
                                              color: Colors.black54,
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        isAmharic
                                            ? slideText['subtitle_am'] ?? ''
                                            : isOromo
                                                ? slideText['subtitle_or'] ?? ''
                                                : slideText['subtitle_en'] ??
                                                    '',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white.withOpacity(0.95),
                                          shadows: const [
                                            Shadow(
                                              offset: Offset(1, 1),
                                              blurRadius: 3,
                                              color: Colors.black54,
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      // Slide indicators
                      Positioned(
                        bottom: 20,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _slides.length,
                            (index) => Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentSlide == index
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Hero Content - Centered Logo Only (positioned below text)
                      Positioned(
                        bottom: 80,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/logo.jpg',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.favorite,
                                    color: AppTheme.primaryRed,
                                    size: 60,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Statistics Section
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  color: Colors.grey[50],
                  child: Column(
                    children: [
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.1,
                        ),
                        itemCount: _stats.length,
                        itemBuilder: (context, index) {
                          final stat = _stats[index];
                          return Card(
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    stat['icon'],
                                    style: const TextStyle(fontSize: 28),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    stat['number'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryRed,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Flexible(
                                    child: Text(
                                      stat['label'],
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Colors.grey[700],
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Vision, Mission, Core Values
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Card(
                              color: AppTheme.primaryRed,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isAmharic
                                          ? 'ራዕይ'
                                          : isOromo
                                              ? 'Ilma'
                                              : 'VISION',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      isAmharic
                                          ? 'በኢትዮጵያ ውስጥ የመረጡ አጋሮች እና የፊት መስመር ሰብዓዊ ድርጅት መሆን።'
                                          : isOromo
                                              ? 'Gosoonni filataman fi dhaabbata hawaasa biyyoolessaa jalqabaa ta\'uun Ethiopia keessatti.'
                                              : 'To be the Partner of Choice and A Frontline Humanitarian Organization in Ethiopia.',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Card(
                              color: AppTheme.primaryRed,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isAmharic
                                          ? 'ተልዕኮ'
                                          : isOromo
                                              ? 'Misiroota'
                                              : 'MISSION',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      isAmharic
                                          ? 'የሰውን ስቃይ ማስቆም እና መቀነስ በመደበኛ እና በወቅቱ ሰብዓዊ እርዳታዎች።'
                                          : isOromo
                                              ? 'Muruu namootaa dhabamsiisuu fi hir\'isuu gargaarsa hawaasa biyyoolessaa kan ta\'e.'
                                              : 'To prevent and alleviate human sufferings through humanitarian interventions.',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Donation CTA
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryRed, AppTheme.darkRed],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        isAmharic
                            ? 'ልገሳ ያድርጉ'
                            : isOromo
                                ? 'Kenneessaa'
                                : 'Make a Donation',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isAmharic
                            ? 'ልገሳዎ ሕይወትን ይቆጥባል'
                            : isOromo
                                ? 'Kenneessaa keessan jireenya qofaaf godhataa jira'
                                : 'Your donation helps save lives',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const DonationScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primaryRed,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          isAmharic
                              ? '💝 አሁን ይልገሱ'
                              : isOromo
                                  ? '💝 Amma kennaa'
                                  : '💝 Donate Now',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Recognition Blog Section
              if (_blogs.isNotEmpty)
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(24.0),
                    color: Colors.grey[50],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAmharic
                              ? 'መሸለም ብሎግ'
                              : isOromo
                                  ? 'Blog Mallattoo'
                                  : 'Recognition Blog',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryRed,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 280,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _blogs.length,
                            itemBuilder: (context, index) {
                              final blog = _blogs[index];
                              return Container(
                                width: 280,
                                margin: const EdgeInsets.only(right: 16),
                                child: Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 120,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              AppTheme.primaryRed,
                                              AppTheme.darkRed
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(12),
                                            topRight: Radius.circular(12),
                                          ),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.emoji_events,
                                            color: Colors.white,
                                            size: 50,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              blog['title'] ?? 'Recognition',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              blog['description'] ?? '',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 12,
                                                  backgroundColor:
                                                      AppTheme.primaryRed,
                                                  child: Text(
                                                    blog['user']?['name']?[0]
                                                            ?.toUpperCase() ??
                                                        'U',
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    blog['user']?['name'] ??
                                                        'Anonymous',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.grey[600],
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
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
                      ],
                    ),
                  ),
                ),

              // Get Involved Section
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  color: AppTheme.primaryRed,
                  child: Column(
                    children: [
                      Text(
                        isAmharic
                            ? 'እኛን ይቀላቀሉ'
                            : isOromo
                                ? 'Nu waliin maaqaa'
                                : 'Get Involved',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Card(
                              color: Colors.white.withOpacity(0.1),
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const RegisterScreen(),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      const Icon(Icons.people,
                                          size: 40, color: Colors.white),
                                      const SizedBox(height: 8),
                                      Text(
                                        isAmharic
                                            ? 'በፈቃደኛ'
                                            : isOromo
                                                ? 'Hawwaasa'
                                                : 'Volunteer',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Card(
                              color: Colors.white.withOpacity(0.1),
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const RegisterScreen(),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      const Icon(Icons.person,
                                          size: 40, color: Colors.white),
                                      const SizedBox(height: 8),
                                      Text(
                                        isAmharic
                                            ? 'አባል'
                                            : isOromo
                                                ? 'Manguddoo'
                                                : 'Member',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Card(
                              color: Colors.white.withOpacity(0.1),
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const HubRequestScreen(),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      const Icon(Icons.hub,
                                          size: 40, color: Colors.white),
                                      const SizedBox(height: 8),
                                      Text(
                                        isAmharic
                                            ? 'ማዕከል'
                                            : isOromo
                                                ? 'Hub'
                                                : 'Hub',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Footer
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  color: Colors.grey[900],
                  child: Column(
                    children: [
                      Text(
                        isAmharic
                            ? 'የኢትዮጵያ ቀይ መስቀል ማኅበር'
                            : isOromo
                                ? 'Ethiopian Red Cross Society'
                                : 'Ethiopian Red Cross Society',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isAmharic
                            ? 'ከ1935 ጀምሮ'
                            : isOromo
                                ? '1935 irraa eegalee'
                                : 'Since 1935',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isAmharic
                            ? 'ሕይወትን ለሰውነት እንኖራለን'
                            : isOromo
                                ? 'Jireenyaaf jiraanna'
                                : 'We Live for Humanity',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[300],
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

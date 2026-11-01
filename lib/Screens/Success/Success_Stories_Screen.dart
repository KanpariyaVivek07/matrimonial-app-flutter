import 'package:flutter/material.dart';
import 'package:textformfield/Screens/Success/Story_Detail_screen.dart';

class SuccessStoriesScreen extends StatefulWidget {
  const SuccessStoriesScreen({super.key});

  @override
  State<SuccessStoriesScreen> createState() => _SuccessStoriesScreenState();
}

class _SuccessStoriesScreenState extends State<SuccessStoriesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final List<Map<String, String>> stories = [
    {
      'name': 'Rahul & Priya',
      'city': 'Surat',
      'photo': 'assets/image/c1.jpeg',
      'desc': 'We met on this platform and found our perfect match! '
          'Our journey began with a simple "hello" and blossomed into a beautiful '
          'relationship. After six months of dating, we knew we were meant to be. '
          'Now, we\'re happily married and expecting our first child!'
    },
    {
      'name': 'Amit & Sneha',
      'city': 'Ahmedabad',
      'photo': 'assets/image/c5.jpeg',
      'desc': 'A smooth and trusted journey to happily ever after! '
          'We were both skeptical about online matchmaking, but this platform '
          'proved us wrong. The verification process gave us confidence, and '
          'the matching algorithm was spot on. We tied the knot in a beautiful '
          'ceremony last year.'
    },
    {
      'name': 'Karan & Neha',
      'city': 'Rajkot',
      'photo': 'assets/image/c3.jpeg',
      'desc': 'We found love and family through this app. It works! '
          'As single parents, we were looking for someone who would understand '
          'our situations. The app helped us connect on a deeper level beyond '
          'just profiles. Now our families are blended, and we couldn\'t be happier.'
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openStoryDetail(Map<String, String> story) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => StoryDetailScreen(story: story),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  Widget _buildStoryCard(Map<String, String> story, int index) {
    return SlideTransition(
      position: _slideAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: GestureDetector(
          onTap: () => _openStoryDetail(story),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: EdgeInsets.only(
              bottom: 20,
              top: index == 0 ? 0 : 0,
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xfffceabb), Color(0xfff8b500)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Row(
              children: [
              Hero(
              tag: story['photo']!,
                child: Container(
                  decoration: BoxDecoration(
                      boxShadow: [
                      BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: const Offset(2, 2),
                      ) ],
                      borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    story['photo']!,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story['name']!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    story['city']!,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "❤️ Loved",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            story['desc']!,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _openStoryDetail(story),
                child: const Text(
                  "Read Full Story →",
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          ],
        ),
      ),
    ),
    ),
    ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appBarHeight = AppBar().preferredSize.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final totalAppBarHeight = appBarHeight + statusBarHeight;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Success Stories",
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          // gradient: LinearGradient(
          //   begin: Alignment.topCenter,
          //   end: Alignment.bottomCenter,
          //   colors: [
          //     Colors.deepPurple,
          //     const Color(0xFF9575CD),
          //     Colors.white,
          //   ],
          //   stops: const [0.0, 0.3, 0.3],
          //   tileMode: TileMode.clamp,
          // ),
        ),
        child: Padding(
          padding: EdgeInsets.only(top: 20),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: stories.length,
            itemBuilder: (context, index) {
              return _buildStoryCard(stories[index], index);
            },
          ),
        ),
      ),
    );
  }
}
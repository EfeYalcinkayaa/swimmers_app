// lib/main.dart
import 'pages/settings_page.dart';
import 'package:provider/provider.dart';
import 'theme_notifier.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';
import 'pages/login_page.dart';
import 'dart:async';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const SwimmerAppRoot(),
    ),
  );
}

class SwimmerAppRoot extends StatelessWidget {
  const SwimmerAppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'World Swimmers',
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        fontFamily: 'SF Pro',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        fontFamily: 'SF Pro',
      ),
      themeMode: themeNotifier.themeMode, // 💡 Burada dinamik tema kullanılıyor
      home: SplashScreen(),
    );
  }
}


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..forward();

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/HD-wallpaper-iphone-11-amoled-blue-galaxy-iphone-new-oceans-phone-wave-thumbnail.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.pool, size: 80, color: Colors.white),
              SizedBox(height: 20),
              Text(
                'World Swimmers App\nHoşgeldiniz! 🌊',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  final String username;
  const MainNavigationPage({required this.username, Key? key}) : super(key: key);

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;
  late final List<Widget> _pages; // ✅ late tanımlandı

  @override
  void initState() {
    super.initState();
    _pages = [
      SwimmerListPage(),
      TrackedSwimmersPage(),
      SettingsPage(username: widget.username), // ✅ widget burada kullanılabilir
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Swimmers'),
          BottomNavigationBarItem(icon: Icon(Icons.track_changes), label: 'Tracked'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class PlaceholderWidget extends StatelessWidget {
  final String text;
  const PlaceholderWidget(this.text);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(text, style: TextStyle(fontSize: 22)),
    );
  }
}

class Swimmer {
  final String name, nation, team, bestTime, profileUrl;
  final List<String> events;

  Swimmer({
    required this.name,
    required this.nation,
    required this.events,
    required this.team,
    required this.bestTime,
    required this.profileUrl,
  });

  factory Swimmer.fromJson(Map<String, dynamic> json) => Swimmer(
        name: json['name'],
        nation: json['nation'],
        events: List<String>.from(json['events']),
        team: json['team'],
        bestTime: json['bestTime'],
        profileUrl: json['profileUrl'],
      );
}

List<Swimmer> trackedSwimmers = [];

class SwimmerListPage extends StatefulWidget {
  @override
  State<SwimmerListPage> createState() => _SwimmerListPageState();
}

class _SwimmerListPageState extends State<SwimmerListPage> {
  List<Swimmer> swimmers = [], filtered = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final jsonStr = await rootBundle.loadString('assets/updated_swimmers.json');
    final List<dynamic> jsonList = json.decode(jsonStr);
    setState(() {
      swimmers = jsonList.map((e) => Swimmer.fromJson(e)).toList();
      filtered = swimmers;
      isLoading = false;
    });
  }

  void filter(String q) {
    setState(() {
      filtered = swimmers
          .where((s) => s.name.toLowerCase().contains(q.toLowerCase()))
          .toList();
    });
  }

  void toggleTrack(Swimmer swimmer) {
    setState(() {
      if (trackedSwimmers.contains(swimmer)) {
        trackedSwimmers.remove(swimmer);
      } else {
        trackedSwimmers.add(swimmer);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🌊 World Swimmers"),
        centerTitle: true,
        elevation: 6,
        shadowColor: Colors.black38,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    onChanged: filter,
                    decoration: InputDecoration(
                      labelText: "Search swimmer",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => TweenAnimationBuilder(
                      duration: Duration(milliseconds: 400 + i * 50),
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (_, value, child) => Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, (1 - value) * 20),
                          child: child,
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => SwimmerDetail(swimmer: filtered[i]),
                            transitionsBuilder: (_, anim, __, child) => FadeTransition(
                              opacity: anim,
                              child: child,
                            ),
                          ),
                        ),
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(filtered[i].name,
                                              style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 4),
                                          Text("🌍 Nation: ${filtered[i].nation}"),
                                          Text("🏊 Events: ${filtered[i].events.join(", ")}"),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        trackedSwimmers.contains(filtered[i])
                                            ? Icons.check_circle
                                            : Icons.add_circle_outline,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () => toggleTrack(filtered[i]),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class SwimmerDetail extends StatelessWidget {
  final Swimmer swimmer;
  const SwimmerDetail({required this.swimmer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(swimmer.name)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("🌍 Nation: ${swimmer.nation}", style: TextStyle(fontSize: 18)),
                Text("🏢 Team: ${swimmer.team}", style: TextStyle(fontSize: 18)),
                Text("⏱️ Best Time: ${swimmer.bestTime}", style: TextStyle(fontSize: 18)),
                const SizedBox(height: 16),
                Text("🏁 Events:", style: TextStyle(fontWeight: FontWeight.bold)),
                ...swimmer.events.map((e) => Text("• $e")),
                const Spacer(),
                if (swimmer.profileUrl.isNotEmpty)
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final uri = Uri.parse(swimmer.profileUrl);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      },
                      icon: Icon(Icons.link),
                      label: Text("View Profile"),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TrackedSwimmersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("📌 Tracked Swimmers")),
      body: trackedSwimmers.isEmpty
          ? Center(child: Text("No swimmers being tracked yet."))
          : ListView.builder(
              itemCount: trackedSwimmers.length,
              itemBuilder: (_, i) {
                final swimmer = trackedSwimmers[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(swimmer.name),
                    subtitle: Text("${swimmer.nation} • ${swimmer.events.join(", ")}"),
                  ),
                );
              },
            ),
    );
  }
}

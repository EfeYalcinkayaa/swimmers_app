import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_notifier.dart';
import '../widgets/background_container.dart'; // ✅ Arka plan container'ı eklendi

class SettingsPage extends StatelessWidget {
  final String username;
  const SettingsPage({required this.username, super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final themeMode = themeNotifier.themeMode;

    return Scaffold(
      appBar: AppBar(
  title: const Text(
    "⚙️ Ayarlar",
    style: TextStyle(color: Colors.white),
  ),
  centerTitle: true,
  backgroundColor: Colors.black.withOpacity(0.5),
  elevation: 0,
  iconTheme: const IconThemeData(color: Colors.white),
),

      body: BackgroundContainer(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: Colors.white.withOpacity(0.9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("🎨 Tema Seçimi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ListTile(
                      title: const Text("Sistem Varsayılanı"),
                      leading: Radio<ThemeMode>(
                        value: ThemeMode.system,
                        groupValue: themeMode,
                        onChanged: (_) => themeNotifier.setSystemMode(),
                      ),
                    ),
                    ListTile(
                      title: const Text("Açık Tema"),
                      leading: Radio<ThemeMode>(
                        value: ThemeMode.light,
                        groupValue: themeMode,
                        onChanged: (_) => themeNotifier.setLightMode(),
                      ),
                    ),
                    ListTile(
                      title: const Text("Koyu Tema"),
                      leading: Radio<ThemeMode>(
                        value: ThemeMode.dark,
                        groupValue: themeMode,
                        onChanged: (_) => themeNotifier.setDarkMode(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.white.withOpacity(0.9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.person),
                title: const Text("Kullanıcı Adı"),
                subtitle: Text(username),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.white.withOpacity(0.9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: const ListTile(
                leading: Icon(Icons.info_outline),
                title: Text("Uygulama Sürümü"),
                subtitle: Text("v1.0.0"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

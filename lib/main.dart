import 'package:flutter/material.dart';

import 'dart:convert';

void main() => runApp(const GameCompanionApp());

class GameCompanionApp extends StatelessWidget {
  const GameCompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Elden Ring Rehberi',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.amber,
        colorScheme: const ColorScheme.dark(
          primary: Colors.amber,
          secondary: Colors.redAccent,
        ),
      ),
      home: const BossListScreen(),
    );
  }
}

// 1. ANA LİSTE VE ARAMA SAYFASI
class BossListScreen extends StatefulWidget {
  const BossListScreen({super.key});

  @override
  State<BossListScreen> createState() => _BossListScreenState();
}

class _BossListScreenState extends State<BossListScreen> {
  List<dynamic> allBosses = [];
  List<dynamic> filteredBosses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBosses(); // Sayfa açıldığında veriyi otomatik çek
  }

  // API'den veri çekme simülasyonu
  Future<void> _loadBosses() async {
    setState(() => isLoading = true);

    await Future.delayed(const Duration(seconds: 2));

    // Lore (Hikaye) bilgisi de eklendi
    const String jsonResponse = '''
    [
      {"name": "Margit, the Fell Omen", "location": "Stormhill", "difficulty": "Zor", "drops": "Talisman Pouch", "lore": "Stormveil Kalesi'nin koruyucusu. Kararanlara geçit vermemek için bekler."},
      {"name": "Godrick the Grafted", "location": "Stormveil Castle", "difficulty": "Çok Zor", "drops": "Godrick's Great Rune", "lore": "Zayıf bir yarı tanrı, güç için Ejderha ve savaşçı uzuvlarını kendine aşılamıştır."},
      {"name": "Radahn, Scourge of the Stars", "location": "Caelid", "difficulty": "Aşırı Zor", "drops": "Radahn's Great Rune", "lore": "Yıldızları fethedebilen en güçlü general. Kızıl Çürüklük yüzünden aklını yitirmiştir."},
      {"name": "Malenia, Blade of Miquella", "location": "Elphael", "difficulty": "Kabus", "drops": "Malenia's Great Rune", "lore": "Asla yenilgi yüzü görmemiş efsanevi kılıç ustası. Çürüklük tanrıçasının taşıyıcısı."}
    ]
    ''';

    final List<dynamic> fetchedData = jsonDecode(jsonResponse);

    setState(() {
      allBosses = fetchedData;
      filteredBosses = fetchedData; // Başlangıçta hepsi listelenir
      isLoading = false;
    });
  }

  // Arama fonksiyonu (State Management)
  void _filterBosses(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredBosses = allBosses;
      } else {
        filteredBosses = allBosses
            .where(
              (boss) => boss['name'].toString().toLowerCase().contains(
                query.toLowerCase(),
              ),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Elden Ring Boss Rehberi',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.amber,
      ),
      body: Column(
        children: [
          // ARAMA ÇUBUĞU EKLENDİ
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: _filterBosses,
              decoration: InputDecoration(
                hintText: 'Boss Ara (Örn: Malenia)',
                prefixIcon: const Icon(Icons.search, color: Colors.amber),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.amber),
                  )
                // YUKARIDAN ÇEKİP YENİLEME (PULL-TO-REFRESH) EKLENDİ
                : RefreshIndicator(
                    color: Colors.amber,
                    onRefresh: _loadBosses,
                    child: ListView.builder(
                      itemCount: filteredBosses.length,
                      itemBuilder: (context, index) {
                        final boss = filteredBosses[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.redAccent,
                              child: Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              boss['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(boss['location']),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.amber,
                            ),
                            onTap: () {
                              // DETAY SAYFASINA YÖNLENDİRME (ROUTING) EKLENDİ
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      BossDetailScreen(bossData: boss),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// 2. YENİ EKLENEN: DETAY SAYFASI
class BossDetailScreen extends StatelessWidget {
  final Map<String, dynamic> bossData; // Önceki sayfadan gelen veriyi tutar

  const BossDetailScreen({super.key, required this.bossData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          bossData['name'],
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.amber,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(Icons.fort, size: 120, color: Colors.amber.shade700),
            ),
            const SizedBox(height: 30),
            Text(
              'Zorluk: ${bossData['difficulty']}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Konum: ${bossData['location']}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 12),
            Text(
              'Ganimet: ${bossData['drops']}',
              style: const TextStyle(fontSize: 18),
            ),
            const Divider(height: 40, color: Colors.amber),
            const Text(
              'Hikaye (Lore)',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              bossData['lore'],
              style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

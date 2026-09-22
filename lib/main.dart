import 'package:flutter/material.dart';

import 'dart:convert'; // JSON verilerini işlemek için

void main() => runApp(const GameCompanionApp());

class GameCompanionApp extends StatelessWidget {
  const GameCompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Elden Ring Rehberi',
      // Oyunun atmosferine uygun karanlık bir tema (Dark Theme) kurguluyoruz
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

class BossListScreen extends StatefulWidget {
  const BossListScreen({super.key});

  @override
  State<BossListScreen> createState() => _BossListScreenState();
}

class _BossListScreenState extends State<BossListScreen> {
  // İnternetten (REST API) geliyormuş gibi simüle ettiğimiz asenkron JSON verisi
  Future<List<dynamic>> fetchBosses() async {
    // İnternet hızını taklit etmek için 2 saniye bekletiyoruz (Asenkron işlem)
    await Future.delayed(const Duration(seconds: 2));

    // API'den gelen ham JSON verisi
    const String jsonResponse = '''
    [
      {"name": "Margit, the Fell Omen", "location": "Stormhill", "difficulty": "Zor", "drops": "Talisman Pouch"},
      {"name": "Godrick the Grafted", "location": "Stormveil Castle", "difficulty": "Çok Zor", "drops": "Godrick's Great Rune"},
      {"name": "Radahn, Scourge of the Stars", "location": "Caelid", "difficulty": "Aşırı Zor", "drops": "Radahn's Great Rune"},
      {"name": "Malenia, Blade of Miquella", "location": "Elphael", "difficulty": "Kabus", "drops": "Malenia's Great Rune"}
    ]
    ''';

    // JSON'ı Dart dilinin anlayabileceği List formatına çeviriyoruz
    return jsonDecode(jsonResponse);
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
        centerTitle: true,
      ),
      // Veri yüklenirken, hata alırken ve veri geldiğinde UI durumunu yöneten yapı
      body: FutureBuilder<List<dynamic>>(
        future: fetchBosses(),
        builder: (context, snapshot) {
          // 1. Durum: Veri henüz yükleniyor (Ekranda dönen ikon çıkar)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            );
          }
          // 2. Durum: Hata oluştu
          else if (snapshot.hasError) {
            return const Center(child: Text('Veri çekilirken hata oluştu.'));
          }
          // 3. Durum: Veri başarıyla geldi ve arayüze çiziliyor
          else {
            final bosses = snapshot.data!;
            return ListView.builder(
              itemCount: bosses.length,
              itemBuilder: (context, index) {
                final boss = bosses[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  elevation: 4,
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
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text('Konum: ${boss['location']}'),
                    trailing: Chip(
                      label: Text(
                        boss['difficulty'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: Colors.black45,
                    ),
                    onTap: () {
                      // Karta tıklandığında alt taraftan ganimet bilgisini (SnackBar) gösterir
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${boss['name']} Ganimeti: ${boss['drops']}',
                          ),
                          backgroundColor: Colors.amber.shade800,
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

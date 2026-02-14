import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../widgets/header.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> products = [];
  bool loading = true;

  // ✅ Base URL selon plateforme
  // Web: localhost
  // Android Emulator: 10.0.2.2 (pointe vers le PC)
  // Desktop: 127.0.0.1
  String get _baseUrl {
    if (kIsWeb) return 'http://localhost:8000';
    if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:8000';
    return 'http://127.0.0.1:8000';
  }

  /// ✅ Corrige l’URL d’image
  /// - Ne doit JAMAIS produire /media/static/...
  /// - Supporte:
  ///   - URL complète: http://127.0.0.1:8000/static/...
  ///   - Chemin: /static/... ou static/...
  ///   - Chemin: /media/... ou media/...
  String fixImageUrl(dynamic v) {
    final s = (v ?? '').toString().trim();
    if (s.isEmpty) return '';

    // 1) Si l'API renvoie une URL complète
    if (s.startsWith('http://') || s.startsWith('https://')) {
      // Remplace juste le host 127.0.0.1 par le host utilisable sur la plateforme
      // (sans toucher au reste du chemin /static/... ou /media/...)
      return s.replaceFirst('http://127.0.0.1:8000', _baseUrl)
              .replaceFirst('http://localhost:8000', _baseUrl);
    }

    // 2) Si l'API renvoie un chemin absolu
    if (s.startsWith('/')) {
      return '$_baseUrl$s';
    }

    // 3) Si l'API renvoie un chemin relatif
    // Ex: "static/image/..." ou "media/produits/..."
    return '$_baseUrl/$s';
  }

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/produits/'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          products = List<Map<String, dynamic>>.from(data);
          loading = false;
        });
      } else {
        setState(() => loading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur HTTP ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de connexion: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    return Scaffold(
      appBar: const Header(),
      drawer: isMobile
          ? Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const DrawerHeader(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green, Colors.lightGreen],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(Icons.shopping_cart, size: 40, color: Colors.white),
                        SizedBox(height: 8),
                        Text(
                          'E-Shop',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Votre boutique en ligne',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _drawerItem(context, Icons.home, "Accueil", '/home'),
                  _drawerItem(context, Icons.category, "Catégories", '/categories'),
                  _drawerItem(context, Icons.favorite, "Favoris", '/favorites'),
                  _drawerItem(context, Icons.shopping_bag, "Panier", '/cart'),
                  const Divider(),
                  _drawerItem(context, Icons.person, "Mon Compte", '/profile'),
                  _drawerItem(context, Icons.settings, "Paramètres", '/settings'),
                  _drawerItem(context, Icons.help, "Aide", '/help'),
                  const Divider(),
                  _drawerItem(context, Icons.login, "Connexion", '/login'),
                  _drawerItem(context, Icons.person_add, "Inscription", '/signup'),
                ],
              ),
            )
          : null,
      body: loading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Chargement des produits...',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: fetchProducts,
              color: Colors.green,
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: isMobile
                    ? ListView.separated(
                        itemCount: products.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return ProductCard(
                            product: products[index],
                            fixImageUrl: fixImageUrl,
                          );
                        },
                      )
                    : CustomScrollView(
                        slivers: [
                          SliverGrid(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: isTablet ? 2 : 3,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.75,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return ProductCard(
                                  product: products[index],
                                  fixImageUrl: fixImageUrl,
                                );
                              },
                              childCount: products.length,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon, color: Colors.green[700]),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
      trailing: const Icon(Icons.chevron_right, size: 18),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final String Function(dynamic) fixImageUrl;

  const ProductCard({
    super.key,
    required this.product,
    required this.fixImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = fixImageUrl(product['image']);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: (imageUrl.isEmpty)
                    ? Container(
                        height: 180,
                        width: double.infinity,
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image, size: 50, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Image non disponible', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: 180,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 180,
                            color: Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('IMG URL => $imageUrl');
                          debugPrint('IMG ERROR => $error');
                          return Container(
                            height: 180,
                            color: Colors.grey[200],
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                SizedBox(height: 8),
                                Text(
                                  'Image non disponible',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        },
                        semanticLabel: (product['nom'] ?? 'Image du produit').toString(),
                      ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${double.tryParse(product['prix'].toString())?.round() ?? 0} Ar',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['nom']?.toString() ?? 'Sans titre',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product['description']?.toString() ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Ajouté le: ${(product['date_ajout']?.toString().split('T').first ?? '')}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Navigation détails produit
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: const Text(
                        'Voir détails',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

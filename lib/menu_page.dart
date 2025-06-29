import 'package:flutter/material.dart';
import 'nav_bar.dart';
import 'profile.dart';
import 'video_scroll_page.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'upload.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _videos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVideos();
  }

  Future<void> _fetchVideos() async {
    setState(() { _isLoading = true; });
    final snapshot = await FirebaseFirestore.instance.collection('videos').get();
    final videos = snapshot.docs.map((doc) => doc.data()).toList();
    videos.shuffle(Random());
    setState(() {
      _videos = List<Map<String, dynamic>>.from(videos);
      _isLoading = false;
    });
  }

  void _onNavBarTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UploadPage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileScreen(
            username: 'genz_user',
            bio: 'Juste un dev qui code son TikTok parce que TikTok est coupé. #NoTikTokNoCry',
            abonnes: 42,
            isCurrentUser: true,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF181A20),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
        child: Column(
          children: [
            // Champ de recherche
            TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: Color(0xFF262A34),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                hintStyle: TextStyle(color: Colors.white54),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 8),
            // Boutons Actus et LIVE
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF262A34),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  ),
                  child: Text('Actus', style: TextStyle(color: Colors.white)),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF262A34),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  ),
                  child: Text('LIVE', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            SizedBox(height: 8),
            // Grille d'images
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: Color(0xFFC34E00)))
                  : _videos.isEmpty
                      ? Center(child: Text('Aucune vidéo disponible', style: TextStyle(color: Colors.white54)))
                      : MasonryGridView.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          physics: BouncingScrollPhysics(),
                          padding: EdgeInsets.only(bottom: 16),
                          itemCount: _videos.length,
                          itemBuilder: (context, index) {
                            final video = _videos[index];
                            final title = video['caption'] ?? 'Vidéo';
                            final thumbnail = video['thumbnailUrl'] ?? 'https://ui-avatars.com/api/?name=Video&background=23242B&color=fff';
                            return SizedBox(
                              height: 200 + Random().nextInt(60),
                              child: _buildBattleCard(title, thumbnail, video),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onNavBarTap,
      ),
    );
  }

  Widget _buildBattleCard(String title, String imageUrl, Map<String, dynamic> video) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoScrollPage(
              username: video['username'] ?? 'utilisateur',
              description: video['caption'] ?? '',
              hashtags: '',
              likes: video['likesCount'] ?? 0,
              comments: video['commentsCount'] ?? 0,
              shares: 0,
              // Tu pourras ajouter d'autres champs ici
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity),
            ),
          ),
          SizedBox(height: 4),
          Text(title, style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
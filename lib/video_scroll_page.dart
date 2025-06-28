import 'package:flutter/material.dart';
import 'nav_bar.dart';

class VideoScrollPage extends StatelessWidget {
  final String username;
  final String description;
  final String hashtags;
  final int likes;
  final int comments;
  final int shares;

  const VideoScrollPage({
    Key? key,
    required this.username,
    required this.description,
    required this.hashtags,
    required this.likes,
    required this.comments,
    required this.shares,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF181A20),
      body: Stack(
        children: [
          // Vidéo fictive (remplacer par un vrai player si besoin)
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Color(0xFF181A20),
            child: Center(
              child: Text(
                description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Overlay actions à droite
          Positioned(
            right: 16,
            top: MediaQuery.of(context).size.height * 0.25,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.grey[300],
                  child: Text(
                    username[0].toUpperCase(),
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
                SizedBox(height: 24),
                _ActionIcon(icon: Icons.favorite_border, count: likes),
                SizedBox(height: 18),
                _ActionIcon(icon: Icons.mode_comment_outlined, count: comments),
                SizedBox(height: 18),
                _ActionIcon(icon: Icons.send, count: shares),
              ],
            ),
          ),
          // Bas de l'écran : nom utilisateur et hashtags
          Positioned(
            left: 16,
            bottom: 32,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '@$username',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  hashtags,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final int count;
  const _ActionIcon({required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 30),
        SizedBox(height: 2),
        Text(
          count >= 1000 ? '${(count / 1000).toStringAsFixed(1)}K' : count.toString(),
          style: TextStyle(color: Colors.white, fontSize: 13),
        ),
      ],
    );
  }
} 
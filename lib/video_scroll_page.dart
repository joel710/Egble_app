import 'package:flutter/material.dart';
import 'nav_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
                // Avatar
                Container(
                  width: 44,
                  height: 44,
                  margin: EdgeInsets.only(bottom: 28),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      'https://placehold.co/40x40/D6C2B4/1a1a1a?text=P',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Like
                _SvgActionButton(
                  svg: '''<svg xmlns="http://www.w3.org/2000/svg" width="24px" height="24px" fill="currentColor" viewBox="0 0 256 256"><path d="M178,32c-20.65,0-38.73,8.88-50,23.89C116.73,40.88,98.65,32,78,32A62.07,62.07,0,0,0,16,94c0,70,103.79,126.66,108.21,129a8,8,0,0,0,7.58,0C136.21,220.66,240,164,240,94A62.07,62.07,0,0,0,178,32ZM128,206.8C109.74,196.16,32,147.69,32,94A46.06,46.06,0,0,1,78,48c19.45,0,35.78,10.36,42.6,27a8,8,0,0,0,14.8,0c6.82-16.67,23.15-27,42.6-27a46.06,46.06,0,0,1,46,46C224,147.61,146.24,196.15,128,206.8Z"></path></svg>''',
                  count: likes,
                ),
                SizedBox(height: 18),
                // Comment
                _SvgActionButton(
                  svg: '''<svg xmlns="http://www.w3.org/2000/svg" width="24px" height="24px" fill="currentColor" viewBox="0 0 256 256"><path d="M140,128a12,12,0,1,1-12-12A12,12,0,0,1,140,128ZM84,116a12,12,0,1,0,12,12A12,12,0,0,0,84,116Zm88,0a12,12,0,1,0,12,12A12,12,0,0,0,172,116Zm60,12A104,104,0,0,1,79.12,219.82L45.07,231.17a16,16,0,0,1-20.24-20.24l11.35-34.05A104,104,0,1,1,232,128Zm-16,0A88,88,0,1,0,51.81,172.06a8,8,0,0,1,.66,6.54L40,216,77.4,203.53a7.85,7.85,0,0,1,2.53-.42,8,8,0,0,1,4,1.08A88,88,0,0,0,216,128Z"></path></svg>''',
                  count: comments,
                ),
                SizedBox(height: 18),
                // Share
                _SvgActionButton(
                  svg: '''<svg xmlns="http://www.w3.org/2000/svg" width="24px" height="24px" fill="currentColor" viewBox="0 0 256 256"><path d="M227.32,28.68a16,16,0,0,0-15.66-4.08l-.15,0L19.57,82.84a16,16,0,0,0-2.42,29.84l85.62,40.55,40.55,85.62A15.86,15.86,0,0,0,157.74,248q.69,0,1.38-.06a15.88,15.88,0,0,0,14-11.51l58.2-191.94c0-.05,0-.1,0-.15A16,16,0,0,0,227.32,28.68ZM157.83,231.85l-.05.14L118.42,148.9l47.24-47.25a8,8,0,0,0-11.31-11.31L107.1,137.58,24,98.22l.14,0L216,40Z"></path></svg>''',
                  count: shares,
                ),
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

class _SvgActionButton extends StatelessWidget {
  final String svg;
  final int count;
  const _SvgActionButton({required this.svg, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SvgPicture.string(svg, color: Colors.white, width: 32, height: 32),
        SizedBox(height: 2),
        Text(
          count >= 1000 ? '${(count / 1000).toStringAsFixed(1)}K' : count.toString(),
          style: TextStyle(color: Colors.white, fontSize: 13),
        ),
      ],
    );
  }
} 
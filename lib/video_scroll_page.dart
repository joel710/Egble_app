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

  void _showCommentInput(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Champ de saisie + bouton Send
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Comment',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFC34E00), // orange soft
                        shape: StadiumBorder(),
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      ),
                      child: Text('Send', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                // Rangée d'icônes
                Row(
                  children: [
                    Icon(Icons.alternate_email, color: Colors.grey[700]),
                    SizedBox(width: 16),
                    Icon(Icons.emoji_emotions_outlined, color: Colors.grey[700]),
                    SizedBox(width: 16),
                    Icon(Icons.image_outlined, color: Colors.grey[700]),
                    SizedBox(width: 16),
                    Icon(Icons.add_circle_outline, color: Colors.grey[700]),
                    SizedBox(width: 16),
                    // Quelques emojis custom (remplace par tes assets si besoin)
                    Text('🥲', style: TextStyle(fontSize: 24)),
                    Text('🥰', style: TextStyle(fontSize: 24)),
                    Text('😱', style: TextStyle(fontSize: 24)),
                    Text('😘', style: TextStyle(fontSize: 24)),
                    Text('😊', style: TextStyle(fontSize: 24)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF191919),
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
          // Flèche retour stylisée en haut à gauche
          Positioned(
            top: 24,
            left: 8,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 28),
            ),
          ),
          // Overlay actions à droite
          Positioned(
            right: 16,
            bottom: 140,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Like
                _SvgActionButton(
                  svg: '''<svg xmlns="http://www.w3.org/2000/svg" width="24px" height="24px" fill="currentColor" viewBox="0 0 256 256"><path d="M178,32c-20.65,0-38.73,8.88-50,23.89C116.73,40.88,98.65,32,78,32A62.07,62.07,0,0,0,16,94c0,70,103.79,126.66,108.21,129a8,8,0,0,0,7.58,0C136.21,220.66,240,164,240,94A62.07,62.07,0,0,0,178,32ZM128,206.8C109.74,196.16,32,147.69,32,94A46.06,46.06,0,0,1,78,48c19.45,0,35.78,10.36,42.6,27a8,8,0,0,0,14.8,0c6.82-16.67,23.15-27,42.6-27a46.06,46.06,0,0,1,46,46C224,147.61,146.24,196.15,128,206.8Z"></path></svg>''',
                  count: likes,
                ),
                SizedBox(height: 24),
                // Comment
                _SvgActionButton(
                  svg: '''<svg xmlns="http://www.w3.org/2000/svg" width="24px" height="24px" fill="currentColor" viewBox="0 0 256 256"><path d="M140,128a12,12,0,1,1-12-12A12,12,0,0,1,140,128ZM84,116a12,12,0,1,0,12,12A12,12,0,0,0,84,116Zm88,0a12,12,0,1,0,12,12A12,12,0,0,0,172,116Zm60,12A104,104,0,0,1,79.12,219.82L45.07,231.17a16,16,0,0,1-20.24-20.24l11.35-34.05A104,104,0,1,1,232,128Zm-16,0A88,88,0,1,0,51.81,172.06a8,8,0,0,1,.66,6.54L40,216,77.4,203.53a7.85,7.85,0,0,1,2.53-.42,8,8,0,0,1,4,1.08A88,88,0,0,0,216,128Z"></path></svg>''',
                  count: comments,
                ),
                SizedBox(height: 24),
                // Star (favori)
                _SvgActionButton(
                  svg: '''<svg xmlns="http://www.w3.org/2000/svg" width="24px" height="24px" fill="currentColor" viewBox="0 0 256 256"><path d="M227.32,28.68a16,16,0,0,0-15.66-4.08l-.15,0L19.57,82.84a16,16,0,0,0-2.42,29.84l85.62,40.55,40.55,85.62A15.86,15.86,0,0,0,157.74,248q.69,0,1.38-.06a15.88,15.88,0,0,0,14-11.51l58.2-191.94c0-.05,0-.1,0-.15A16,16,0,0,0,227.32,28.68ZM157.83,231.85l-.05.14L118.42,148.9l47.24-47.25a8,8,0,0,0-11.31-11.31L107.1,137.58,24,98.22l.14,0L216,40Z"></path></svg>''',
                  count: 197,
                ),
                
              ],
            ),
          ),
          // Bas de l'écran : profil, nom, follow, description, partage
          Positioned(
            left: 16,
            right: 16,
            bottom: 70,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage('https://placehold.co/48x48/fff/000?text=U'),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Color(0xFFC34E00), width: 2),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        username,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 9, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text('Follow', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            description,
                            style: TextStyle(color: Colors.white, fontSize: 18),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2),
                          Text(
                            hashtags,
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    
                  ],
                ),
              ],
            ),
          ),
          // Champ de commentaire en bas
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () => _showCommentInput(context),
              child: Container(
                margin: EdgeInsets.only(left: 8, right: 8, bottom: 8),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Color(0xFF23242B),
                  borderRadius: BorderRadius.circular(32),
                ),
                alignment: Alignment.centerLeft,
                child: Text(
                  'Comment',
                  style: TextStyle(color: Colors.white54, fontSize: 18),
                ),
              ),
            ),
          ),
        ],
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
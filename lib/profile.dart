import 'package:flutter/material.dart';
import 'nav_bar.dart';

class ProfileScreen extends StatefulWidget {
  final String username;
  final String bio;

  final int abonnes;
  final bool isCurrentUser; // <--- Nouvel argument

  const ProfileScreen({
    required this.username,
    required this.bio,

    required this.abonnes,
    required this.isCurrentUser,
    Key? key,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isFollowing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isCurrentUser ? 'Mon Profil' : 'Profil de ${widget.username}',
        ),
        centerTitle: true,
      ),
      backgroundColor: Color(0xFF191919),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(height: 20),
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/images/profile.jpg'),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Color(0xFFC34E00), width: 2),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  widget.username,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  widget.bio,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[400]),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StatColumn(label: 'Abonnés', count: widget.abonnes),
                    SizedBox(width: 20),
                  ],
                ),
                SizedBox(height: 10),
                Divider(color: Colors.grey[700]),
              ],
            ),
          ),
          SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Container(
                  color: Colors.grey[800],
                  child: Center(child: Icon(Icons.play_arrow, color: Colors.white)),
                );
              },
              childCount: 9,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 1,
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.popUntil(context, (route) => route.isFirst);
          }
        },
      ),
    );
  }
}

class StatColumn extends StatelessWidget {
  final String label;
  final int count;

  const StatColumn({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$count', style: TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'nav_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'menu_page.dart';
import 'upload.dart';
import 'video_scroll_page.dart';
import 'video_preview_player.dart';

class ProfileScreen extends StatefulWidget {
  final String? uid;

  const ProfileScreen({this.uid, Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isFollowing = false;
  File? _newProfilePic;
  String? _profilePicUrl;
  bool _isUploadingPic = false;

  Map<String, dynamic>? _userData;
  bool _isLoadingProfile = true;

  final TextEditingController _nameEditController = TextEditingController();
  final TextEditingController _bioEditController = TextEditingController();

  List<Map<String, dynamic>> _userVideos = [];
  bool _isLoadingVideos = true;

  bool _isFollowing = false;

  int abonnes = 0;

  bool get isCurrentUser {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return false;
    return (widget.uid == null || widget.uid == user.id);
  }

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _checkIfFollowing();
  }

  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoadingProfile = true;
    });
    try {
      String? userId = widget.uid;
      if (userId == null) {
        final user = Supabase.instance.client.auth.currentUser;
        if (user == null) throw Exception('Utilisateur non connecté.');
        userId = user.id;
      }
      final response =
          await Supabase.instance.client
              .from('users')
              .select()
              .eq('id', userId)
              .single();
      // Compte dynamiquement les abonnés avec la méthode count de Supabase
      final countRes = await Supabase.instance.client
          .from('followers')
          .select('id')
          .eq('followed_id', userId);
      final abonnesCount = countRes is List ? countRes.length : 0;
      setState(() {
        _userData = response;
        _profilePicUrl = _userData?['profilepic'];
        abonnes = abonnesCount;
      });
      await _fetchUserVideos(userId);
    } catch (e) {
      // Optionnel : afficher une erreur
    } finally {
      setState(() {
        _isLoadingProfile = false;
      });
    }
  }

  Future<void> _fetchUserVideos(String uid) async {
    setState(() {
      _isLoadingVideos = true;
    });
    final response = await Supabase.instance.client
        .from('videos')
        .select()
        .eq('uid', uid)
        .order('createdat', ascending: false);
    setState(() {
      _userVideos = List<Map<String, dynamic>>.from(response);
      _isLoadingVideos = false;
    });
  }

  Future<void> _pickAndUploadProfilePic() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() {
        _isUploadingPic = true;
      });
      try {
        final user = Supabase.instance.client.auth.currentUser;
        if (user == null) throw Exception('Utilisateur non connecté.');
        final file = File(picked.path);
        // Upload sur Supabase Storage
        final fileName =
            '${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final storageResponse = await Supabase.instance.client.storage
            .from('profile-pics')
            .upload(
              fileName,
              file,
              fileOptions: const FileOptions(upsert: true),
            );
        if (storageResponse.isEmpty) throw Exception('Erreur upload Supabase');
        final url = Supabase.instance.client.storage
            .from('profile-pics')
            .getPublicUrl(fileName);
        // Mise à jour du profil dans la table users
        await Supabase.instance.client
            .from('users')
            .update({'profilepic': url})
            .eq('id', user.id);
        setState(() {
          _profilePicUrl = url;
          _newProfilePic = file;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Photo de profil mise à jour !')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur : ${e.toString()}')));
      } finally {
        setState(() {
          _isUploadingPic = false;
        });
      }
    }
  }

  void _showEditProfileModal() async {
    _nameEditController.text = _userData?['username'] ?? '';
    _bioEditController.text = _userData?['bio'] ?? '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Color(0xFF23242B),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundImage:
                              _newProfilePic != null
                                  ? FileImage(_newProfilePic!)
                                  : (_profilePicUrl != null
                                      ? NetworkImage(_profilePicUrl!)
                                      : AssetImage('assets/images/profile.jpg')
                                          as ImageProvider),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap:
                                _isUploadingPic
                                    ? null
                                    : () async {
                                      await _pickAndUploadProfilePic();
                                      setState(
                                        () {},
                                      ); // Force le refresh du modal
                                    },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFC34E00),
                                shape: BoxShape.circle,
                              ),
                              padding: EdgeInsets.all(8),
                              child:
                                  _isUploadingPic
                                      ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                      : Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  TextFormField(
                    controller: _nameEditController,
                    decoration: InputDecoration(
                      labelText: 'Nom',
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Color(0xFF262A34),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.person, color: Colors.grey[400]),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _bioEditController,
                    decoration: InputDecoration(
                      labelText: 'Bio',
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Color(0xFF262A34),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(
                        Icons.info_outline,
                        color: Colors.grey[400],
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                    maxLines: 2,
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        final user = Supabase.instance.client.auth.currentUser;
                        if (user == null) return;
                        await Supabase.instance.client
                            .from('users')
                            .update({
                              'username': _nameEditController.text.trim(),
                              'bio': _bioEditController.text.trim(),
                            })
                            .eq('id', user.id);
                        await _fetchUserProfile();
                        Navigator.pop(context);
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Profil mis à jour !')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFC34E00),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Enregistrer',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _checkIfFollowing() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || widget.uid == null) return;
    final response =
        await Supabase.instance.client
            .from('followers')
            .select()
            .eq('follower_id', user.id)
            .eq('followed_id', widget.uid!)
            .maybeSingle();
    setState(() {
      _isFollowing = response != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProfile) {
      return Scaffold(
        backgroundColor: Color(0xFF191919),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFC34E00)),
        ),
      );
    }
    final username = _userData?['username'] ?? 'Utilisateur';
    final bio = _userData?['bio'] ?? 'Aucune bio';
    final profilePic =
        _profilePicUrl ??
        _userData?['profilepic'] ??
        'https://ui-avatars.com/api/?name=Egble&background=23242B&color=fff';
    return Scaffold(
      appBar: AppBar(
        title: Text(isCurrentUser ? 'Mon Profil' : 'Profil de $username'),
        centerTitle: true,
        actions:
            isCurrentUser
                ? [
                  IconButton(
                    icon: Icon(Icons.edit, color: Color(0xFFC34E00)),
                    onPressed: _showEditProfileModal,
                  ),
                  IconButton(
                    icon: Icon(Icons.logout, color: Colors.redAccent),
                    tooltip: 'Se déconnecter',
                    onPressed: () async {
                      await Supabase.instance.client.auth.signOut();
                      if (mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      }
                    },
                  ),
                ]
                : null,
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
                  backgroundImage:
                      _newProfilePic != null
                          ? FileImage(_newProfilePic!)
                          : NetworkImage(profilePic) as ImageProvider,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Color(0xFFC34E00), width: 2),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  username,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  bio.isEmpty ? 'Aucune bio' : bio,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[400]),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StatColumn(label: 'Abonnés', count: abonnes),
                    SizedBox(width: 20),
                    if (!isCurrentUser)
                      ElevatedButton(
                        onPressed: () async {
                          final user =
                              Supabase.instance.client.auth.currentUser;
                          if (user == null || widget.uid == null) return;
                          setState(() {
                            _isFollowing = !_isFollowing;
                          });
                          try {
                            if (_isFollowing) {
                              // Follow
                              await Supabase.instance.client
                                  .from('followers')
                                  .insert({
                                    'follower_id': user.id,
                                    'followed_id': widget.uid!,
                                    'followed_at':
                                        DateTime.now().toIso8601String(),
                                  });
                            } else {
                              // Unfollow
                              await Supabase.instance.client
                                  .from('followers')
                                  .delete()
                                  .eq('follower_id', user.id)
                                  .eq('followed_id', widget.uid!);
                            }
                            await _fetchUserProfile();
                            await _checkIfFollowing();
                          } catch (e) {
                            setState(() {
                              _isFollowing = !_isFollowing;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erreur lors du follow: $e'),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFC34E00),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          _isFollowing ? 'Se désabonner' : "S'abonner",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 10),
                Divider(color: Colors.grey[700]),
              ],
            ),
          ),
          SliverGrid(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (_isLoadingVideos) {
                return Center(child: CircularProgressIndicator());
              }
              if (_userVideos.isEmpty) {
                return Center(
                  child: Text(
                    'Aucune vidéo',
                    style: TextStyle(color: Colors.white54),
                  ),
                );
              }
              final video = _userVideos[index];
              final thumbnail =
                  video['thumbnailUrl'] ??
                  'https://ui-avatars.com/api/?name=Video&background=23242B&color=fff';
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => VideoScrollPage(
                            initialIndex: index,
                            // Optionnel : tu peux passer la liste des vidéos si besoin
                          ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _VideoPreviewPlayer(videoUrl: video['videourl']),
                ),
              );
            }, childCount: _userVideos.length),
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
        currentIndex: isCurrentUser ? 2 : 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MenuPage()),
              (route) => false,
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UploadPage()),
            );
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

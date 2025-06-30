import 'package:flutter/material.dart';
import 'nav_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile.dart';

class VideoScrollPage extends StatefulWidget {
  // On peut passer l'index initial si besoin
  final int initialIndex;
  const VideoScrollPage({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<VideoScrollPage> createState() => _VideoScrollPageState();
}

class _VideoScrollPageState extends State<VideoScrollPage> {
  List<Map<String, dynamic>> _videos = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _pageSize = 8;
  DocumentSnapshot? _lastDoc;
  PageController? _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _fetchVideos();
  }

  Future<void> _fetchVideos({bool loadMore = false}) async {
    if (loadMore)
      setState(() {
        _isLoadingMore = true;
      });
    else
      setState(() {
        _isLoading = true;
      });
    Query query = FirebaseFirestore.instance
        .collection('videos')
        .orderBy('createdAt', descending: true)
        .limit(_pageSize);
    if (_lastDoc != null) {
      query = query.startAfterDocument(_lastDoc!);
    }
    final snapshot = await query.get();
    if (snapshot.docs.isNotEmpty) {
      _lastDoc = snapshot.docs.last;
      setState(() {
        _videos.addAll(
          snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>),
        );
      });
    }
    setState(() {
      _isLoading = false;
      _isLoadingMore = false;
    });
  }

  void _onPageChanged(int index) {
    if (index >= _videos.length - 2 && !_isLoadingMore) {
      _fetchVideos(loadMore: true);
    }
  }

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
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                      ),
                      child: Text(
                        'Send',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                // Rangée d'icônes
                Row(
                  children: [
                    Icon(Icons.alternate_email, color: Colors.grey[700]),
                    SizedBox(width: 16),
                    Icon(
                      Icons.emoji_emotions_outlined,
                      color: Colors.grey[700],
                    ),
                    SizedBox(width: 16),
                    Icon(Icons.image_outlined, color: Colors.grey[700]),
                    SizedBox(width: 16),
                    Icon(Icons.add_circle_outline, color: Colors.grey[700]),
                    SizedBox(width: 16),

                    // Quelques emojis custom (remplace par tes assets si besoin)
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

  void _showCommentsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Color(0xFF23242B),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 8,
                      top: 16,
                      bottom: 8,
                    ),
                    child: Row(
                      children: [
                        Text(
                          '217 comments',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        Spacer(),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  // Liste des commentaires
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        _buildComment(
                          avatar:
                              'https://randomuser.me/api/portraits/men/1.jpg',
                          username: 'joel453',
                          text: 'egble do mi?',
                        ),
                        _buildComment(
                          avatar:
                              'https://randomuser.me/api/portraits/cats/1.jpg',
                          username: 'overfit678A032B',
                          text: ' le model a encore crasher , egblé.',
                        ),
                        _buildComment(
                          avatar:
                              'https://randomuser.me/api/portraits/men/2.jpg',
                          username: 'El_baron',
                          text: 'aloba gné azé gan🥲🌹',
                        ),
                      ],
                    ),
                  ),
                  // Champ de saisie en bas
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
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
                            backgroundColor: Color(0xFFC34E00),
                            shape: StadiumBorder(),
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 10,
                            ),
                          ),
                          child: Text(
                            'Send',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
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

  Widget _buildComment({
    required String avatar,
    required String username,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(backgroundImage: NetworkImage(avatar), radius: 18),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(text, style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          Column(
            children: [Icon(Icons.favorite_border, color: Colors.white54)],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _videos.isEmpty) {
      return Scaffold(
        backgroundColor: Color(0xFF191919),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFC34E00)),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Color(0xFF191919),
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: _videos.length + (_isLoadingMore ? 1 : 0),
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          if (index >= _videos.length) {
            return Center(
              child: CircularProgressIndicator(color: Color(0xFFC34E00)),
            );
          }
          final video = _videos[index];
          return _VideoPlayerFeedItem(video: video);
        },
      ),
    );
  }
}

class _VideoPlayerFeedItem extends StatefulWidget {
  final Map<String, dynamic> video;
  const _VideoPlayerFeedItem({required this.video});

  @override
  State<_VideoPlayerFeedItem> createState() => _VideoPlayerFeedItemState();
}

class _VideoPlayerFeedItemState extends State<_VideoPlayerFeedItem> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isLiked = false;
  int _likesCount = 0;
  String? _videoId;
  final TextEditingController _commentController = TextEditingController();
  bool _isSendingComment = false;
  Map<String, dynamic>? _uploaderData;
  bool _isLoadingUploader = true;
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.video['videoUrl'] ?? '')
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
        _controller?.play();
        _controller?.setLooping(true);
      });
    _likesCount = widget.video['likesCount'] ?? 0;
    _videoId = widget.video['id'] ?? widget.video['videoId'];
    _checkIfLiked();
    _fetchUploaderData();
  }

  Future<void> _checkIfLiked() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _videoId == null) return;
    final doc =
        await FirebaseFirestore.instance
            .collection('videos')
            .doc(_videoId)
            .collection('likes')
            .doc(user.uid)
            .get();
    setState(() {
      _isLiked = doc.exists;
    });
  }

  Future<void> _toggleLike() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _videoId == null) return;
    final likeRef = FirebaseFirestore.instance
        .collection('videos')
        .doc(_videoId)
        .collection('likes')
        .doc(user.uid);
    final videoRef = FirebaseFirestore.instance
        .collection('videos')
        .doc(_videoId);
    if (_isLiked) {
      await likeRef.delete();
      await videoRef.update({'likesCount': FieldValue.increment(-1)});
      setState(() {
        _isLiked = false;
        _likesCount--;
      });
    } else {
      await likeRef.set({'likedAt': FieldValue.serverTimestamp()});
      await videoRef.update({'likesCount': FieldValue.increment(1)});
      setState(() {
        _isLiked = true;
        _likesCount++;
      });
    }
  }

  Future<void> _addComment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null ||
        _videoId == null ||
        _commentController.text.trim().isEmpty)
      return;
    setState(() {
      _isSendingComment = true;
    });
    final commentText = _commentController.text.trim();
    await FirebaseFirestore.instance
        .collection('videos')
        .doc(_videoId)
        .collection('comments')
        .add({
          'uid': user.uid,
          'username': user.displayName ?? 'Utilisateur',
          'text': commentText,
          'createdAt': FieldValue.serverTimestamp(),
        });
    await FirebaseFirestore.instance.collection('videos').doc(_videoId).update({
      'commentsCount': FieldValue.increment(1),
    });
    _commentController.clear();
    setState(() {
      _isSendingComment = false;
    });
  }

  Future<void> _fetchUploaderData() async {
    setState(() {
      _isLoadingUploader = true;
    });
    final uploaderId = widget.video['uid'];
    if (uploaderId == null) return;
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uploaderId)
            .get();
    if (doc.exists) {
      setState(() {
        _uploaderData = doc.data();
      });
      _checkIfFollowing(uploaderId);
    }
    setState(() {
      _isLoadingUploader = false;
    });
  }

  Future<void> _checkIfFollowing(String uploaderId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uploaderId)
            .collection('followers')
            .doc(user.uid)
            .get();
    setState(() {
      _isFollowing = doc.exists;
    });
  }

  Future<void> _toggleFollow() async {
    final user = FirebaseAuth.instance.currentUser;
    final uploaderId = widget.video['uid'];
    if (user == null || uploaderId == null) return;
    final followRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uploaderId)
        .collection('followers')
        .doc(user.uid);
    final uploaderRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uploaderId);
    if (_isFollowing) {
      await followRef.delete();
      await uploaderRef.update({'abonnes': FieldValue.increment(-1)});
      setState(() {
        _isFollowing = false;
      });
    } else {
      await followRef.set({'followedAt': FieldValue.serverTimestamp()});
      await uploaderRef.update({'abonnes': FieldValue.increment(1)});
      setState(() {
        _isFollowing = true;
      });
    }
  }

  void _showCommentsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Color(0xFF23242B),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 8,
                      top: 16,
                      bottom: 8,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Commentaires',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        Spacer(),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream:
                          FirebaseFirestore.instance
                              .collection('videos')
                              .doc(_videoId)
                              .collection('comments')
                              .orderBy('createdAt', descending: true)
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFC34E00),
                            ),
                          );
                        }
                        final comments = snapshot.data!.docs;
                        if (comments.isEmpty) {
                          return Center(
                            child: Text(
                              'Aucun commentaire',
                              style: TextStyle(color: Colors.white54),
                            ),
                          );
                        }
                        return ListView.builder(
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            final data =
                                comments[index].data() as Map<String, dynamic>;
                            return ListTile(
                              leading: CircleAvatar(child: Icon(Icons.person)),
                              title: Text(
                                data['username'] ?? 'Utilisateur',
                                style: TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                data['text'] ?? '',
                                style: TextStyle(color: Colors.white70),
                              ),
                            );
                          },
                        );
                      },
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

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Center(child: CircularProgressIndicator(color: Color(0xFFC34E00)));
    }
    return Stack(
      children: [
        Center(
          child: AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          ),
        ),
        // Overlays TikTok (profil, likes, commentaires, etc.)
        Positioned(
          right: 16,
          bottom: 120,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  _isLiked ? Icons.favorite : Icons.favorite_border,
                  color: _isLiked ? Colors.red : Colors.white,
                  size: 32,
                ),
                onPressed: _toggleLike,
              ),
              SizedBox(height: 4),
              Text(
                _likesCount >= 1000
                    ? '${(_likesCount / 1000).toStringAsFixed(1)}K'
                    : _likesCount.toString(),
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
              // Bouton commentaire
              IconButton(
                icon: Icon(Icons.comment, color: Colors.white, size: 32),
                onPressed: _showCommentsModal,
              ),
            ],
          ),
        ),
        // Infos vidéo + uploader
        Positioned(
          left: 16,
          bottom: 40,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(
                            uid: widget.video['uid'],
                          ),
                        ),
                      );
                    },
                    child: _isLoadingUploader
                        ? CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.grey[700],
                        )
                        : CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage(
                            _uploaderData?['profilePic'] ??
                                'https://ui-avatars.com/api/?name=Egble&background=23242B&color=fff',
                          ),
                        ),
                  ),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(
                            uid: widget.video['uid'],
                          ),
                        ),
                      );
                    },
                    child: Text(
                      _uploaderData?['username'] ?? 'Utilisateur',
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
                  if (!_isLoadingUploader &&
                      FirebaseAuth.instance.currentUser?.uid !=
                          widget.video['uid'])
                    GestureDetector(
                      onTap: _toggleFollow,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _isFollowing ? Colors.grey : Colors.red,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          _isFollowing ? 'Abonné' : 'S\'abonner',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                widget.video['caption'] ?? '',
                style: TextStyle(color: Colors.white, fontSize: 18),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // Champ de saisie commentaire en bas
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            margin: EdgeInsets.only(left: 8, right: 8, bottom: 8),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Color(0xFF23242B),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Commenter...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                _isSendingComment
                    ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFC34E00),
                      ),
                    )
                    : IconButton(
                      icon: Icon(Icons.send, color: Color(0xFFC34E00)),
                      onPressed: _addComment,
                    ),
              ],
            ),
          ),
        ),
      ],
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
          count >= 1000
              ? '${(count / 1000).toStringAsFixed(1)}K'
              : count.toString(),
          style: TextStyle(color: Colors.white, fontSize: 13),
        ),
      ],
    );
  }
}

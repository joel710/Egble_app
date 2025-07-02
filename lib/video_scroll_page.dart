import 'package:flutter/material.dart';
import 'nav_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:video_player/video_player.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'profile.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'services/video_interaction_service.dart';

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
  int _currentPage = 0;
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
    try {
      final response = await Supabase.instance.client
          .from('videos')
          .select()
          .order('createdat', ascending: false)
          .range(_currentPage * _pageSize, (_currentPage + 1) * _pageSize - 1);
      setState(() {
        if (loadMore) {
          _videos.addAll(List<Map<String, dynamic>>.from(response));
        } else {
          _videos = List<Map<String, dynamic>>.from(response);
        }
        if (response != null && (response as List).isNotEmpty) {
          _currentPage += 1;
        }
      });
    } catch (e) {
      print('Erreur lors du chargement des vidéos: $e');
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

  void _showCommentsModal(BuildContext context, Map<String, dynamic> video) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return CommentsModal(video: video);
      },
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

  void _handleLike(Map<String, dynamic> video) {
    // Cette fonction sera appelée par le _VideoPlayerFeedItem
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
    _controller = VideoPlayerController.network(widget.video['videourl'] ?? '')
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
        _controller?.play();
        _controller?.setLooping(true);
      });
    _likesCount = widget.video['likescount'] ?? 0;
    _videoId = widget.video['id'] ?? widget.video['videoid'];
    _checkIfLiked();
    _fetchUploaderData();
  }

  Future<void> _checkIfLiked() async {
    final user = Supabase.instance.client.auth.currentUser;
    final videoId = _videoId!;
    if (user == null) return;

    try {
      final response =
          await Supabase.instance.client
              .from('video_likes')
              .select()
              .eq('video_id', videoId)
              .eq('user_id', user.id)
              .maybeSingle();

      setState(() {
        _isLiked = response != null;
      });
    } catch (e) {
      print('Erreur lors de la vérification du like: $e');
    }
  }

  Future<void> _toggleLike() async {
    final videoId = _videoId!;
    final result = await VideoInteractionService.toggleLike(
      videoId,
      _likesCount,
    );
    setState(() {
      _isLiked = result;
      _likesCount += result ? 1 : -1;
    });
  }

  Future<void> _fetchUploaderData() async {
    setState(() {
      _isLoadingUploader = true;
    });

    final uploaderId = widget.video['uid'];
    if (uploaderId == null) return;

    try {
      final response =
          await Supabase.instance.client
              .from('users')
              .select()
              .eq('id', uploaderId)
              .single();

      setState(() {
        _uploaderData = response;
      });
      _checkIfFollowing(uploaderId);
    } catch (e) {
      print('Erreur lors du chargement des données uploader: $e');
    } finally {
      setState(() {
        _isLoadingUploader = false;
      });
    }
  }

  Future<void> _checkIfFollowing(String uploaderId) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final response =
          await Supabase.instance.client
              .from('followers')
              .select()
              .eq('follower_id', user.id)
              .eq('followed_id', uploaderId)
              .maybeSingle();

      setState(() {
        _isFollowing = response != null;
      });
    } catch (e) {
      print('Erreur lors de la vérification du follow: $e');
    }
  }

  Future<void> _toggleFollow() async {
    final user = Supabase.instance.client.auth.currentUser;
    final uploaderId = widget.video['uid'];
    if (user == null || uploaderId == null) return;

    try {
      if (_isFollowing) {
        // Unfollow
        await Supabase.instance.client
            .from('followers')
            .delete()
            .eq('follower_id', user.id)
            .eq('followed_id', uploaderId);

        setState(() {
          _isFollowing = false;
        });
      } else {
        // Follow
        await Supabase.instance.client.from('followers').insert({
          'follower_id': user.id,
          'followed_id': uploaderId,
          'followed_at': DateTime.now().toIso8601String(),
        });

        setState(() {
          _isFollowing = true;
        });
      }
    } catch (e) {
      print('Erreur lors du follow/unfollow: $e');
    }
  }

  void _showCommentsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return CommentsModal(video: widget.video);
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
              // Like
              _ActionButton(
                icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                activeIcon: Icons.favorite,
                isActive: _isLiked,
                activeColor: Colors.red,
                count: _likesCount,
                onTap: _toggleLike,
              ),
              SizedBox(height: 18),
              // Commentaire
              _ActionButton(
                iconWidget: SvgPicture.asset(
                  'assets/icons/message_circle_more.svg',
                  width: 32,
                  height: 32,
                  color: Colors.white,
                ),
                count: widget.video['commentscount'] ?? 0,
                onTap: () => _showCommentsModal(context),
              ),
              SizedBox(height: 18),
              // Partage
              _ActionButton(
                icon: Icons.send,
                count:
                    0, // Remplacer par un vrai compteur si tu veux compter les partages
                onTap: () {
                  final url = widget.video['videourl'] ?? '';
                  if (url.isNotEmpty) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Lien copié: $url')));
                  }
                },
              ),
            ],
          ),
        ),
        // Infos vidéo + uploader
        Positioned(
          left: 16,
          right: 16,
          bottom: 80,
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
                          builder:
                              (context) =>
                                  ProfileScreen(uid: widget.video['uid']),
                        ),
                      );
                    },
                    child:
                        _isLoadingUploader
                            ? CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.grey[700],
                            )
                            : CircleAvatar(
                              radius: 18,
                              backgroundImage: NetworkImage(
                                _uploaderData?['profilepic'] ??
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
                          builder:
                              (context) =>
                                  ProfileScreen(uid: widget.video['uid']),
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
                      Supabase.instance.client.auth.currentUser?.id !=
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
              Container(
                padding: EdgeInsets.only(bottom: 8),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width - 100,
                ),
                child: Text(
                  widget.video['caption'] ?? '',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        // Champ de commentaire discret en bas
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            margin: EdgeInsets.only(left: 12, right: 12, bottom: 10),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.18),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white24, width: 0.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    style: TextStyle(fontSize: 13, color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Ajouter un commentaire...',
                      border: InputBorder.none,
                      isDense: true,
                      hintStyle: TextStyle(fontSize: 12, color: Colors.white54),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.emoji_emotions_outlined,
                    color: Colors.white38,
                    size: 20,
                  ),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Color(0xFFC34E00), size: 20),
                  onPressed: _addComment,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _addComment() async {
    if (_videoId == null || _commentController.text.trim().isEmpty) return;
    setState(() {
      _isSendingComment = true;
    });
    final commentText = _commentController.text.trim();
    final success = await VideoInteractionService.addComment(
      _videoId!,
      commentText,
      widget.video['commentscount'] ?? 0,
    );
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de l'ajout du commentaire.")),
      );
    } else {
      _commentController.clear();
      setState(() {
        // Incrémente localement le compteur de commentaires
        widget.video['commentscount'] =
            (widget.video['commentscount'] ?? 0) + 1;
      });
      // Optionnel : tu peux rafraîchir les commentaires si tu les affiches ici
    }
    setState(() {
      _isSendingComment = false;
    });
  }
}

class CommentsModal extends StatefulWidget {
  final Map<String, dynamic> video;

  const CommentsModal({required this.video, Key? key}) : super(key: key);

  @override
  State<CommentsModal> createState() => _CommentsModalState();
}

class _CommentsModalState extends State<CommentsModal> {
  final TextEditingController _commentController = TextEditingController();
  List<Map<String, dynamic>> _comments = [];
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    try {
      final response = await Supabase.instance.client
          .from('video_comments')
          .select()
          .eq('video_id', widget.video['id'])
          .order('created_at', ascending: false);

      List<Map<String, dynamic>> comments = List<Map<String, dynamic>>.from(
        response,
      );
      // Pour chaque commentaire, on récupère les infos utilisateur
      for (var comment in comments) {
        final userId = comment['user_id'];
        final userData =
            await Supabase.instance.client
                .from('users')
                .select('username, profilepic')
                .eq('id', userId)
                .maybeSingle();
        comment['user'] = userData;
      }
      setState(() {
        _comments = comments;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des commentaires: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addComment() async {
    if (widget.video['id'] == null || _commentController.text.trim().isEmpty)
      return;
    setState(() {
      _isSending = true;
    });
    final commentText = _commentController.text.trim();
    final success = await VideoInteractionService.addComment(
      widget.video['id'],
      commentText,
      widget.video['commentscount'] ?? 0,
    );
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de l'ajout du commentaire.")),
      );
    } else {
      _commentController.clear();
      await _fetchComments();
    }
    setState(() {
      _isSending = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      '${_comments.length} commentaires',
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
                child:
                    _isLoading
                        ? Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFC34E00),
                          ),
                        )
                        : _comments.isEmpty
                        ? Center(
                          child: Text(
                            'Aucun commentaire',
                            style: TextStyle(color: Colors.white54),
                          ),
                        )
                        : ListView.builder(
                          controller: scrollController,
                          itemCount: _comments.length,
                          itemBuilder: (context, index) {
                            final comment = _comments[index];
                            final user =
                                comment['user'] as Map<String, dynamic>?;

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundImage: NetworkImage(
                                      user?['profilepic'] ??
                                          'https://ui-avatars.com/api/?name=User&background=23242B&color=fff',
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user?['username'] ?? 'Utilisateur',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          comment['text'] ?? '',
                                          style: TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.favorite_border,
                                      color: Colors.white54,
                                      size: 20,
                                    ),
                                    onPressed: () {},
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
              ),
              // Champ de saisie en bas
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 8,
                    top: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Ajouter un commentaire...',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Color(0xFF262A34),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      _isSending
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
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatefulWidget {
  final IconData? icon;
  final Widget? iconWidget;
  final IconData? activeIcon;
  final int count;
  final bool isActive;
  final VoidCallback onTap;
  final Color? activeColor;
  final String? videoId;

  const _ActionButton({
    this.icon,
    this.iconWidget,
    this.activeIcon,
    required this.count,
    required this.onTap,
    this.isActive = false,
    this.activeColor,
    this.videoId,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.2).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) => _controller.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _handleTap,
          child: ScaleTransition(
            scale: _scaleAnim,
            child:
                widget.iconWidget ??
                Icon(
                  widget.isActive && widget.activeIcon != null
                      ? widget.activeIcon
                      : widget.icon,
                  color:
                      widget.isActive
                          ? (widget.activeColor ?? Color(0xFFC34E00))
                          : Colors.white,
                  size: 32,
                ),
          ),
        ),
        SizedBox(height: 2),
        Text(
          widget.count >= 1000
              ? '${(widget.count / 1000).toStringAsFixed(1)}K'
              : widget.count.toString(),
          style: TextStyle(color: Colors.white, fontSize: 13),
        ),
      ],
    );
  }
}

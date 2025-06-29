import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'welcome_page.dart';
import 'login_page.dart';
import 'register_page.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage>
    with TickerProviderStateMixin {
  File? _selectedVideo;
  final ImagePicker _picker = ImagePicker();
  VideoPlayerController? _videoController;
  bool _isPlaying = false;
  double _playbackSpeed = 1.0;
  late AnimationController _playButtonController;
  late AnimationController _timelineController;

  // Text overlay variables
  List<TextOverlay> _textOverlays = [];
  bool _isTextMode = false;

  @override
  void initState() {
    super.initState();
    _playButtonController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _timelineController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _playButtonController.dispose();
    _timelineController.dispose();
    super.dispose();
  }

  Future<void> _pickVideo(ImageSource source) async {
    try {
      final status = await Permission.storage.request();
      if (status.isGranted || status.isLimited) {
        final XFile? video = await _picker.pickVideo(source: source);
        if (video != null) {
          setState(() {
            _selectedVideo = File(video.path);
            _initializeVideoPlayer();
          });
        }
      } else {
        _showPermissionDialog();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _initializeVideoPlayer() async {
    if (_selectedVideo != null) {
      _videoController = VideoPlayerController.file(_selectedVideo!)
        ..initialize().then((_) {
          setState(() {});
          _videoController!.setLooping(true);
          _videoController!.addListener(() {
            setState(() {});
          });
        });
    }
  }

  void _toggleVideoPlayback() {
    if (_videoController == null) return;
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _videoController!.play();
        _playButtonController.forward();
      } else {
        _videoController!.pause();
        _playButtonController.reverse();
      }
    });
  }

  void _showVideoSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF252525),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.video_library, color: Colors.white),
                title: const Text(
                  'Depuis la galerie',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickVideo(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam, color: Colors.white),
                title: const Text(
                  'Enregistrer une vidéo',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickVideo(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSpeedDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Vitesse de lecture',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SfSlider(
                  min: 0.25,
                  max: 4.0,
                  value: _playbackSpeed,
                  interval: 0.25,
                  showTicks: false,
                  showLabels: false,
                  enableTooltip: true,
                  tooltipShape: const SfPaddleTooltipShape(),
                  activeColor: Colors.white,
                  inactiveColor: Colors.grey[800],
                  thumbShape: const SfThumbShape(),
                  onChanged: (value) {
                    setState(() {
                      _playbackSpeed = value;
                      _videoController?.setPlaybackSpeed(value);
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('0.25x', style: TextStyle(color: Colors.grey[400])),
                  Text(
                    '${_playbackSpeed.toStringAsFixed(1)}x',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text('4.0x', style: TextStyle(color: Colors.grey[400])),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  void _addTextOverlay(Offset position) {
    final textOverlay = TextOverlay(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: '',
      position: position,
      scale: 1.0,
    );

    setState(() {
      _textOverlays.add(textOverlay);
    });

    _showTextEditDialog(textOverlay);
  }

  void _showTextEditDialog(TextOverlay overlay) {
    final textController = TextEditingController(text: overlay.text);

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: TextField(
              controller: textController,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              decoration: const InputDecoration(
                hintText: 'Tapez votre texte...',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
              autofocus: true,
              maxLines: null,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _textOverlays.removeWhere((t) => t.id == overlay.id);
                  });
                  Navigator.pop(context);
                },
                child: const Text(
                  'Supprimer',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    overlay.text = textController.text;
                  });
                  Navigator.pop(context);
                },
                child: const Text('OK', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }

  String _formatDuration(double seconds) {
    Duration duration = Duration(seconds: seconds.toInt());
    return "${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}";
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Permission requise'),
            content: const Text(
              'Cette application a besoin d\'accéder à votre galerie pour sélectionner des vidéos.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: const Text('Paramètres'),
              ),
            ],
          ),
    );
  }

  Widget _buildModernTimeline() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return Container(
        height: 80,
        color: const Color(0xFF191919),
        child: Center(
          child: Text(
            'Aucune vidéo chargée',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ),
      );
    }

    final duration = _videoController!.value.duration;
    final position = _videoController!.value.position;
    final progress = position.inMilliseconds / duration.inMilliseconds;

    return Container(
      height: 80,
      color: const Color(0xFF191919),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Time indicators
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(position.inSeconds.toDouble()),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _formatDuration(duration.inSeconds.toDouble()),
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Modern timeline
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF191919),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  // Background track
                  Container(
                    width: double.infinity,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  // Progress track
                  FractionallySizedBox(
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC34E00).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  // Timeline slider
                  Positioned.fill(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 40,
                        thumbShape: const CustomThumbShape(),
                        overlayShape: SliderComponentShape.noOverlay,
                        activeTrackColor: Colors.transparent,
                        inactiveTrackColor: Colors.transparent,
                        thumbColor: const Color(0xFFC34E00),
                      ),
                      child: Slider(
                        value: position.inSeconds.toDouble(),
                        min: 0.0,
                        max: duration.inSeconds.toDouble(),
                        onChanged: (value) {
                          _videoController!.seekTo(
                            Duration(seconds: value.toInt()),
                          );
                        },
                      ),
                    ),
                  ),

                  // Waveform simulation (decorative)
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 15,
                      ),
                      child: Row(
                        children: List.generate(50, (index) {
                          final height = (index % 5 + 1) * 2.0;
                          final isActive = index / 50 <= progress;
                          return Container(
                            width: 2,
                            height: height,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              color:
                                  isActive
                                      ? const Color(0xFFC34E00).withOpacity(0.8)
                                      : Colors.grey[700]?.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191919),
      body: Column(
        children: [
          // Video Player (covers full top)
          Expanded(
            child: Stack(
              children: [
                // Video container
                Center(
                  child:
                      _videoController != null &&
                              _videoController!.value.isInitialized
                          ? GestureDetector(
                            onTap: _isTextMode ? null : _toggleVideoPlayback,
                            onTapDown:
                                _isTextMode
                                    ? (details) {
                                      final RenderBox box =
                                          context.findRenderObject()
                                              as RenderBox;
                                      final localPosition = box.globalToLocal(
                                        details.globalPosition,
                                      );
                                      _addTextOverlay(localPosition);
                                    }
                                    : null,
                            child: AspectRatio(
                              aspectRatio: _videoController!.value.aspectRatio,
                              child: VideoPlayer(_videoController!),
                            ),
                          )
                          : GestureDetector(
                            onTap: _showVideoSourceDialog,
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              color: Colors.grey[900],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1A1A1A),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(
                                      Icons.video_library,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Sélectionner une vidéo',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                ),

                // App Bar overlay
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Spacer(),
                        const Text(
                          'Crée une vidéo',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(
                            Icons.send,
                            color: Color(0xFFC34E00),
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),

                // Text overlays
                ..._textOverlays.map(
                  (overlay) => Positioned(
                    left: overlay.position.dx,
                    top: overlay.position.dy,
                    child: GestureDetector(
                      onTap: () => _showTextEditDialog(overlay),
                      onScaleUpdate: (details) {
                        setState(() {
                          overlay.scale = details.scale;
                          overlay.position += details.focalPointDelta;
                        });
                      },
                      child: Transform.scale(
                        scale: overlay.scale,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            overlay.text.isEmpty ? 'Tapez ici' : overlay.text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Play button overlay
                if (_videoController != null &&
                    _videoController!.value.isInitialized &&
                    !_isPlaying &&
                    !_isTextMode)
                  Center(
                    child: AnimatedBuilder(
                      animation: _playButtonController,
                      builder: (context, child) {
                        return Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.play_arrow,
                            color: Colors.white.withOpacity(
                              1.0 - _playButtonController.value,
                            ),
                            size: 50,
                          ),
                        );
                      },
                    ),
                  ),

                // Tools positioned at top right
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  right: 16,
                  child: Column(
                    children: [
                      _buildVerticalToolButton(
                        Icons.speed,
                        'Vitesse',
                        _showSpeedDialog,
                      ),
                      const SizedBox(height: 12),
                      _buildVerticalToolButton(
                        _isTextMode ? Icons.text_fields : Icons.text_fields,
                        'Texte',
                        () {
                          setState(() {
                            _isTextMode = !_isTextMode;
                          });
                          if (!_isTextMode) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Mode texte désactivé'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                        isActive: _isTextMode,
                      ),
                    ],
                  ),
                ),

                // Text mode indicator
                if (_isTextMode)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Appuyez pour ajouter du texte',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Modern Timeline (replaces toolbar)
          _buildModernTimeline(),
        ],
      ),
    );
  }

  Widget _buildVerticalToolButton(
    IconData icon,
    String label,
    VoidCallback onPressed, {
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color:
                  isActive
                      ? const Color(0xFFC34E00).withOpacity(0.3)
                      : Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(22),
              border:
                  isActive
                      ? Border.all(color: const Color(0xFFC34E00), width: 2)
                      : null,
            ),
            child: Icon(
              icon,
              color: isActive ? const Color(0xFFC34E00) : Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? const Color(0xFFC34E00) : Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              shadows: const [
                Shadow(
                  offset: Offset(0, 1),
                  blurRadius: 2,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TextOverlay {
  String id;
  String text;
  Offset position;
  double scale;

  TextOverlay({
    required this.id,
    required this.text,
    required this.position,
    required this.scale,
  });
}

class CustomThumbShape extends SliderComponentShape {
  const CustomThumbShape();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(16, 40);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    // Thumb
    final thumbPaint =
        Paint()
          ..color = const Color(0xFFC34E00)
          ..style = PaintingStyle.fill;

    final thumbRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 4, height: 40),
      const Radius.circular(2),
    );

    canvas.drawRRect(thumbRect, thumbPaint);

    // Thumb indicator
    final indicatorPaint =
        Paint()
          ..color = const Color(0xFFC34E00)
          ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(center.dx, center.dy), 8, indicatorPaint);
  }
}

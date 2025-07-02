import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as path;

class VideoService {
  static const int maxFileSize = 50 * 1024 * 1024; // 50 Mo
  static const int maxDurationSeconds = 60; // 1 minute

  /// Upload une vidéo sur Supabase Storage, vérifie la taille et la durée, puis enregistre les métadonnées dans Firestore.
  /// Retourne l'URL publique de la vidéo.
  static Future<String?> uploadVideo({
    required File file,
    required String caption,
    required supabase.User user,
    String? thumbnailUrl,
  }) async {
    // Vérification taille
    final fileSize = await file.length();
    if (fileSize > maxFileSize) {
      throw Exception('La vidéo dépasse 50 Mo.');
    }

    // Vérification durée
    final controller = VideoPlayerController.file(file);
    await controller.initialize();
    final duration = controller.value.duration;
    await controller.dispose();
    if (duration.inSeconds > maxDurationSeconds) {
      throw Exception('La vidéo dépasse 1 minute.');
    }

    // Upload sur Supabase Storage
    final fileName =
        '${user.id}_${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}';
    final storageResponse = await supabase.Supabase.instance.client.storage
        .from('videos')
        .upload(
          fileName,
          file,
          fileOptions: const supabase.FileOptions(upsert: true),
        );
    if (storageResponse.isEmpty) {
      throw Exception('Erreur lors de l\'upload Supabase.');
    }
    final publicUrl = supabase.Supabase.instance.client.storage
        .from('videos')
        .getPublicUrl(fileName);

    // Enregistrement Supabase
    await supabase.Supabase.instance.client.from('videos').insert({
      'uid': user.id,
      'videourl': publicUrl,
      'caption': caption,
      'createdat': DateTime.now().toIso8601String(),
      'duration': duration.inSeconds,
      'likescount': 0,
      'commentscount': 0,
      if (thumbnailUrl != null) 'thumbnailurl': thumbnailUrl,
    });

    return publicUrl;
  }
}

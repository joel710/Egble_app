import 'package:supabase_flutter/supabase_flutter.dart';

class VideoInteractionService {
  static final _supabase = Supabase.instance.client;

  // Like/Unlike une vidéo
  static Future<bool> toggleLike(String videoId, int currentLikesCount) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    try {
      // Vérifier si l'utilisateur a déjà liké
      final existingLike =
          await _supabase
              .from('video_likes')
              .select()
              .eq('video_id', videoId)
              .eq('user_id', user.id)
              .maybeSingle();

      if (existingLike != null) {
        // Unlike
        await _supabase
            .from('video_likes')
            .delete()
            .eq('video_id', videoId)
            .eq('user_id', user.id);

        // Décrémenter le compteur
        await _supabase
            .from('videos')
            .update({'likescount': currentLikesCount - 1})
            .eq('id', videoId);

        return false; // Plus liké
      } else {
        // Like
        await _supabase.from('video_likes').insert({
          'video_id': videoId,
          'user_id': user.id,
        });

        // Incrémenter le compteur
        await _supabase
            .from('videos')
            .update({'likescount': currentLikesCount + 1})
            .eq('id', videoId);

        return true; // Maintenant liké
      }
    } catch (e) {
      print('Erreur lors du toggle like: $e');
      return false;
    }
  }

  // Vérifier si l'utilisateur a liké une vidéo
  static Future<bool> isLiked(String videoId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    try {
      final response =
          await _supabase
              .from('video_likes')
              .select()
              .eq('video_id', videoId)
              .eq('user_id', user.id)
              .maybeSingle();

      return response != null;
    } catch (e) {
      print('Erreur lors de la vérification du like: $e');
      return false;
    }
  }

  // Ajouter un commentaire
  static Future<bool> addComment(
    String videoId,
    String text,
    int currentCommentsCount,
  ) async {
    final user = _supabase.auth.currentUser;
    if (user == null || text.trim().isEmpty) return false;

    try {
      // Ajouter le commentaire
      await _supabase.from('video_comments').insert({
        'video_id': videoId,
        'user_id': user.id,
        'text': text.trim(),
      });

      // Incrémenter le compteur de commentaires
      await _supabase
          .from('videos')
          .update({'commentscount': currentCommentsCount + 1})
          .eq('id', videoId);

      return true;
    } catch (e) {
      print('Erreur lors de l\'ajout du commentaire: $e');
      return false;
    }
  }

  // Récupérer les commentaires d'une vidéo
  static Future<List<Map<String, dynamic>>> getComments(String videoId) async {
    try {
      final response = await _supabase
          .from('video_comments')
          .select('*, users(username, profilepic)')
          .eq('video_id', videoId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erreur lors du chargement des commentaires: $e');
      return [];
    }
  }
}

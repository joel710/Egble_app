import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:path/path.dart' as path;

class ProfileService {
  /// Upload une photo de profil sur Supabase Storage et met à jour la table 'users' dans Supabase.
  static Future<String> uploadProfilePicture({
    required File file,
    required supabase.User user,
  }) async {
    final fileName =
        '${user.id}_${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}';
    final storageResponse = await supabase.Supabase.instance.client.storage
        .from('profile_pics')
        .upload(
          fileName,
          file,
          fileOptions: const supabase.FileOptions(upsert: true),
        );
    if (storageResponse.isEmpty) {
      throw Exception("Erreur lors de l'upload Supabase.");
    }
    final publicUrl = supabase.Supabase.instance.client.storage
        .from('profile_pics')
        .getPublicUrl(fileName);
    // Met à jour la table 'users' dans Supabase
    await supabase.Supabase.instance.client
        .from('users')
        .update({'profilepic': publicUrl})
        .eq('id', user.id);
    return publicUrl;
  }
}

import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as path;

class ProfileService {
  /// Upload une photo de profil sur Supabase Storage et met à jour Firestore.
  static Future<String> uploadProfilePicture({
    required File file,
    required User user,
  }) async {
    final fileName = '${user.uid}_${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}';
    final storageResponse = await Supabase.instance.client.storage
        .from('profile_pics')
        .upload(fileName, file, fileOptions: const FileOptions(upsert: true));
    if (storageResponse.isEmpty) {
      throw Exception("Erreur lors de l'upload Supabase.");
    }
    final publicUrl = Supabase.instance.client.storage.from('profile_pics').getPublicUrl(fileName);
    // Met à jour Firestore
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'profilePic': publicUrl,
    });
    return publicUrl;
  }
} 
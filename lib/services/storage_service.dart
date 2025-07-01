import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

/// Service for handling Firebase Storage operations
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload user avatar
  Future<String> uploadAvatar({
    required String userId,
    required XFile imageFile,
  }) async {
    try {
      final file = File(imageFile.path);
      final ref = _storage.ref().child('avatars/$userId.jpg');

      // Upload file
      final uploadTask = await ref.putFile(
        file,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'userId': userId},
        ),
      );

      // Get download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload avatar: $e');
    }
  }

  /// Upload course thumbnail
  Future<String> uploadCourseThumbnail({
    required String courseId,
    required File imageFile,
  }) async {
    try {
      final ref = _storage.ref().child('courses/thumbnails/$courseId.jpg');

      final uploadTask = await ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'courseId': courseId},
        ),
      );

      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload course thumbnail: $e');
    }
  }

  /// Upload achievement icon
  Future<String> uploadAchievementIcon({
    required String achievementId,
    required File imageFile,
  }) async {
    try {
      final ref = _storage.ref().child('achievements/$achievementId.png');

      final uploadTask = await ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/png',
          customMetadata: {'achievementId': achievementId},
        ),
      );

      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload achievement icon: $e');
    }
  }

  /// Delete file from storage
  Future<void> deleteFile(String filePath) async {
    try {
      await _storage.ref(filePath).delete();
    } catch (e) {
      // File might not exist, ignore error
      print('Error deleting file: $e');
    }
  }

  /// Get download URL for a file
  Future<String> getDownloadUrl(String filePath) async {
    try {
      return await _storage.ref(filePath).getDownloadURL();
    } catch (e) {
      throw Exception('Failed to get download URL: $e');
    }
  }

  /// Check if file exists
  Future<bool> fileExists(String filePath) async {
    try {
      await _storage.ref(filePath).getDownloadURL();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Upload multiple files
  Future<List<String>> uploadMultipleFiles({
    required String folder,
    required List<File> files,
  }) async {
    final urls = <String>[];

    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
      final ref = _storage.ref().child('$folder/$fileName');

      try {
        final uploadTask = await ref.putFile(file);
        final url = await uploadTask.ref.getDownloadURL();
        urls.add(url);
      } catch (e) {
        print('Failed to upload file $i: $e');
      }
    }

    return urls;
  }
}

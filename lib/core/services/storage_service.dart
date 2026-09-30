import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../network/result.dart';
import '../network/supabase/supabase_config.dart';

class StorageService {
  StorageService({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;
  static const String _bucketName = 'ramp_media';

  Future<Result<String>> uploadFile({
    required File file,
    required String folder,
    String? customFileName,
  }) async {
    try {
      final fileName = customFileName ??
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final path = '$folder/$fileName';

      await _client.storage.from(_bucketName).upload(path, file);
      final downloadUrl = _client.storage.from(_bucketName).getPublicUrl(path);

      debugPrint('✅ Supabase Storage file uploaded successfully: $downloadUrl');
      return Result.success(downloadUrl);
    } catch (e) {
      debugPrint('❌ Supabase Storage upload error ($folder): $e');
      return Result.failure('Failed to upload file to Supabase Storage', e);
    }
  }

  Future<Result<String>> uploadData({
    required Uint8List data,
    required String folder,
    required String fileName,
    String mimeType = 'image/jpeg',
  }) async {
    try {
      final path = '$folder/$fileName';
      await _client.storage.from(_bucketName).uploadBinary(
            path,
            data,
            fileOptions: FileOptions(contentType: mimeType),
          );
      final downloadUrl = _client.storage.from(_bucketName).getPublicUrl(path);

      debugPrint('✅ Supabase Storage data uploaded successfully: $downloadUrl');
      return Result.success(downloadUrl);
    } catch (e) {
      debugPrint('❌ Supabase Storage upload error ($folder/$fileName): $e');
      return Result.failure('Failed to upload raw data to Supabase Storage', e);
    }
  }

  Future<Result<void>> deleteFile(String fileUrl) async {
    try {
      final uri = Uri.parse(fileUrl);
      final pathSegments = uri.pathSegments;
      final bucketIdx = pathSegments.indexOf(_bucketName);
      if (bucketIdx != -1 && bucketIdx < pathSegments.length - 1) {
        final path = pathSegments.sublist(bucketIdx + 1).join('/');
        await _client.storage.from(_bucketName).remove([path]);
      }
      return Result.success(null);
    } catch (e) {
      debugPrint('❌ Supabase Storage delete error ($fileUrl): $e');
      return Result.failure('Failed to delete file from Supabase Storage', e);
    }
  }
}

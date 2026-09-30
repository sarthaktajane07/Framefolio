import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';

/// Uploads images to Cloudinary (free tier — no Firebase Storage billing needed).
///
/// Storage equivalent path concept:  photographers/{uid}/cover/  &  portfolio/
/// Cloudinary folder used:           framefolio/{uid}/cover      &  framefolio/{uid}/portfolio
class StorageService {
  /// Upload a single [XFile] to Cloudinary under [folder].
  /// Returns the secure HTTPS URL.
  Future<String> uploadImage(XFile file, {required String folder}) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/${AppConstants.cloudinaryCloudName}/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = AppConstants.cloudinaryUploadPreset
      ..fields['folder'] = folder;

    if (kIsWeb) {
      final bytes = await file.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: file.name),
      );
    } else {
      request.files.add(
        await http.MultipartFile.fromPath('file', file.path),
      );
    }

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception(
        'Image upload failed (${response.statusCode}): $body',
      );
    }

    final json = jsonDecode(body) as Map<String, dynamic>;
    return json['secure_url'] as String;
  }

  /// Upload the cover photo for [uid] and return its URL.
  Future<String> uploadCoverPhoto(XFile file, String uid) {
    return uploadImage(file, folder: 'framefolio/$uid/cover');
  }

  /// Upload a portfolio image for [uid] and return its URL.
  Future<String> uploadPortfolioImage(XFile file, String uid) {
    return uploadImage(file, folder: 'framefolio/$uid/portfolio');
  }
}

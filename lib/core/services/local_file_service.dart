import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Service responsible for handling local file system operations.
/// Follows the Single Responsibility Principle by isolating file I/O 
/// from the database and presentation layers.
class LocalFileService {
  
  /// Saves a temporary image file to the application's permanent document directory.
  /// Generates a unique timestamp-based filename to prevent collisions.
  /// 
  /// @param {File} sourceFile - The temporary image file (e.g., from camera or gallery).
  /// @param {String} prefix - A semantic prefix for the file name (e.g., 'facade', 'streetview').
  /// @returns {Future<String>} The absolute path to the permanently saved file.
  Future<String> saveImageLocally(File sourceFile, {String prefix = 'img'}) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${directory.path}/client_media');
    
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final originalPath = sourceFile.path;
    final fileExtension = originalPath.substring(originalPath.lastIndexOf('.'));
    final uniqueId = DateTime.now().millisecondsSinceEpoch;
    final destinationPath = '${imagesDir.path}/${prefix}_$uniqueId$fileExtension';

    final savedFile = await sourceFile.copy(destinationPath);
    return savedFile.path;
  }

  /// Deletes a specific file from the local file system to free up device space.
  /// 
  /// @param {String} filePath - The absolute path of the file to delete.
  Future<void> deleteImageLocally(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
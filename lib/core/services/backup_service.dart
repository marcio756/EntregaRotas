// Ficheiro: lib/core/services/backup_service.dart
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../main.dart';

/// Service responsible for packing and unpacking the entire application state.
/// Follows SRP by decoupling archival and file picking logic from the UI.
class BackupService {
  /// Zips the Isar DB, JSON history, and local images into a single exportable file.
  Future<bool> exportBackup() async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final tempDir = await getTemporaryDirectory();
      
      // Gera um nome de ficheiro seguro com base na data (ex: 2026-05-20T10-05)
      final timestamp = DateTime.now().toIso8601String().replaceAll(RegExp(r'[:.]'), '-').substring(0, 16);
      final zipFile = File('${tempDir.path}/rota_pao_$timestamp.zip');
      
      // 1. Garantir que a Base de Dados é copiada em segurança (sem transações a decorrer)
      final isar = await isarService.db;
      final isarBackupPath = '${tempDir.path}/default.isar';
      if (File(isarBackupPath).existsSync()) File(isarBackupPath).deleteSync();
      await isar.copyToFile(isarBackupPath);

      // 2. Iniciar a compressão (Zip)
      var encoder = ZipFileEncoder();
      encoder.create(zipFile.path);
      
      encoder.addFile(File(isarBackupPath), 'default.isar');
      
      final historyFile = File('${docsDir.path}/delivery_history_logs.json');
      if (historyFile.existsSync()) {
        encoder.addFile(historyFile, 'delivery_history_logs.json');
      }
      
      final mediaDir = Directory('${docsDir.path}/client_media');
      if (mediaDir.existsSync()) {
        encoder.addDirectory(mediaDir, includeDirName: true);
      }
      
      encoder.close();

      // 3. Pedir ao utilizador a pasta onde quer guardar o ficheiro no telemóvel
      String? selectedDirectory = await FilePicker.getDirectoryPath();

      if (selectedDirectory != null) {
        final outputPath = '$selectedDirectory/rota_pao_backup_$timestamp.zip';
        await zipFile.copy(outputPath);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Unzips a backup file and overwrites the application's document directory.
  Future<bool> importBackup() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (result != null && result.files.single.path != null) {
        final zipPath = result.files.single.path!;
        final docsDir = await getApplicationDocumentsDirectory();
        
        // 1. Fechar forçadamente a ligação à BD local para permitir a sobreposição do ficheiro
        final isar = await isarService.db;
        await isar.close();

        // 2. Extrair o Zip em memória e injetar os ficheiros nos diretórios nativos da App
        final bytes = File(zipPath).readAsBytesSync();
        final archive = ZipDecoder().decodeBytes(bytes);

        for (final file in archive) {
          final filename = file.name;
          if (file.isFile) {
            final data = file.content as List<int>;
            File('${docsDir.path}/$filename')
              ..createSync(recursive: true)
              ..writeAsBytesSync(data);
          } else {
            Directory('${docsDir.path}/$filename').createSync(recursive: true);
          }
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
import 'dart:io';

import 'package:darkness_push/model/p8_file.dart';
import 'package:file_picker/file_picker.dart';

enum FileServiceError { canceled, selectedNotP8File, selectedWrongFile }

class FileService {
  static Future<P8File> selectP8File() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result == null) throw FileServiceError.canceled;
    if (result.files.single.extension?.toLowerCase() != 'p8') {
      throw FileServiceError.selectedNotP8File;
    }
    final path = result.files.single.path;
    if (path != null) {
      final content = await File(path).readAsString();
      final name = result.files.single.name;
      String? keyID;
      if (name.length == 21 && name.startsWith('AuthKey_') && name.endsWith('.p8')) {
        keyID = name.substring(8, 18);
      }
      final file = P8File(key: content, name: name, keyID: keyID);
      return file;
    } else {
      throw FileServiceError.selectedWrongFile;
    }
  }
}

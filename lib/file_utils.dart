import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

_requestPermission() async {
  if (await Permission.storage.isPermanentlyDenied) {
    return false;
  }
  if (await Permission.storage.status.isDenied) {
    if (await Permission.storage.request().isDenied) {
      return false;
    }
  }
  return true;
}

getSaveDirectory() async {
  if (Platform.isAndroid) {
    if (await _requestPermission()) {
      return Directory("/storage/emulated/0/Download");
    }
    return null;
  } else if (Platform.isIOS) {
    _requestPermission();
    return getLibraryDirectory();
  } else if (Platform.isWindows || Platform.isLinux) {
    return getDownloadsDirectory();
  }
}

void unzip(String filePath) async {
  if (await _requestPermission()) {
    if (Platform.isAndroid) {
      Directory _out = Directory("/storage/emulated/0/DCIM/");

      // Read the Zip file from disk.
      final bytes = File(filePath).readAsBytesSync();

      // Decode the Zip file
      final archive = ZipDecoder().decodeBytes(bytes);

      // Extract the contents of the Zip archive to disk.
      for (final file in archive) {
        final filename = file.name;
        final data = file.content as List<int>;
        File(_out.absolute.path + filename)
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      }
    }
  }
}

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_pdf_renderer/native_pdf_renderer.dart';
import 'package:path/path.dart' show extension;

class FilePreview {
  static const MethodChannel _channel = const MethodChannel('file_preview');

  static Future<Widget> getThumbnail(String filePath) async {
    switch (extension(filePath.toLowerCase())) {
      case ".pdf":
        final file = await PDFDocument.openFile(filePath);
        final page = await file.getPage(1);
        final filePreview =
            await page.render(width: page.width, height: page.height);
        return Image.memory(filePreview.bytes);
      case ".jpg":
      case ".jpeg":
      case ".png":
      case ".gif":
        return Image.file(File(filePath));
      default:
        if (Platform.isIOS) {
          final Uint8List byteList =
              await _channel.invokeMethod('getThumbnail', filePath);
          return Image.memory(byteList);
        } else {
          return Image.network(
            "https://via.placeholder.com/80x100?text=${extension(filePath)}",
          );
        }
    }
  }
}
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';


class Downloader extends StatefulWidget
{
  @override
  _DownloaderState createState() => _DownloaderState();
}




class _DownloaderState extends State<Downloader>
{
  var status = "Descargando";
  var progress = 'Por favor, espera...';
  String fileName = 'platform-tools.zip';
  String outputDir = 'platform-tools';

  String? getPlatformToolsUrl()
  {
    if (Platform.isWindows)
    {
      return 'https://dl.google.com/android/repository/platform-tools-latest-windows.zip';
    }
    else if (Platform.isMacOS)
    {
      return 'https://dl.google.com/android/repository/platform-tools-latest-darwin.zip';
    }
    else if (Platform.isLinux)
    {
      return 'https://dl.google.com/android/repository/platform-tools-latest-linux.zip';
    }
    else
    {
      return null;
    }
  }

  Future<void> downloadFile() async
  {
    status = "Descargando Platform Tools";
    try
    {
      final response = await http.get(Uri.parse(getPlatformToolsUrl()!));
      if (response.statusCode == 200)
      {
        final file = File(fileName);
        await file.writeAsBytes(response.bodyBytes);
        progress =  'Download completed: $fileName';
      }
      else
      {
        progress = 'Download Error: ${response.statusCode}';
      }
    }
    catch (e)
    {
      progress = 'An error occurred during the download: $e';
    }
  }

  Future<void> unzipFile() async
  {
    status = "Descomprimiendo";
    try
    {
      final bytes = File(fileName).readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);
      final outputDirectory = Directory(outputDir);
      if (!outputDirectory.existsSync())
      {
        outputDirectory.createSync(recursive: true);
      }

      for (final file in archive)
      {
        final filePath = '$outputDir/${file.name}';
        if (file.isFile)
        {
          final outFile = File(filePath);
          outFile.createSync(recursive: true);
          outFile.writeAsBytesSync(file.content as List<int>);
        }
        else
        {
          Directory(filePath).createSync(recursive: true);
        }
      }

      if (File(fileName).existsSync())
      {
        File(fileName).deleteSync();
      }

      progress = 'File decompressed correctly';


    }
    catch (e)
    {
      progress = 'File decompression error: $e';
    }
  }

  Future<void> moveFolderToParent() async
  {
    try
    {
      final currentDirectory = Directory.current;
      final folder = Directory("platform-tools/platform-tools");

      if (!folder.existsSync())
      {
        print('La carpeta $outputDir no existe.');
        return;
      }

      final newPath = '${currentDirectory.path}/adb-tools';

      await folder.rename(newPath);

      if (Directory("platform-tools").existsSync())
      {
        print('La carpeta $newPath ya existe. Eliminando...');
        await Directory("platform-tools").delete(recursive: true);
      }

      print('Carpeta movida a: $newPath');
    }
    catch (e)
    {
      progress = 'Error al mover la carpeta: $e';
    }
  }

}

void showDownloadProgressDialog(BuildContext context)
{
  final downloader = Downloader();
  bool isDownloading = true;
  bool isComplete = false;



  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(status),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(isComplete ? '¡Completado!' : progress),
          ],
        ),
      );
    },
  ).then((_)
  {
    // Este bloque se ejecuta cuando el diálogo se cierra
    if (isComplete)
    {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Proceso completado exitosamente.')),
      );
    }
  });

  // Ejecutar el proceso de descarga y descompresión
  Future(() async
  {
    final url = downloader.getPlatformToolsUrl();
    if (url == null)
    {
      print('OS no soportado');
      return;
    }

    await downloader.downloadFile();
    await downloader.unzipFile();
    await downloader.moveFolderToParent();

    isDownloading = false;
    isComplete = true;
    Navigator.of(context).pop();
  });
}
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';


class Downloader
{
  static final statusController = StreamController<String>.broadcast();
  static final progressController = StreamController<String>.broadcast();
  static String fileName = 'platform-tools.zip';
  static String outputDir = 'platform-tools';
  static bool isDownloading = false;
  static bool isComplete = false;

  static bool adbExists() => Directory("adb-tools").existsSync();

  static String? getPlatformToolsUrl()
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
    return null;
  }

  static Future<String> downloadFile() async
  {
    try
    {
      final response = await http.get(Uri.parse(getPlatformToolsUrl()!));
      if (response.statusCode == 200)
      {
        final file = File(fileName);
        await file.writeAsBytes(response.bodyBytes);
        return 'Download completed: $fileName';
      }
      else
      {
        return 'Download Error: ${response.statusCode}';
      }
    }
    catch (e)
    {
      return 'An error occurred during the download: $e';
    }
  }

  static Future<String> unzipFile() async
  {
    try
    {
      final archive = ZipDecoder().decodeBytes(File(fileName).readAsBytesSync());
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

      return 'File decompressed correctly';
    }
    catch (e)
    {
      return 'File decompression error: $e';
    }
  }

  static Future<String> moveFolderToParent() async
  {
    try
    {
      final folder = Directory("platform-tools/platform-tools");

      if (!folder.existsSync())
      {
        return "Por favor, espera...";
      }

      final newPath = '${Directory.current.path}/adb-tools';

      await folder.rename(newPath);

      if (Directory("platform-tools").existsSync())
      {
        await Directory("platform-tools").delete(recursive: true);
      }
    }
    catch (e)
    {
      return 'Error al mover la carpeta: $e';
    }
    return "Por favor, espera...";
  }

  static Future<void> showDownloadPreparationDialogs(BuildContext context) async
  {
    await showDialog(
      context: context,
      builder: (BuildContext context)
      {
        return AlertDialog(
          title: const Text('Descarga necesaria'),
          content: const Text('Se necesitan herramientas de ADB. Se iniciará la descarga.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: ()
              {
                Navigator.of(context).pop();
                showDownloadProgressDialog(context);
              },
            ),
          ],
        );
      },
    );

    /*await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Habilitar depuración USB'),
          content: Text('Por favor, habilita la depuración USB en tu dispositivo Android:\n\n1. Ve a Configuración\n2. Opciones de desarrollador\n3. Activa "Depuración USB"'),
          actions: [
            TextButton(
              child: Text('Entendido'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );*/
  }


  static Future<void> showDownloadProgressDialog(BuildContext context) async
  {
    isDownloading = true;
    isComplete = false;
    statusController.add("Descargando");
    progressController.add("Por favor, espera...");

    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context)
      {
        return AlertDialog(
          title: StreamBuilder<String>(
            stream: statusController.stream,
            initialData: "Descargando",
            builder: (context, statusSnapshot)
            {
              return Text(statusSnapshot.data!);
            },
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              StreamBuilder<String>(
                stream: progressController.stream,
                initialData: "Por favor, espera...",
                builder: (context, progressSnapshot) => Text(progressSnapshot.data!),
              ),
            ],
          ),
        );
      },
    );

    try
    {
      statusController.add("Descargando Platform Tools");
      progressController.add(await downloadFile());
      statusController.add("Descomprimiendo");
      progressController.add(await unzipFile());
      statusController.add("Moviendo archivos");
      progressController.add(await moveFolderToParent());

      navigator.pop();
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Proceso completado exitosamente.')),);
    }
    catch (e)
    {
      navigator.pop();
      scaffoldMessenger.showSnackBar(SnackBar(content: Text('Ocurrió un error: $e')),);
    }
    finally
    {
      statusController.close();
      progressController.close();
    }
  }
}
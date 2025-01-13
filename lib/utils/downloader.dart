import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';


void main() async
{
  if (!Directory("platform-tools").existsSync())
  {
    final url = getPlatformToolsUrl();
    if (url == null)
    {
      print('OS no supported');
      return;
    }

    final fileName = 'platform-tools.zip';
    final outputDir = 'platform-tools';

    print('Downloading Platform Tools from: $url');
    await downloadFile(url, 'platform-tools.zip');

    print('Descomprimiendo el archivo...');
    await unzipFile(fileName, outputDir);
    print('Descompresión completada en el directorio: $outputDir');

    print('Moviendo la carpeta descomprimida a un nivel superior...');
    await moveFolderToParent(outputDir);

    print('Operación completada. La carpeta se movió exitosamente.');
  }
}

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

Future<void> downloadFile(String url, String fileName) async
{
  try
  {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200)
    {
      final file = File(fileName);
      await file.writeAsBytes(response.bodyBytes);
      print('Download completed: $fileName');
    }
    else
    {
      print('Download Error: ${response.statusCode}');
    }
  }
  catch (e)
  {
    print('An error occurred during the download: $e');
  }
}

Future<void> unzipFile(String zipPath, String outputDir) async
{
  try
  {
    final bytes = File(zipPath).readAsBytesSync();
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

    print('File decompressed correctly');

    if (File(zipPath).existsSync())
      {
        File(zipPath).deleteSync();
      }
  }
  catch (e)
  {
    print('File decompression error: $e');
  }
}

Future<void> moveFolderToParent(String folderPath) async {
  try {
    final currentDirectory = Directory.current;
    final folder = Directory("platform-tools/platform-tools");

    if (!folder.existsSync())
    {
      print('La carpeta $folderPath no existe.');
      return;
    }

    final newPath = '${currentDirectory.path}/asas-t3est';



    await folder.rename(newPath);

    if (Directory("platform-tools").existsSync())
    {
      print('La carpeta $newPath ya existe. Eliminando...');
      await Directory("platform-tools").delete(recursive: true);
    }

    print('Carpeta movida a: $newPath');
  } catch (e) {
    print('Error al mover la carpeta: $e');
  }
}
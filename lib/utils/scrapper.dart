import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';


class Scrapper
{
  Future<Map<String, String>> fetchAppDetails(String packageName) async
  {
    final response = await http.get(Uri.parse("https://play.google.com/store/apps/details?id=$packageName"));
    try
    {
      if (response.statusCode != 200)
      {
        throw Exception("No se pudo obtener la información de la app");
      }

      var document = parse(response.body);
      String? appName = document.querySelector('span[itemprop="name"]')?.text.trim();
      String? author = document.querySelector('a[href^="/store/apps/developer?id="] span, a[href^="/store/apps/dev?id="] span')?.text.trim();
      String? iconPath = document.querySelector('.RhBWnf img')?.attributes['src'];

      return
        {
          'appName': appName ?? '',
          'author': author ?? '',
          'iconPath': iconPath ?? ''
        };
    }
    catch (e)
    {
      return {'appName': '', 'author': '', 'iconPath': ''};
    }
  }
}

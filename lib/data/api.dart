import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Apidatas {
  // static const String apiKey = '8f113230f22347a5939c7475dd134537';
  static const String apiKey = '6688768fb4a744e5bf1b2d13521afad1';

  List<Map<String, dynamic>> favorites = [];

  Future<List<Map<String, dynamic>>> getFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getStringList('favorites') ?? [];
    return favoritesJson
        .map((json) => Map<String, dynamic>.from(jsonDecode(json)))
        .toList();
  }

  Future<void> addToFavorites(Map<String, dynamic> article) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getStringList('favorites') ?? [];

    bool isAlreadyAdded = favoritesJson
        .any((fav) => jsonDecode(fav)['title'] == article['title']);

    if (!isAlreadyAdded) {
      favoritesJson.add(jsonEncode(article));
      await prefs.setStringList('favorites', favoritesJson);
    }
  }

  Stream<Map<String, dynamic>> fetchData() async* {
    final url = Uri.parse(
        'https://newsapi.org/v2/top-headlines?sources=techcrunch&apiKey=$apiKey');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $apiKey',
        },
      );
      log("message");
      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body) as Map<String, dynamic>;
        yield decodedData;
      } else {
        throw Exception('Failed to fetch data: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }
}

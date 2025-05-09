import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/podcast.dart';

class ItunesApiService {
  Future<List<Podcast>> fetchPodcasts(String category) async {
    final url = Uri.parse(
      'https://itunes.apple.com/search?term=$category&media=podcast',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body)['results'];
      return data.map((json) => Podcast.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load podcasts');
    }
  }
}

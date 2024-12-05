import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/album.dart';

class AlbumRepository {
  Future<List<Album>> fetchAlbum() async {
    final response =
        await http.get(Uri.parse('https://reqres.in/api/users?page=1'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse =
          jsonDecode(response.body)['data'] as List<dynamic>;
      return jsonResponse
          .map((data) => Album.fromJson(data as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load album');
    }
  }
}

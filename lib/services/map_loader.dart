import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

class MapLoader {
  Future<TiledComponent> loadMapFromUrl(String url, Vector2 tileSizeInPixels) async {
    try {
      // 1. Make the API call to get the S3 URL
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch map URL: ${response.statusCode}');
      }

      // Assuming the response contains the S3 URL directly
      // Adjust this part based on your actual API response structure
      final mapUrl = response.body;

      // 2. Download the TMX file from S3
      final mapResponse = await http.get(Uri.parse(mapUrl));
      if (mapResponse.statusCode != 200) {
        throw Exception('Failed to download TMX file: ${mapResponse.statusCode}');
      }

      // 3. Save the file temporarily
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp_map.tmx');
      await tempFile.writeAsBytes(mapResponse.bodyBytes);

      // 4. Load the map using TiledComponent
      final level = await TiledComponent.load(
        tempFile.path,
        tileSizeInPixels,
      );

      // 5. Clean up the temporary file
      await tempFile.delete();

      return level;
    } catch (e) {
      throw Exception('Error loading map: $e');
    }
  }
}
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class TmxS3Loader {
  final String bucketUrl;
  final String tmxFileName;
  final Dio dio;
  
  TmxS3Loader({
    required this.bucketUrl,
    required this.tmxFileName,
    Dio? dio,
  }) : this.dio = dio ?? Dio();

  Future<TiledComponent> loadTmxFromS3() async {
    try {
      final String fullUrl = '$bucketUrl/$tmxFileName';
      
      // Download the TMX file using Dio
      final response = await dio.get(
        fullUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      
      // Get temporary directory to store the downloaded file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/$tmxFileName');
      
      // Write the downloaded content to a temporary file
      await tempFile.writeAsBytes(response.data);
      
      // Load the TMX file directly using TiledComponent
      final tiledComponent = await TiledComponent.load(
        tempFile.path,
        Vector2.all(64), // Specify your tile size here
      );

      // Clean up the temporary file
      await tempFile.delete();
      
      return tiledComponent;
    } catch (e) {
      throw Exception('Error loading TMX from S3: $e');
    }
  }
}
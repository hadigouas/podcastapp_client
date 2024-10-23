import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_application_3/core/classes/shared_pref.dart';
import 'package:flutter_application_3/core/constent/api_consts.dart';
import 'package:flutter_application_3/core/errors/errors.dart';
import 'package:flutter_application_3/features/home/models/podcast_model.dart';
import 'package:http_parser/http_parser.dart';

abstract class PodcastRepo {
  Future<Either<ServerFailure, List<Podcast>>> getAllPodcasts();
  Future<Either<ServerFailure, String>> addPodcast(String name, String author,
      String audioPath, String thumbnailPath, String color);
  Future<Either<ServerFailure, String>> updatePodcast(String id, String name,
      String author, String audioPath, String thumbnailPath, String color);
  Future<Either<ServerFailure, String>> deletePodcast(String podcastId);
  Future<Either<ServerFailure, Podcast>> getPodcastById(String podcastId);
}

class PodcastImpl implements PodcastRepo {
  late final Dio dio;
  final token = SharedPrefs.getString("auth_token");
  PodcastImpl({required this.dio}) {
    dio.options.baseUrl = ApiConsts.base_url;
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);
    dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'x-auth': token
    };
  }

  @override
  Future<Either<ServerFailure, List<Podcast>>> getAllPodcasts() async {
    // Implementation remains the same
    try {
      final response = await dio.get('podcast/list');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final podcasts = data.map((json) => Podcast.fromJson(json)).toList();
        return Right(podcasts);
      } else {
        return Left(
            ServerFailure('Failed to get podcasts: ${response.statusCode}'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure('Failed to get podcasts: ${e.toString()}'));
    }
  }

  @override
  Future<Either<ServerFailure, String>> addPodcast(String name, String author,
      String audioPath, String thumbnailPath, String color) async {
    try {
      if (!color.startsWith('#')) {
        color = '#$color';
      }
      if (color.length > 7) {
        color = '#${color.substring(color.length - 6)}';
      }

      var formData = FormData.fromMap({
        'podcastname': name,
        'author': author,
        'color': color,
        'thumbnail': await MultipartFile.fromFile(thumbnailPath,
            contentType: MediaType('image', 'jpeg')),
        'audio': await MultipartFile.fromFile(audioPath,
            contentType: MediaType('audio', 'mpeg')),
      });

      final response = await dio.post('podcast/upload', data: formData);
      if (response.statusCode == 200) {
        return const Right('Podcast added successfully');
      } else {
        return Left(
            ServerFailure('Failed to add podcast: ${response.statusCode}'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure('Failed to add podcast: ${e.toString()}'));
    }
  }

  @override
  Future<Either<ServerFailure, String>> updatePodcast(
      String id,
      String name,
      String author,
      String audioPath,
      String thumbnailPath,
      String color) async {
    try {
      var formData = FormData.fromMap({
        'podcastname': name,
        'author': author,
        'color': color,
        if (thumbnailPath.isNotEmpty)
          'thumbnail': await MultipartFile.fromFile(thumbnailPath,
              contentType: MediaType('image', 'jpeg')),
        if (audioPath.isNotEmpty)
          'audio': await MultipartFile.fromFile(audioPath,
              contentType: MediaType('audio', 'mpeg')),
      });

      final response = await dio.put('podcast/$id', data: formData);

      if (response.statusCode == 200) {
        return const Right('Podcast updated successfully');
      } else {
        return Left(
            ServerFailure('Failed to update podcast: ${response.statusCode}'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure('Failed to update podcast: ${e.toString()}'));
    }
  }

  @override
  Future<Either<ServerFailure, String>> deletePodcast(String podcastId) async {
    try {
      final response = await dio.delete('podcast/$podcastId');
      if (response.statusCode == 200) {
        return const Right('Podcast deleted successfully');
      } else {
        return Left(
            ServerFailure('Failed to delete podcast: ${response.statusCode}'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure('Failed to delete podcast: ${e.toString()}'));
    }
  }

  @override
  Future<Either<ServerFailure, Podcast>> getPodcastById(
      String podcastId) async {
    // Implementation remains the same
    try {
      final response = await dio.get('podcast/$podcastId');
      if (response.statusCode == 200) {
        final podcast = Podcast.fromJson(response.data);
        return Right(podcast);
      } else {
        return Left(ServerFailure('Podcast not found: ${response.statusCode}'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure('Failed to get podcast: ${e.toString()}'));
    }
  }
}

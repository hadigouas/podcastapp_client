import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_application_3/core/constent/api_consts.dart';
import 'package:flutter_application_3/features/home/models/podcast_model.dart';

abstract class PodcastRepo {
  Future<Either<String, List<Podcast>>> getAllPodcasts();
  Future<Either<String, List<Podcast>>> addPodcast(Podcast podcast);
  Future<Either<String, List<Podcast>>> updatePodcast(Podcast podcast);
  Future<Either<String, List<Podcast>>> deletePodcast(String podcastId);
  Future<Either<String, Podcast>> getPodcastById(String podcastId);
}

class PodcastImpl implements PodcastRepo {
  late final Dio dio;

  PodcastImpl({required this.dio}) {
    dio.options.baseUrl = ApiConsts.base_url;
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);
    dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  @override
  Future<Either<String, List<Podcast>>> getAllPodcasts() async {
    try {
      final response = await dio.get('podcast');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final podcasts = data.map((json) => Podcast.fromJson(json)).toList();
        return Right(podcasts);
      } else {
        return Left('Failed to get podcasts: ${response.statusCode}');
      }
    } catch (e) {
      return Left('Failed to get podcasts: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<Podcast>>> addPodcast(Podcast podcast) async {
    try {
      final response = await dio.post('podcast/upload', data: podcast.toJson());
      if (response.statusCode == 201) {
        return getAllPodcasts();
      } else {
        return Left('Failed to add podcast: ${response.statusCode}');
      }
    } catch (e) {
      return Left('Failed to add podcast: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<Podcast>>> updatePodcast(Podcast podcast) async {
    try {
      final response =
          await dio.put('podcast/${podcast.id}', data: podcast.toJson());
      if (response.statusCode == 200) {
        return getAllPodcasts();
      } else {
        return Left('Failed to update podcast: ${response.statusCode}');
      }
    } catch (e) {
      return Left('Failed to update podcast: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<Podcast>>> deletePodcast(String podcastId) async {
    try {
      final response = await dio.delete('podcast/$podcastId');
      if (response.statusCode == 200) {
        return getAllPodcasts();
      } else {
        return Left('Failed to delete podcast: ${response.statusCode}');
      }
    } catch (e) {
      return Left('Failed to delete podcast: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, Podcast>> getPodcastById(String podcastId) async {
    try {
      final response = await dio.get('podcast/$podcastId');
      if (response.statusCode == 200) {
        final podcast = Podcast.fromJson(response.data);
        return Right(podcast);
      } else {
        return Left('Podcast not found: ${response.statusCode}');
      }
    } catch (e) {
      return Left('Failed to get podcast: ${e.toString()}');
    }
  }
}

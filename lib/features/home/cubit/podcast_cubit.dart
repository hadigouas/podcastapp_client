import 'package:flutter_application_3/features/home/cubit/podcast_state.dart';
import 'package:flutter_application_3/features/home/models/podcast_model.dart';
import 'package:flutter_application_3/features/home/repo/podcast_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

class PodcastCubit extends Cubit<PodcastState> {
  final PodcastRepo _podcastRepo;
  List<Podcast> _allPodcasts = [];
  bool isActive = false;

  PodcastCubit(this._podcastRepo) : super(PodcastInitial());

  Future<void> addPodcast(String name, String author, String audioPath,
      String thumbnailPath, String color) async {
    try {
      emit(PodcastLoading());
      final result = await _podcastRepo.addPodcast(
          name, author, audioPath, thumbnailPath, color);
      result.fold(
        (error) => emit(PodcastFailed(errorMessage: error.message)),
        (successMessage) => emit(PodcastSuccess(successMessage)),
      );
    } catch (e) {
      emit(PodcastFailed(errorMessage: e.toString()));
    }
  }

  Future<void> getAllPodcasts() async {
    try {
      emit(PodcastLoading());
      final result = await _podcastRepo.getAllPodcasts();
      result.fold(
        (error) => emit(PodcastFailed(errorMessage: error.message)),
        (podcastList) {
          _allPodcasts = podcastList;
          emit(PodcastList(podcastList));
        },
      );
    } catch (e) {
      emit(PodcastFailed(errorMessage: e.toString()));
    }
  }

  Future<void> toggleFavorite(String podcastId) async {
    try {
      await _podcastRepo.addFavorite(podcastId);
    } catch (e) {
      emit(PodcastFailed(errorMessage: e.toString()));
    }
  }

  Future<void> getFavorites() async {
    final result = await _podcastRepo.getFavorite();
    result.fold(
      (failure) => emit(PodcastFailed(errorMessage: failure.message)),
      (favoriteList) {
        emit(FavoriteList(favoriteList));
      },
    );
  }

  void searchPodcasts(String query) {
    if (query.isEmpty) {
      emit(PodcastList(
          _allPodcasts)); // Reset to the full list when query is empty
    } else {
      final results = _allPodcasts.where((podcast) {
        final lowerCaseQuery = query.toLowerCase();
        return podcast.name.toLowerCase().contains(lowerCaseQuery) ||
            podcast.author.toLowerCase().contains(lowerCaseQuery);
      }).toList();
      emit(PodcastSearchResults(results)); // Emit search results
    }
  }

  void toggleSclabbar(AudioPlayer audioPlayer, Podcast podcast) {
    isActive = !isActive;
    emit(SclabBar(
        podcast: podcast, audioPlayer: audioPlayer, isActive: isActive));
  }
}

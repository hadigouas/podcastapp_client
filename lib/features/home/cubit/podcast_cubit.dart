import 'package:flutter_application_3/features/home/cubit/podcast_state.dart';
import 'package:flutter_application_3/features/home/models/podcast_model.dart';
import 'package:flutter_application_3/features/home/repo/podcast_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

class PodcastCubit extends Cubit<PodcastState> {
  final PodcastRepo _podcastRepo;
  final List<Podcast> _allPodcasts = [];
  bool isActive = false;

  PodcastCubit(this._podcastRepo) : super(PodcastInitial());

  Future<void> addPodcast(String name, String author, String audioPath,
      String thumbnailPath, String color) async {
    try {
      emit(PodcastLoading());
      final result = await _podcastRepo.addPodcast(
          name, author, audioPath, thumbnailPath, color);
      print(result);
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
      final currentfav = state as CombinedList;
      result.fold(
        (error) => emit(PodcastFailed(errorMessage: error.message)),
        (podcastList) {
          emit(const CombinedList().copyWith(
              podcastList: podcastList, favorites: currentfav.favorites));
        },
      );
    } catch (e) {
      emit(PodcastFailed(errorMessage: e.toString()));
    }
  }

  Future<void> toggleFavorite(String podcastId) async {
    try {
      await _podcastRepo.addFavorite(podcastId);
      getFavorites();
    } catch (e) {
      emit(PodcastFailed(errorMessage: e.toString()));
    }
  }

  Future<void> getFavorites() async {
    final result = await _podcastRepo.getFavorite();
    final currentpodcastlist = state as CombinedList;
    result.fold(
      (failure) => emit(PodcastFailed(errorMessage: failure.message)),
      (favoriteList) {
        emit(const CombinedList().copyWith(
            favorites: favoriteList,
            podcastList: currentpodcastlist.podcastList));
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

import 'package:flutter_application_3/features/home/cubit/podcast_state.dart';
import 'package:flutter_application_3/features/home/repo/podcast_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PodcastCubit extends Cubit<PodcastState> {
  final PodcastRepo _podcastRepo;
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
        (podcastList) => emit(PodcastList(podcastList)),
      );
    } catch (e) {
      emit(PodcastFailed(errorMessage: e.toString()));
    }
  }

  Future<void> updatePodcast(String id, String name, String author,
      String audioPath, String thumbnailPath, String color) async {
    try {
      emit(PodcastLoading());
      final result = await _podcastRepo.updatePodcast(
          id, name, author, audioPath, thumbnailPath, color);

      result.fold(
        (error) => emit(PodcastFailed(errorMessage: error.message)),
        (successMessage) => emit(PodcastSuccess(successMessage)),
      );
    } catch (e) {
      emit(PodcastFailed(errorMessage: e.toString()));
    }
  }

  Future<void> deletePodcast(String podcastId) async {
    try {
      emit(PodcastLoading());
      final result = await _podcastRepo.deletePodcast(podcastId);
      result.fold(
        (error) => emit(PodcastFailed(errorMessage: error.message)),
        (successMessage) => emit(PodcastSuccess(successMessage)),
      );
    } catch (e) {
      emit(PodcastFailed(errorMessage: e.toString()));
    }
  }

  // Future<void> getPodcastById(String podcastId) async {
  //   try {
  //     emit(PodcastLoading());
  //     final result = await _podcastRepo.getPodcastById(podcastId);
  //     result.fold(
  //       (error) => emit(PodcastFailed(errorMessage: error.message)),
  //       (podcast) => emit(PodcastDetailSuccess(podcast)),
  //     );
  //   } catch (e) {
  //     emit(PodcastFailed(errorMessage: e.toString()));
  //   }
  // }
}

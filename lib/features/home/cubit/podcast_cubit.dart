import 'package:flutter_application_3/features/home/cubit/podcast_state.dart';
import 'package:flutter_application_3/features/home/models/podcast_model.dart';
import 'package:flutter_application_3/features/home/repo/podcast_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PodcastCubit extends Cubit<PodcastState> {
  final PodcastRepo _podcastRepo;

  PodcastCubit(this._podcastRepo) : super(PodcastInitial());

  Future<void> addPodcast(Podcast podcast) async {
    try {
      emit(PodcastLoading());
      final result = await _podcastRepo.addPodcast(podcast);
      result.fold(
        (error) => emit(PodcastFailed(errorMessage: error)),
        (podcastList) => emit(PodcastSuccess(podcastList)),
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
        (error) => emit(PodcastFailed(errorMessage: error)),
        (podcastList) => emit(PodcastSuccess(podcastList)),
      );
    } catch (e) {
      emit(PodcastFailed(errorMessage: e.toString()));
    }
  }

  // Implement other methods (updatePodcast, deletePodcast, getPodcastById) similarly
}

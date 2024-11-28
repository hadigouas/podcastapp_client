// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:flutter_application_3/features/home/models/favorite_model.dart';
import 'package:flutter_application_3/features/home/models/podcast_model.dart';
import 'package:just_audio/just_audio.dart';

abstract class PodcastState extends Equatable {
  const PodcastState();

  @override
  List<Object> get props => [];
}

class PodcastInitial extends PodcastState {}

class PodcastLoading extends PodcastState {}

class SclabBar extends PodcastState {
  final Podcast podcast;
  final AudioPlayer audioPlayer;
  final bool isActive;
  const SclabBar({
    required this.isActive,
    required this.podcast,
    required this.audioPlayer,
  });
}

class PodcastList extends PodcastState {
  final List<Podcast> podcastList;

  const PodcastList(this.podcastList);

  @override
  List<Object> get props => [podcastList];
}

class PodcastSearchResults extends PodcastState {
  final List<Podcast> searchResults;

  const PodcastSearchResults(this.searchResults);

  @override
  List<Object> get props => [searchResults];
}

class PodcastSuccess extends PodcastState {
  final String message;

  const PodcastSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class PodcastFailed extends PodcastState {
  final String errorMessage;

  const PodcastFailed({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}

class FavoriteList extends PodcastState {
  final List<Favorite> favorites;

  const FavoriteList(this.favorites);

  @override
  List<Object> get props => [favorites];
}

class FavoriteAdded extends PodcastState {}

class FavoriteRemoved extends PodcastState {}

class CombinedList extends PodcastState {
  final List<Podcast> podcastList;
  final List<Favorite> favorites;

  const CombinedList({
    this.podcastList = const [],
    this.favorites = const [],
  });

  CombinedList copyWith({
    List<Podcast>? podcastList,
    List<Favorite>? favorites,
  }) {
    return CombinedList(
      podcastList: podcastList ?? this.podcastList,
      favorites: favorites ?? this.favorites,
    );
  }

  @override
  List<Object> get props => [podcastList, favorites];
}

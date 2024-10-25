// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
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

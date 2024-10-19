import 'package:equatable/equatable.dart';
import 'package:flutter_application_3/features/home/models/podcast_model.dart';

abstract class PodcastState extends Equatable {
  const PodcastState();

  @override
  List<Object> get props => [];
}

class PodcastInitial extends PodcastState {}

class PodcastLoading extends PodcastState {}

class PodcastSuccess extends PodcastState {
  final List<Podcast> podcastList;

  const PodcastSuccess(this.podcastList);

  @override
  List<Object> get props => [podcastList];
}

class PodcastFailed extends PodcastState {
  final String errorMessage;

  const PodcastFailed({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}

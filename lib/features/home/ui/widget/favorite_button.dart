import 'package:flutter/material.dart';
import 'package:flutter_application_3/features/home/cubit/podcast_cubit.dart';
import 'package:flutter_application_3/features/home/cubit/podcast_state.dart';
import 'package:flutter_application_3/features/home/models/podcast_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoriteButton extends StatefulWidget {
  const FavoriteButton({super.key, required this.podcast});

  final Podcast podcast;

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PodcastCubit, PodcastState>(
      builder: (context, state) {
        final isFavorite =
            state is FavoriteList && state.favorites.contains(widget.podcast);
        return IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.greenAccent : Colors.white,
          ),
          onPressed: () {
            BlocProvider.of<PodcastCubit>(context)
                .toggleFavorite(widget.podcast.id);
          },
        );
      },
    );
  }
}

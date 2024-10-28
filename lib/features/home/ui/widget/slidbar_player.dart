import 'package:flutter/material.dart';
import 'package:flutter_application_3/core/theme/colors.dart';
import 'package:flutter_application_3/features/home/models/podcast_model.dart';
import 'package:just_audio/just_audio.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({
    super.key,
    required this.audioPlayer,
    required this.podcast,
  });

  final AudioPlayer? audioPlayer;
  final Podcast podcast;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.darkBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Album/Track Image
          Container(
            width: 50,
            height: 50,
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[800],
            ),
            child: Image.network(podcast.thumbnailUrl),
          ),

          // Track Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  podcast.name,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  podcast.author,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Control Buttons
          Row(
            children: [
              IconButton(
                icon:
                    const Icon(Icons.play_arrow, color: Colors.white, size: 32),
                onPressed: () {
                  audioPlayer!.play();
                },
              ),
              IconButton(
                icon: const Icon(Icons.pause, color: Colors.white, size: 32),
                onPressed: () {
                  audioPlayer!.pause();
                },
              ),
              IconButton(
                icon: const Icon(Icons.favorite, color: Colors.white, size: 24),
                onPressed: () {
                  // Handle favorite toggle
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

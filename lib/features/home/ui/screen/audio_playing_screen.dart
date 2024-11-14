import 'package:audio_session/audio_session.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/audio_player_service.dart';
import 'package:flutter_application_3/core/theme/textstyle.dart';
import 'package:flutter_application_3/features/home/models/podcast_model.dart';
import 'package:flutter_application_3/features/home/ui/widget/favorite_button.dart';
import 'package:flutter_application_3/navigation_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class PodcastPlayerScreen extends StatefulWidget {
  final Podcast podcast;

  const PodcastPlayerScreen({
    super.key,
    required this.podcast,
  });

  @override
  State<PodcastPlayerScreen> createState() => _PodcastPlayerScreenState();
}

class _PodcastPlayerScreenState extends State<PodcastPlayerScreen>
    with SingleTickerProviderStateMixin {
  final AudioPlayer audioPlayer = getIt<AudioPlayer>(); // Singleton instance
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;
  bool _isInitialized = false;
  late AnimationController _favoriteController;

  @override
  void initState() {
    super.initState();
    _favoriteController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _initializePlayer();
  }

  @override
  void dispose() {
    _favoriteController.dispose();
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.speech());

      if (audioPlayer.audioSource?.toString() != widget.podcast.audioUrl) {
        await audioPlayer.setAudioSource(
          AudioSource.uri(
            Uri.parse(widget.podcast.audioUrl),
            tag: MediaItem(
              id: widget.podcast.id,
              title: widget.podcast.name,
              artist: widget.podcast.author,
              artUri: Uri.parse(widget.podcast.thumbnailUrl),
            ),
          ),
        );
      }

      if (_isPlaying) {
        await audioPlayer.play(); // Resume playback if it's paused
      }

      _setupListeners();
      setState(() => _isInitialized = true);
    } catch (e) {
      _handleError('Failed to load audio source: $e');
    }
  }

  void _setupListeners() {
    audioPlayer.positionStream.listen((position) {
      if (mounted) {
        setState(() => _position = position);
      }
    });

    audioPlayer.durationStream.listen((duration) {
      if (mounted) {
        setState(() => _duration = duration ?? Duration.zero);
      }
    });

    audioPlayer.playingStream.listen((isPlaying) {
      if (mounted) {
        setState(() => _isPlaying = isPlaying);
      }
    });
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await audioPlayer.pause();
    } else {
      await audioPlayer.play();
    }
  }

  void _navigateToNavigationBar() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            MyNavigationBar(
          // Pass the player for state sync
          podcast: widget.podcast,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, -1.0); // Slide down from top to bottom
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0
        ? '$hours:$minutes:$seconds'
        : '$minutes:$seconds';
  }

  void _handleError(String message) {
    debugPrint(message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color podcastColor =
        Color(int.parse(widget.podcast.color.replaceAll('#', '0xff')));

    return Scaffold(
      backgroundColor: podcastColor.withOpacity(0.15),
      appBar: _buildAppBar(podcastColor),
      body: _isInitialized
          ? SafeArea(
              child: Stack(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: CachedNetworkImage(
                      imageUrl: widget.podcast.thumbnailUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Stack(
                        children: [
                          Container(
                            height: 300,
                            width: 300,
                            color: Colors.grey[900],
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: podcastColor.withOpacity(0.8),
                  ),
                  Column(
                    children: [
                      SizedBox(height: 50.h),
                      _buildHeader(),
                      _buildPodcastImage(),
                      _buildPodcastInfo(),
                      SizedBox(height: 50.h),
                      Expanded(
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                width: MediaQuery.of(context)
                                    .size
                                    .width, // Optional: adjust width
                                height: 120.h,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20.0),
                                    topRight: Radius.circular(20.0),
                                  ),
                                ),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                _buildProgressBar(podcastColor),
                                _buildControlButtons(podcastColor),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  PreferredSizeWidget _buildAppBar(Color podcastColor) {
    return AppBar(
      elevation: 0,
      title: Text(
        'Podcast Player',
        style: AppTextStyles.darkBodyText1,
      ),
      centerTitle: true,
      backgroundColor: podcastColor.withOpacity(0.3),
      leading: IconButton(
        icon: const Icon(Icons.keyboard_arrow_down),
        onPressed: _navigateToNavigationBar,
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down),
            color: Colors.white,
            onPressed: _navigateToNavigationBar,
          ),
          Text(
            'NOW PLAYING',
            style: AppTextStyles.darkBodyText2.copyWith(
              color: Colors.white54,
              fontSize: 12,
              letterSpacing: 1.5,
            ),
          ),
          FavoriteButton(podcast: widget.podcast)
        ],
      ),
    );
  }

  Widget _buildPodcastImage() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: CachedNetworkImage(
            imageUrl: widget.podcast.thumbnailUrl,
            placeholder: (context, url) => Container(
              height: 300,
              width: 300,
              color: Colors.grey[900],
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
            errorWidget: (context, url, error) =>
                const Icon(Icons.error, color: Colors.red),
            height: 300,
            width: 300,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildPodcastInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        children: [
          Text(
            widget.podcast.name,
            style: AppTextStyles.darkHeadline1.copyWith(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            widget.podcast.author,
            style: AppTextStyles.darkBodyText2.copyWith(
              color: Colors.white54,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(Color podcastColor) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 25),
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 8),
              activeTrackColor: podcastColor,
              inactiveTrackColor: Colors.black54,
              thumbColor: podcastColor,
              overlayColor: Colors.black54,
            ),
            child: Slider(
              value: _position.inSeconds.toDouble(),
              min: 0,
              max: _duration.inSeconds.toDouble(),
              onChanged: (value) =>
                  audioPlayer.seek(Duration(seconds: value.toInt())),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_position),
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
              Text(
                _formatDuration(_duration),
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControlButtons(Color podcastColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.shuffle),
            color: podcastColor,
            iconSize: 24,
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.skip_previous),
            color: podcastColor,
            iconSize: 40,
            onPressed: () {},
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: podcastColor,
              boxShadow: [
                BoxShadow(
                  color: podcastColor.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
              color: Colors.white,
              iconSize: 40,
              onPressed: _togglePlayPause,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.skip_next),
            color: podcastColor,
            iconSize: 40,
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.repeat),
            color: podcastColor,
            iconSize: 24,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

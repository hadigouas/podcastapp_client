import 'package:audio_session/audio_session.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/core/theme/textstyle.dart';
import 'package:flutter_application_3/features/home/models/podcast_model.dart';
import 'package:flutter_application_3/navigation_bar.dart';
import 'package:just_audio/just_audio.dart';

class PodcastPlayerScreen extends StatefulWidget {
  final Podcast podcast;
  final AudioPlayer? audioPlayer;

  const PodcastPlayerScreen({
    super.key,
    required this.podcast,
    required this.audioPlayer,
  });

  @override
  State<PodcastPlayerScreen> createState() => _PodcastPlayerScreenState();
}

class _PodcastPlayerScreenState extends State<PodcastPlayerScreen>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _errorMessage;
  bool _isLoading = true;
  bool _isInitialized = false;
  bool _isFavorite = false;
  late AnimationController _favoriteController;

  @override
  void initState() {
    super.initState();
    _audioPlayer = widget.audioPlayer ?? AudioPlayer();
    _favoriteController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _initAudioPlayer();
  }

  @override
  void dispose() {
    _favoriteController.dispose();
    super.dispose();
  }

  Future<void> _initAudioPlayer() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.speech());
    } catch (e) {
      _handleError('Failed to initialize audio session: $e');
      return;
    }

    // Listen for changes in playback position and update the UI.
    _audioPlayer.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });

    // Listen for changes in the playback event and update duration and state.
    _audioPlayer.playbackEventStream.listen(
      (event) {
        if (mounted) {
          setState(() {
            _duration = event.duration ?? Duration.zero;
            _isPlaying = _audioPlayer.playing;
          });
        }
      },
      onError: (Object e, StackTrace st) {
        _handleError('Playback error: $e');
      },
    );

    setState(() {
      _isInitialized = true;
    });

    await _loadAudioSource();
  }

  Future<void> _loadAudioSource() async {
    try {
      final audioSource = AudioSource.uri(
        Uri.parse(widget.podcast.audioUrl),
        headers: {'User-Agent': 'YourApp/1.0'},
      );

      await _audioPlayer.setAudioSource(
        audioSource,
        initialPosition: _position,
        preload: true,
      );

      setState(() {
        _isLoading = false;
        _isInitialized = true;
      });
    } catch (e) {
      _handleError('Failed to load audio: $e');
    }
  }

  void _handleError(String message) {
    debugPrint(message);
    if (mounted) {
      setState(() {
        _errorMessage = message;
        _isLoading = false;
        _isInitialized = false;
      });
    }
  }

  Future<void> _togglePlayPause() async {
    if (!_isInitialized) return;

    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play();
      }
    } catch (e) {
      _handleError('Playback control error: $e');
    }
  }

  Future<void> _seekTo(Duration position) async {
    if (!_isInitialized) return;

    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      _handleError('Seek error: $e');
    }
  }

  void _navigateToNavigationBar() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MyNavigationBar(
          audioPlayer: _audioPlayer,
          podcast: widget.podcast,
        ),
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

  @override
  Widget build(BuildContext context) {
    Color podcastColor =
        Color(int.parse(widget.podcast.color.replaceAll('#', '0xff')));

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _navigateToNavigationBar();
        }
      },
      child: Scaffold(
        backgroundColor: podcastColor.withOpacity(0.15),
        appBar: _buildAppBar(podcastColor),
        body: _isLoading
            ? _buildLoadingIndicator()
            : _errorMessage != null
                ? _buildErrorWidget()
                : _buildPlayerWidget(podcastColor),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(Color podcastColor) {
    return AppBar(
      elevation: 0,
      leading: IconButton(
        onPressed: _navigateToNavigationBar,
        icon: const Icon(Icons.arrow_back),
      ),
      title: Text(
        'Now Playing',
        style: AppTextStyles.darkBodyText1,
      ),
      centerTitle: true,
      backgroundColor: podcastColor.withOpacity(0.8),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        color: Colors.white,
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerWidget(Color podcastColor) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          _buildPodcastImage(),
          _buildPodcastInfo(),
          const Spacer(),
          _buildProgressBar(),
          _buildControlButtons(),
          const SizedBox(height: 50),
        ],
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
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.greenAccent : Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPodcastImage() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
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

  Widget _buildProgressBar() {
    return Column(
      children: [
        SliderTheme(
          data: const SliderThemeData(
            trackHeight: 2,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 4),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 8),
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.white24,
            thumbColor: Colors.white,
            overlayColor: Colors.white24,
          ),
          child: Slider(
            value: _position.inSeconds.toDouble(),
            min: 0,
            max: _duration.inSeconds.toDouble(),
            onChanged: (value) => _seekTo(Duration(seconds: value.toInt())),
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
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
              Text(
                _formatDuration(_duration),
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControlButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.shuffle),
            color: Colors.white54,
            iconSize: 24,
            onPressed: () {}, // Add shuffle functionality if needed
          ),
          IconButton(
            icon: const Icon(Icons.skip_previous),
            color: Colors.white,
            iconSize: 40,
            onPressed: () {}, // Add previous track functionality if needed
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
              color: Colors.black,
              iconSize: 40,
              onPressed: _togglePlayPause,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.skip_next),
            color: Colors.white,
            iconSize: 40,
            onPressed: () {}, // Add next track functionality if needed
          ),
          IconButton(
            icon: const Icon(Icons.repeat),
            color: Colors.white54,
            iconSize: 24,
            onPressed: () {}, // Add repeat functionality if needed
          ),
        ],
      ),
    );
  }
}

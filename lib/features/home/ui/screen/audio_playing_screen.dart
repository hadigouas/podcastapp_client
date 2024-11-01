import 'package:audio_session/audio_session.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/core/theme/textstyle.dart';
import 'package:flutter_application_3/features/home/models/audio_managing.dart';
import 'package:flutter_application_3/features/home/models/podcast_model.dart';
import 'package:flutter_application_3/navigation_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  final _audioManager = AudioPlayerManager();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _errorMessage;
  bool _isLoading = true;
  bool _isInitialized = false;
  bool _isFavorite = false;
  late AnimationController _favoriteController;
  String? _currentAudioUrl;

  @override
  void initState() {
    super.initState();
    _favoriteController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _setupAudioPlayer();
  }

  @override
  void dispose() {
    _favoriteController.dispose();
    super.dispose();
  }

  Future<void> _setupAudioPlayer() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.speech());

      _audioPlayer = widget.audioPlayer ??
          await _audioManager.getPlayer(widget.podcast.audioUrl);
      _currentAudioUrl = widget.podcast.audioUrl;

      _setupStreamListeners();

      if (widget.audioPlayer == null ||
          widget.podcast.audioUrl != _currentAudioUrl) {
        await _loadAudioSource();
      } else {
        // If using existing player, just update the state
        setState(() {
          _duration = _audioPlayer.duration ?? Duration.zero;
          _position = _audioPlayer.position;
          _isPlaying = _audioPlayer.playing;
          _isLoading = false;
          _isInitialized = true;
        });
      }
    } catch (e) {
      _handleError('Failed to setup audio player: $e');
    }
  }

  void _setupStreamListeners() {
    _audioPlayer.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });

    // Playback event stream
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
  }

  Future<void> _loadAudioSource() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final audioSource = AudioSource.uri(
        Uri.parse(widget.podcast.audioUrl),
        headers: {'User-Agent': 'YourApp/1.0'},
      );

      await _audioPlayer.setAudioSource(
        audioSource,
        initialPosition: Duration.zero,
        preload: true,
      );

      setState(() {
        _isLoading = false;
        _isInitialized = true;
        _currentAudioUrl = widget.podcast.audioUrl;
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
        'Podcast Player',
        style: AppTextStyles.darkBodyText1,
      ),
      centerTitle: true,
      backgroundColor: podcastColor.withOpacity(0.3),
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

  Widget _buildProgressBar(Color podcastcolor) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 25),
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 8),
              activeTrackColor: podcastcolor,
              inactiveTrackColor: Colors.black54,
              thumbColor: podcastcolor,
              overlayColor: Colors.black54,
            ),
            child: Slider(
              value: _position.inSeconds.toDouble(),
              min: 0,
              max: _duration.inSeconds.toDouble(),
              onChanged: (value) => _seekTo(Duration(seconds: value.toInt())),
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

  Widget _buildControlButtons(Color podcastcolor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.shuffle),
            color: podcastcolor,
            iconSize: 24,
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.skip_previous),
            color: podcastcolor,
            iconSize: 40,
            onPressed: () {},
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: podcastcolor,
              boxShadow: [
                BoxShadow(
                  color: podcastcolor.withOpacity(0.2),
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
            color: podcastcolor,
            iconSize: 40,
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.repeat),
            color: podcastcolor,
            iconSize: 24,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

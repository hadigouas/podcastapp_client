import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/core/theme/colors.dart';
import 'package:flutter_application_3/core/theme/textstyle.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UploadTextfield extends StatefulWidget {
  const UploadTextfield({
    super.key,
    required this.hinttext,
    this.isAudio = false,
  });
  final String hinttext;
  final bool isAudio;

  @override
  _UploadTextfieldState createState() => _UploadTextfieldState();
}

class _UploadTextfieldState extends State<UploadTextfield> {
  final TextEditingController _controller = TextEditingController();
  String? _audioFilePath;
  PlayerController? _playerController;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    if (widget.isAudio) {
      _playerController = PlayerController();
    }
  }

  Future<void> _pickAudioFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );
      if (result != null) {
        setState(() {
          _audioFilePath = result.files.single.path;
          _controller.text = result.files.single.name;
        });
        if (_playerController != null && _audioFilePath != null) {
          await _playerController!.preparePlayer(
            path: _audioFilePath!,
            shouldExtractWaveform: true,
            noOfSamples: 100,
            volume: 1.0,
          );
        }
      } else {
        print('No audio file selected');
      }
    } catch (e) {
      print('Error picking audio file: $e');
    }
  }

  Future<void> _togglePlayPause() async {
    if (_playerController != null) {
      if (_isPlaying) {
        await _playerController!.pausePlayer();
      } else {
        await _playerController!.startPlayer();
      }
      setState(() {
        _isPlaying = !_isPlaying;
      });
    }
  }

  void _deleteAudio() {
    setState(() {
      _audioFilePath = null;
      _controller.clear();
      _isPlaying = false;
    });
    _playerController?.stopAllPlayers();
    _playerController?.dispose();
    _playerController = PlayerController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _playerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isAudio && _audioFilePath != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.hinttext,
            style: AppTextStyles.darkBodyText2.copyWith(fontSize: 16),
          ),
          SizedBox(height: 8.h),
          Container(
            height: 100.h,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.darkTextSecondaryColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: AppColors.gradientStart,
                  ),
                  onPressed: _togglePlayPause,
                ),
                Expanded(
                  child: AudioFileWaveforms(
                    backgroundColor: AppColors.gradientStart,
                    size: Size(MediaQuery.of(context).size.width - 120, 80.h),
                    playerController: _playerController!,
                    enableSeekGesture: true,
                    waveformType: WaveformType.fitWidth,
                    playerWaveStyle: const PlayerWaveStyle(
                      fixedWaveColor: AppColors.gradientStart,
                      liveWaveColor: AppColors.gradientEnd,
                      spacing: 6,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: AppColors.gradientStart,
                  ),
                  onPressed: _deleteAudio,
                ),
              ],
            ),
          ),
        ],
      );
    }

    return TextFormField(
      controller: _controller,
      readOnly: widget.isAudio,
      validator: (val) {
        if (val!.trim().isEmpty) {
          return "${widget.hinttext} is missing!";
        }
        return null;
      },
      style: AppTextStyles.darkBodyText2,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(30),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(width: 1.w, color: AppColors.gradientStart),
        ),
        hintText: widget.hinttext,
        hintStyle: AppTextStyles.darkBodyText2.copyWith(fontSize: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide:
              BorderSide(width: 1.w, color: AppColors.darkTextSecondaryColor),
        ),
        suffixIcon: widget.isAudio
            ? IconButton(
                icon: const Icon(Icons.audio_file,
                    color: AppColors.gradientStart),
                onPressed: _pickAudioFile,
              )
            : null,
      ),
    );
  }
}

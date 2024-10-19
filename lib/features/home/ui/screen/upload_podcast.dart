import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/core/theme/colors.dart';
import 'package:flutter_application_3/core/theme/textstyle.dart';
import 'package:flutter_application_3/features/home/cubit/podcast_cubit.dart';
import 'package:flutter_application_3/features/home/cubit/podcast_state.dart';
import 'package:flutter_application_3/features/home/models/podcast_model.dart';
import 'package:flutter_application_3/features/home/ui/widget/upload_textfiled.dart';
import 'package:flutter_application_3/features/home/ui/widget/upload_thumbnail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UploadPodcast extends StatefulWidget {
  const UploadPodcast({super.key});

  @override
  State<UploadPodcast> createState() => _UploadPodcastState();
}

class _UploadPodcastState extends State<UploadPodcast> {
  late Color screenPickerColor;
  late TextEditingController authorController;
  late TextEditingController podcastNameController;
  late TextEditingController audioController;
  String? thumbnailPath;
  String? audioPath;

  @override
  void initState() {
    super.initState();
    screenPickerColor = Colors.blue;
    authorController = TextEditingController();
    podcastNameController = TextEditingController();
    audioController = TextEditingController();
  }

  @override
  void dispose() {
    authorController.dispose();
    podcastNameController.dispose();
    audioController.dispose();
    super.dispose();
  }

  void _onThumbnailChanged(String? path) {
    setState(() {
      thumbnailPath = path;
    });
  }

  void _onAudioPathChanged(String? path) {
    setState(() {
      audioPath = path;
    });
  }

  Podcast _createPodcast() {
    return Podcast(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: podcastNameController.text,
      author: authorController.text,
      audioUrl: audioPath ?? '',

      thumbnailUrl: thumbnailPath!,
      // Add other necessary fields
    );
  }

  void _uploadPodcast() {
    final podcast = _createPodcast();
    BlocProvider.of<PodcastCubit>(context).addPodcast(podcast);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PodcastCubit, PodcastState>(
      listener: (context, state) {
        if (state is PodcastSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Podcast uploaded successfully!')),
          );
          Navigator.pop(context);
        } else if (state is PodcastFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Failed to upload podcast: ${state.errorMessage}')),
          );
        }
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.darkBackgroundColor,
            title: Text(
              "Upload Podcast",
              style: AppTextStyles.darkHeadline2.copyWith(color: Colors.white),
            ),
            centerTitle: true,
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
              color: Colors.white,
            ),
            actions: [
              TextButton(
                onPressed: _uploadPodcast,
                child: Text(
                  "Upload",
                  style: AppTextStyles.darkBodyText2,
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 30,
              horizontal: 10,
            ),
            child: ListView(
              children: [
                UploadThumbnail(onThumbnailChanged: _onThumbnailChanged),
                SizedBox(height: 30.h),
                UploadTextfield(
                  hinttext: "Pick a Podcast",
                  isAudio: true,
                  controller: audioController,
                  onAudioPathChanged: _onAudioPathChanged,
                ),
                SizedBox(height: 30.h),
                UploadTextfield(
                  hinttext: "Author",
                  controller: authorController,
                ),
                SizedBox(height: 30.h),
                UploadTextfield(
                  hinttext: "Podcast Name",
                  controller: podcastNameController,
                ),
                SizedBox(height: 30.h),
                Card(
                  elevation: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 54, 51, 51),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: ColorPicker(
                      color: screenPickerColor,
                      onColorChanged: (Color color) =>
                          setState(() => screenPickerColor = color),
                      width: 40.w,
                      height: 40.h,
                      borderRadius: 22,
                      heading: Text(
                        'Select color',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                        ),
                      ),
                      subheading: Text(
                        'Select color shade',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14.sp,
                        ),
                      ),
                      pickersEnabled: const <ColorPickerType, bool>{
                        ColorPickerType.wheel: true,
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

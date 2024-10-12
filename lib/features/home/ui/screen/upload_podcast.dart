import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/core/theme/colors.dart';
import 'package:flutter_application_3/core/theme/textstyle.dart';
import 'package:flutter_application_3/features/home/ui/widget/upload_textfiled.dart';
import 'package:flutter_application_3/features/home/ui/widget/upload_thumbnail.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UploadPodcast extends StatefulWidget {
  const UploadPodcast({super.key});

  @override
  State<UploadPodcast> createState() => _UploadPodcastState();
}

class _UploadPodcastState extends State<UploadPodcast> {
  late Color screenPickerColor;
  late Color dialogPickerColor;
  late Color dialogSelectColor;

  @override
  void initState() {
    super.initState();
    screenPickerColor = Colors.blue; // Material blue.
    dialogPickerColor = Colors.red; // Material red.
    dialogSelectColor = const Color(0xFFA239CA);
    // A purple color.
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                onPressed: () {},
                child: Text(
                  "Upload",
                  style: AppTextStyles.darkBodyText2,
                ))
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 30,
            horizontal: 10,
          ),
          child: ListView(
            children: [
              const UploadThumbnail(),
              SizedBox(height: 30.h),
              const UploadTextfield(hinttext: "Pick a Podcast"),
              SizedBox(height: 30.h),
              const UploadTextfield(hinttext: "Author"),
              SizedBox(height: 30.h),
              const UploadTextfield(hinttext: "Podcast Name"),
              SizedBox(height: 30.h),
              Card(
                elevation: 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors
                        .darkBackgroundColor, // Custom background color
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.all(8), // Padding inside the container
                  child: ColorPicker(
                    // Use the screenPickerColor as start and active color.
                    color: screenPickerColor,
                    // Update the screenPickerColor using the callback.
                    onColorChanged: (Color color) =>
                        setState(() => screenPickerColor = color),
                    width: 40.w,
                    height: 40.h,
                    borderRadius: 22,
                    heading: Text(
                      'Select color',
                      style: TextStyle(
                        color: Colors.white, // Make heading text white
                        fontSize: 18.sp, // Adjust heading font size
                      ),
                    ),
                    subheading: Text(
                      'Select color shade',
                      style: TextStyle(
                        color: Colors.white70, // Make subheading text lighter
                        fontSize: 14.sp, // Adjust subheading font size
                      ),
                    ),

                    pickersEnabled: const <ColorPickerType, bool>{
                      ColorPickerType.wheel: true, // Enable wheel color picker
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

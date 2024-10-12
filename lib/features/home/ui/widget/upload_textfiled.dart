import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/core/theme/colors.dart';
import 'package:flutter_application_3/core/theme/textstyle.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UploadTextfield extends StatefulWidget {
  const UploadTextfield({
    super.key,
    required this.hinttext,
  });

  final String hinttext;

  @override
  _UploadTextfieldState createState() => _UploadTextfieldState();
}

class _UploadTextfieldState extends State<UploadTextfield> {
  final TextEditingController _controller = TextEditingController();
  String? _audioFilePath;

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
      } else {
        print('No audio file selected');
      }
    } catch (e) {
      print('Error picking audio file: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      readOnly: true,
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
        suffixIcon: IconButton(
          icon: const Icon(Icons.audio_file, color: AppColors.gradientStart),
          onPressed: _pickAudioFile,
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/core/classes/file_picker.dart';
import 'package:flutter_application_3/core/theme/colors.dart';
import 'package:flutter_application_3/core/theme/textstyle.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:r_dotted_line_border/r_dotted_line_border.dart';

class UploadThumbnail extends StatefulWidget {
  final Function(String?) onThumbnailChanged;

  const UploadThumbnail({super.key, required this.onThumbnailChanged});

  @override
  State<UploadThumbnail> createState() => _UploadThumbnailState();
}

class _UploadThumbnailState extends State<UploadThumbnail> {
  String? _thumbnailPath;

  Future<void> _pickImage() async {
    final FilePickerResult? result = await FilePickerHelper().pickPictureFile();
    if (result != null) {
      setState(() {
        _thumbnailPath = result.files.single.path;
      });
      widget.onThumbnailChanged(_thumbnailPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: _thumbnailPath == null ? 100.h : 200.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: _thumbnailPath == null
              ? RDottedLineBorder.all(
                  width: 1,
                  color: AppColors.darkTextSecondaryColor,
                )
              : null,
          image: _thumbnailPath != null
              ? DecorationImage(
                  image: FileImage(File(_thumbnailPath!)),
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                )
              : null,
        ),
        child: _thumbnailPath == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add_a_photo,
                      color: AppColors.darkTextSecondaryColor,
                    ),
                    Text(
                      "Upload the podcast thumbnail",
                      style: AppTextStyles.darkBodyText2,
                    ),
                  ],
                ),
              )
            : Align(
                alignment: Alignment.bottomRight,
                child: IconButton(
                    onPressed: () {
                      setState(() {
                        _thumbnailPath = null;
                      });
                      widget.onThumbnailChanged(null);
                    },
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    )),
              ),
      ),
    );
  }
}

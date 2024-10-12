import 'package:flutter/material.dart';
import 'package:flutter_application_3/core/theme/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/textstyle.dart';

class MyTextFormField extends StatefulWidget {
  const MyTextFormField({
    super.key,
    required this.hinttext,
    required this.labletext,
    this.obscuretext,
    required this.controller,
  });

  final TextEditingController controller;
  final String hinttext;
  final String labletext;
  final bool? obscuretext;

  @override
  _MyTextFormFieldState createState() => _MyTextFormFieldState();
}

class _MyTextFormFieldState extends State<MyTextFormField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText =
        widget.obscuretext ?? false; // Default to false if not provided
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: (val) {
        if (val!.trim().isEmpty) {
          return "${widget.hinttext} is missing!";
        }
        return null;
      },
      style: AppTextStyles.darkBodyText2,
      controller: widget.controller,
      obscureText: _obscureText, // Controls the text visibility
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(20),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(width: 1.w, color: AppColors.gradientStart),
        ),
        label: Text(
          widget.labletext,
          style: AppTextStyles.darkBodyText1,
        ),
        hintText: widget.hinttext,
        hintStyle: AppTextStyles.darkBodyText2,
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide:
              BorderSide(width: 1.w, color: AppColors.darkTextSecondaryColor),
        ),
        // Add the eye icon if obscuretext is not null
        suffixIcon: widget.obscuretext != null
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText; // Toggle obscureText state
                  });
                },
              )
            : null, // No icon if it's not a password field
      ),
    );
  }
}

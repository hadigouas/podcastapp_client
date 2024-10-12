import 'package:flutter/material.dart';
import 'package:flutter_application_3/core/theme/colors.dart';
import 'package:flutter_application_3/core/theme/textstyle.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppButton extends StatelessWidget {
  const AppButton({super.key, required this.text, this.function});
  final String text;
  final VoidCallback? function;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: function,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 40.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
              colors: [AppColors.gradientStart, AppColors.gradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
        ),
        child: Center(
          child: Text(
            text,
            style: AppTextStyles.darkBodyText1,
          ),
        ),
      ),
    );
  }
}

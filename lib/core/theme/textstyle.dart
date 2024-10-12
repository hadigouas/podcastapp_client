import 'package:flutter/material.dart';
import 'package:flutter_application_3/core/theme/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  // Light Theme Text Styles
  static TextStyle lightHeadline1 = GoogleFonts.roboto(
    fontSize: 32.sp,
    fontWeight: FontWeight.bold,
    color: AppColors.lightTextPrimaryColor,
  );

  static TextStyle lightHeadline2 = GoogleFonts.roboto(
    fontSize: 24.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.lightTextPrimaryColor,
  );

  static TextStyle lightBodyText1 = GoogleFonts.roboto(
    fontSize: 16.sp,
    color: AppColors.lightTextPrimaryColor,
  );

  static TextStyle lightBodyText2 = GoogleFonts.roboto(
    fontSize: 14.sp,
    color: AppColors.lightTextSecondaryColor,
  );

  static TextStyle lightButton = GoogleFonts.roboto(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  // Dark Theme Text Styles
  static TextStyle darkHeadline1 = GoogleFonts.roboto(
    fontSize: 32.sp,
    fontWeight: FontWeight.bold,
    color: AppColors.darkTextPrimaryColor,
  );

  static TextStyle darkHeadline2 = GoogleFonts.roboto(
    fontSize: 24.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.darkTextPrimaryColor,
  );

  static TextStyle darkBodyText1 = GoogleFonts.roboto(
    fontSize: 16.sp,
    color: AppColors.darkTextPrimaryColor,
  );

  static TextStyle darkBodyText2 = GoogleFonts.roboto(
    fontSize: 14.sp,
    color: AppColors.darkTextSecondaryColor,
  );

  static TextStyle darkButton = GoogleFonts.roboto(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );
}

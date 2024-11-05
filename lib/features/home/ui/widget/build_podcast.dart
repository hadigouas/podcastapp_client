import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/core/theme/textstyle.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget buildPodcastCard(BuildContext context, podcast,
    {required VoidCallback onTap}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10.0),
    child: SizedBox(
      width: 130.w,
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                fit: BoxFit.fill,
                imageUrl: podcast.thumbnailUrl,
                width: 120.w,
                height: 100.h,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          ),
          Text(
            podcast.name,
            style: AppTextStyles.darkBodyText1,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            podcast.author,
            style: AppTextStyles.darkBodyText2,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}

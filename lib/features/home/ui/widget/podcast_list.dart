import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/core/theme/textstyle.dart';
import 'package:flutter_application_3/features/auth/model/user_auth_modules.dart';
import 'package:flutter_application_3/features/home/models/podcast_model.dart';
import 'package:flutter_application_3/features/home/ui/screen/audio_playing_screen.dart';
import 'package:flutter_application_3/features/home/ui/widget/build_podcast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PodcastListWidget extends StatelessWidget {
  final List<Podcast> podcasts;
  final User user;

  const PodcastListWidget({
    super.key,
    required this.podcasts,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final shuffledList = List.of(podcasts)..shuffle();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Good Evening",
                    style: AppTextStyles.darkBodyText2,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    user.name!,
                    style: AppTextStyles.darkHeadline2,
                  ),
                ],
              ),
              const CircleAvatar(
                radius: 30,
                child: Center(
                  child: Icon(
                    Icons.person,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "Latest update",
            style: AppTextStyles.darkHeadline1,
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 160.h,
            width: MediaQuery.of(context).size.width,
            child: ListView.builder(
              itemCount: 5,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return buildPodcastCard(
                  context,
                  podcasts[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PodcastPlayerScreen(
                          podcast: podcasts[index],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Recommended for you",
            style: AppTextStyles.darkHeadline2,
          ),
          SizedBox(
            height: 160.h,
            width: MediaQuery.of(context).size.width,
            child: ListView.builder(
              itemCount: 5,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return buildPodcastCard(
                  context,
                  shuffledList[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PodcastPlayerScreen(
                          podcast: shuffledList[index],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: podcasts.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PodcastPlayerScreen(
                        podcast: podcasts[index],
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: podcasts[index].thumbnailUrl,
                          width: 60.w,
                          height: 60.h,
                          fit: BoxFit.fill,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            podcasts[index].name,
                            style: AppTextStyles.darkBodyText1,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            podcasts[index].author,
                            style: AppTextStyles.darkBodyText2,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

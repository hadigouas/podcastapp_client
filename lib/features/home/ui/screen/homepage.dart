import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/core/theme/colors.dart';
import 'package:flutter_application_3/core/theme/textstyle.dart';
import 'package:flutter_application_3/features/auth/model/user_auth_modules.dart';
import 'package:flutter_application_3/features/home/cubit/podcast_cubit.dart';
import 'package:flutter_application_3/features/home/cubit/podcast_state.dart';
import 'package:flutter_application_3/features/home/ui/screen/audio_playing_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyHomePage extends StatefulWidget {
  final User user;
  const MyHomePage({
    super.key,
    required this.user,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    BlocProvider.of<PodcastCubit>(context).getAllPodcasts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.darkBackgroundColor,
        ),
        body: BlocBuilder<PodcastCubit, PodcastState>(
          builder: (context, state) {
            if (state is PodcastList) {
              final shuffledList = List.of(state.podcastList)..shuffle();

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text(
                              "   good Evening",
                              style: AppTextStyles.darkBodyText2,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              widget.user.name!,
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
                        )
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
                        itemCount: state.podcastList.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PodcastPlayerScreen(
                                          audioPlayer: null,
                                          podcast: state.podcastList[index],
                                        ),
                                      ),
                                    );
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          state.podcastList[index].thumbnailUrl,
                                      width: 120.w,
                                      height: 100.h,
                                      placeholder: (context, url) =>
                                          const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                state.podcastList[index].name,
                                style: AppTextStyles.darkBodyText1,
                              ),
                              Text(
                                state.podcastList[index].author,
                                style: AppTextStyles.darkBodyText2,
                              ),
                            ],
                          );
                        },
                        scrollDirection: Axis.horizontal,
                      ),
                    ),
                    Text(
                      "Recommended for you",
                      style: AppTextStyles.darkHeadline2,
                    ),
                    SizedBox(
                      height: 160.h,
                      width: MediaQuery.of(context).size.width,
                      child: ListView.builder(
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PodcastPlayerScreen(
                                          audioPlayer: null,
                                          podcast: shuffledList[index],
                                        ),
                                      ),
                                    );
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          shuffledList[index].thumbnailUrl,
                                      width: 120.w,
                                      height: 100.h,
                                      placeholder: (context, url) =>
                                          const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                shuffledList[index].name,
                                style: AppTextStyles.darkBodyText1,
                              ),
                              Text(
                                shuffledList[index].author,
                                style: AppTextStyles.darkBodyText2,
                              ),
                            ],
                          );
                        },
                        scrollDirection: Axis.horizontal,
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is PodcastFailed) {
              return Center(
                child: Text(
                  state.errorMessage,
                  style: AppTextStyles.darkHeadline1,
                ),
              );
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}

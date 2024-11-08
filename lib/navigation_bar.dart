import 'package:flutter/material.dart';
import 'package:flutter_application_3/core/theme/colors.dart';
import 'package:flutter_application_3/features/auth/cubit/cubit/user_auth_cubit.dart';
import 'package:flutter_application_3/features/auth/model/user_auth_modules.dart';
import 'package:flutter_application_3/features/home/models/podcast_model.dart';
import 'package:flutter_application_3/features/home/ui/screen/homepage.dart';
import 'package:flutter_application_3/features/home/ui/widget/mini_player.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';

import 'audio_player_service.dart'; // Import the service locator setup

class MyNavigationBar extends StatefulWidget {
  const MyNavigationBar({
    super.key,
    required this.podcast,
  });

  final Podcast? podcast;

  @override
  State<MyNavigationBar> createState() => _MyNavigationBarState();
}

class _MyNavigationBarState extends State<MyNavigationBar> {
  int _selectedIndex = 0;
  final AudioPlayer audioPlayer =
      getIt<AudioPlayer>(); // Get singleton instance

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<UserAuthCubit, UserAuthState>(
        builder: (context, state) {
          User? user;

          if (state is UserAuthSuccess) {
            user = state.user;
          }

          final List<Widget> pages = <Widget>[
            MyHomePage(user: user!), // Pass the user to MyHomePage
            const Center(
                child: Text('Library Screen', style: TextStyle(fontSize: 24))),
          ];

          return Stack(
            children: [
              pages[_selectedIndex],
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.podcast != null)
                      MiniPlayer(
                        podcast: widget.podcast!,
                      ),
                    const SizedBox(height: 8),
                    NavigationBarTheme(
                      data: NavigationBarThemeData(
                        labelTextStyle: WidgetStateProperty.all(
                          const TextStyle(color: Colors.white),
                        ),
                      ),
                      child: NavigationBar(
                        height: 30.h,
                        backgroundColor: AppColors.darkBackgroundColor,
                        indicatorColor: AppColors.darkTextSecondaryColor,
                        selectedIndex: _selectedIndex,
                        onDestinationSelected: _onItemTapped,
                        destinations: const [
                          NavigationDestination(
                            icon: Icon(
                              Icons.home,
                              color: Colors.white,
                            ),
                            label: 'Home',
                          ),
                          NavigationDestination(
                            icon:
                                Icon(Icons.library_books, color: Colors.white),
                            label: 'Library',
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

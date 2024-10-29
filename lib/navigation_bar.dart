import 'package:flutter/material.dart';
import 'package:flutter_application_3/core/theme/colors.dart';
import 'package:flutter_application_3/features/home/models/podcast_model.dart';
import 'package:flutter_application_3/features/home/ui/screen/homepage.dart';
import 'package:flutter_application_3/features/home/ui/widget/mini_player.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';

class MyNavigationBar extends StatefulWidget {
  const MyNavigationBar({
    super.key,
    required this.audioPlayer,
    required this.podcast,
  });

  final AudioPlayer? audioPlayer;
  final Podcast? podcast;

  @override
  State<MyNavigationBar> createState() => _MyNavigationBarState();
}

class _MyNavigationBarState extends State<MyNavigationBar> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    MyHomePage(),
    Center(child: Text('Library Screen', style: TextStyle(fontSize: 24))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _pages[_selectedIndex],
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.podcast != null)
                  MiniPlayer(
                    audioPlayer: widget.audioPlayer,
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
                    height: 50.h,
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
                        icon: Icon(Icons.library_books, color: Colors.white),
                        label: 'Library',
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_application_3/core/theme/colors.dart';
import 'package:flutter_application_3/features/home/cubit/podcast_cubit.dart';
import 'package:flutter_application_3/features/home/cubit/podcast_state.dart';
import 'package:flutter_application_3/features/home/ui/screen/homepage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyNavigationBar extends StatefulWidget {
  const MyNavigationBar({super.key});

  @override
  State<MyNavigationBar> createState() => _MyNavigationBarState();
}

class _MyNavigationBarState extends State<MyNavigationBar> {
  int _selectedIndex = 0;
  static const List<Widget> _pages = <Widget>[
    MyHomePage(),
    Center(
      child: Text(
        'Library Screen',
        style: TextStyle(fontSize: 24),
      ),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PodcastCubit, PodcastState>(
        builder: (context, state) {
          if (state is SclabBar) {
            return Stack(
              children: [
                // Main content
                _pages[_selectedIndex],

                // Bottom container with slider and navigation
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Sliding panel
                      Container(
                        height: 70,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.darkBackgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Album/Track Image
                            Container(
                              width: 50,
                              height: 50,
                              margin: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[800],
                              ),
                              child: const Icon(
                                Icons.music_note,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            // Track Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Track Name',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Artist Name',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            // Control Buttons
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  onPressed: () {
                                    // Handle previous
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                  onPressed: () {
                                    // Handle play/pause
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.favorite,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  onPressed: () {
                                    // Handle next
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Space between slider and navigation bar
                      const SizedBox(height: 8),

                      // Navigation bar
                      Theme(
                        data: Theme.of(context).copyWith(
                          navigationBarTheme: NavigationBarThemeData(
                            labelTextStyle:
                                WidgetStateProperty.resolveWith<TextStyle>(
                              (Set<WidgetState> states) {
                                if (states.contains(WidgetState.selected)) {
                                  return const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  );
                                }
                                return const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                );
                              },
                            ),
                          ),
                        ),
                        child: NavigationBar(
                          indicatorColor: AppColors.darkBackgroundColor,
                          backgroundColor: AppColors.darkBackgroundColor,
                          selectedIndex: _selectedIndex,
                          onDestinationSelected: _onItemTapped,
                          labelBehavior:
                              NavigationDestinationLabelBehavior.alwaysShow,
                          height: 65,
                          surfaceTintColor: Colors.transparent,
                          destinations: const <NavigationDestination>[
                            NavigationDestination(
                              icon: Icon(
                                Icons.home_outlined,
                                color: Colors.white,
                              ),
                              selectedIcon: Icon(
                                Icons.home,
                                color: Colors.white,
                              ),
                              label: 'Home',
                            ),
                            NavigationDestination(
                              icon: Icon(
                                Icons.library_books_outlined,
                                color: Colors.white,
                              ),
                              selectedIcon: Icon(
                                Icons.library_books,
                                color: Colors.white,
                              ),
                              label: 'Library',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return Stack(
              children: [
                // Main content
                _pages[_selectedIndex],

                // Navigation bar
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      navigationBarTheme: NavigationBarThemeData(
                        labelTextStyle:
                            WidgetStateProperty.resolveWith<TextStyle>(
                          (Set<WidgetState> states) {
                            if (states.contains(WidgetState.selected)) {
                              return const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              );
                            }
                            return const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            );
                          },
                        ),
                      ),
                    ),
                    child: NavigationBar(
                      indicatorColor: AppColors.darkBackgroundColor,
                      backgroundColor: AppColors.darkBackgroundColor,
                      selectedIndex: _selectedIndex,
                      onDestinationSelected: _onItemTapped,
                      labelBehavior:
                          NavigationDestinationLabelBehavior.alwaysShow,
                      height: 65,
                      surfaceTintColor: Colors.transparent,
                      destinations: const <NavigationDestination>[
                        NavigationDestination(
                          icon: Icon(
                            Icons.home_outlined,
                            color: Colors.white,
                          ),
                          selectedIcon: Icon(
                            Icons.home,
                            color: Colors.white,
                          ),
                          label: 'Home',
                        ),
                        NavigationDestination(
                          icon: Icon(
                            Icons.library_books_outlined,
                            color: Colors.white,
                          ),
                          selectedIcon: Icon(
                            Icons.library_books,
                            color: Colors.white,
                          ),
                          label: 'Library',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

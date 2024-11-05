import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_3/features/auth/model/user_auth_modules.dart';
import 'package:flutter_application_3/features/home/cubit/podcast_cubit.dart';
import 'package:flutter_application_3/features/home/cubit/podcast_state.dart';
import 'package:flutter_application_3/features/home/ui/widget/podcast_list.dart';
import 'package:flutter_application_3/features/home/ui/widget/podcast_search.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    BlocProvider.of<PodcastCubit>(context).getAllPodcasts();
    _searchController.addListener(_onSearchChanged);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final query = _searchController.text;
      if (query.isEmpty) {
        BlocProvider.of<PodcastCubit>(context).getAllPodcasts();
      } else {
        BlocProvider.of<PodcastCubit>(context).searchPodcasts(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(width: 3, color: Colors.purple),
                  ),
                  border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      borderSide: BorderSide(width: 3, color: Colors.purple)),
                  labelText: 'Search Podcasts',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            BlocProvider.of<PodcastCubit>(context)
                                .getAllPodcasts();
                          },
                        )
                      : null,
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<PodcastCubit, PodcastState>(
                builder: (context, state) {
                  if (state is PodcastList) {
                    return PodcastListWidget(
                      podcasts: state.podcastList,
                      user: widget.user,
                    );
                  } else if (state is PodcastSearchResults) {
                    return PodcastSearchResultsWidget(
                      searchResults: state.searchResults,
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

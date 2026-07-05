import 'package:flutter/material.dart';
import 'package:peng_houth_cycle/core/enum/app_state.dart';
import 'package:peng_houth_cycle/features/home/presentation/providers/home_provider.dart';
import 'package:peng_houth_cycle/features/home/presentation/widgets/home_draggable_scrollable_sheet.dart';
import 'package:peng_houth_cycle/features/home/presentation/widgets/home_google_map.dart';
import 'package:peng_houth_cycle/features/home/presentation/widgets/home_search.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();

    return Scaffold(
      body: Stack(
        children: [
          const HomeGoogleMap(),

          // ── Search bar, like Google Maps top pill ──
          const HomeSearch(),

          // ── Floating locate-me button, bottom right ──
          Positioned(
            right: 16,
            bottom: 180,
            child: FloatingActionButton.small(
              heroTag: 'locate_me',
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
              onPressed: provider.goToMyLocation,
              child: const Icon(Icons.my_location),
            ),
          ),

          // ── Draggable bottom sheet with station list ──
          const HomeDraggableScrollableSheet(),

          if (provider.state == AppState.loading)
            const Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 120),
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

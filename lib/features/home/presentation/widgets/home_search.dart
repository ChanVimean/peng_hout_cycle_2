import 'package:flutter/material.dart';
import 'package:peng_houth_cycle/core/widgets/app_search_suggestion_bar.dart';
import 'package:peng_houth_cycle/features/home/data/models/station_model.dart';
import 'package:peng_houth_cycle/features/home/presentation/helpers/home_open_station_helper.dart';
import 'package:peng_houth_cycle/features/home/presentation/providers/home_provider.dart';
import 'package:provider/provider.dart';

class HomeSearch extends StatefulWidget {
  const HomeSearch({super.key});

  @override
  State<HomeSearch> createState() => _HomeSearchState();
}

class _HomeSearchState extends State<HomeSearch> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final stations = provider.filtered(
      stations: provider.stations,
      query: _query,
    );

    return SafeArea(
      child: AppSearchSuggestionBar<StationModel>(
        controller: _searchController,
        hint: 'Search stations',
        query: _query,
        suggestions: stations, // already filtered by _filtered()
        itemBuilder: (context, s) => ListTile(
          dense: true,
          leading: Icon(
            Icons.pedal_bike,
            color: s.status == 'normal' ? Colors.green : Colors.red,
          ),
          title: Text(s.name),
          subtitle: Text(
            s.address,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text('${s.bikesCount}/${s.capacity}'),
        ),
        onChanged: (value) => setState(() => _query = value),
        onSelected: (stationModel) {
          FocusScope.of(context).unfocus(); // close keyboard
          _searchController.clear();
          setState(() => _query = '');
          homeOpenStationHelper(context, stationModel: stationModel);
        },
        onClear: () {
          _searchController.clear();
          setState(() => _query = '');
        },
      ),
    );
  }
}

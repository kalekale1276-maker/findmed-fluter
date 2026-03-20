import 'package:flutter/material.dart';

class FacilitySearchDelegate extends SearchDelegate<String> {
  final Function(String) onSearch;
  final VoidCallback onFilter;

  FacilitySearchDelegate({
    required this.onSearch,
    required this.onFilter,
  });

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.filter_list),
        onPressed: onFilter,
        tooltip: 'Filters',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, ''); // Fixed: Added required second parameter
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // When user submits search, pass the query to onSearch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onSearch(query);
    });
    return Center(
      child: Text('Searching for "$query"...'),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Show suggestions while typing
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Search for hospitals or pharmacies',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    // Show recent searches or suggestions
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.history),
          title: Text('Search for "$query"'),
          onTap: () {
            onSearch(query);
            close(context, query);
          },
        ),
      ],
    );
  }

  @override
  void showResults(BuildContext context) {
    super.showResults(context);
    // Trigger search when showing results
    onSearch(query);
  }
}
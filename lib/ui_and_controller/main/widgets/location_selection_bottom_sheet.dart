import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/response/nominatim_search_response_model.dart';
import '../../../services/nominatim_api_service.dart';
import '../../../utils/theme_manager.dart';

class LocationSelectionBottomSheet extends StatefulWidget {
  final Function(String placeId, String description, double latitude, double longitude) onLocationSelected;

  const LocationSelectionBottomSheet({
    super.key,
    required this.onLocationSelected,
  });

  @override
  State<LocationSelectionBottomSheet> createState() =>
      _LocationSelectionBottomSheetState();
}

class _LocationSelectionBottomSheetState
    extends State<LocationSelectionBottomSheet> {
  final NominatimApiService _nominatimApiService = NominatimApiService();
  final TextEditingController _searchController = TextEditingController();
  List<NominatimSearchResult> _searchResults = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _errorMessage;
  Timer? _searchDebounceTimer; // Debounce timer for search

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    // Cancel any pending search debounce timer
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = null;
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final newQuery = _searchController.text;
    setState(() {
      _searchQuery = newQuery;
      _errorMessage = null;
    });

    // Cancel previous debounce timer
    _searchDebounceTimer?.cancel();

    // If search is empty, clear results
    if (newQuery.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    // Debounce search API call (wait 400ms after user stops typing)
    _searchDebounceTimer = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        _loadSearchResults();
      }
    });
  }

  Future<void> _loadSearchResults() async {
    if (!mounted) return;

    final query = _searchQuery.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _nominatimApiService.searchLocations(
        query: query,
      );

      if (mounted) {
        if (response.isSuccess && response.hasResults) {
          setState(() {
            _searchResults = response.results;
          });
        } else if (response.status == 'ERROR') {
          setState(() {
            _searchResults = [];
            _errorMessage = response.errorMessage ?? 'Search failed';
          });
        } else {
          // Empty results
          setState(() {
            _searchResults = [];
          });
        }
      }
    } catch (e) {
      print('LocationSelectionBottomSheet: Error loading search results: $e');
      if (mounted) {
        setState(() {
          _searchResults = [];
          _errorMessage = 'Failed to search locations';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.location_on_rounded, color: colorMainTheme, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Select Location',
                    style: textStyleSubHeading.copyWith(fontSize: 20),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          ),
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search location...',
                  hintStyle: textStyleBody.copyWith(color: colorGrey),
                  prefixIcon: Icon(Icons.search_rounded, color: colorGrey),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded, color: colorGrey),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchResults = [];
                              _errorMessage = null;
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Search Results List
          Flexible(
            child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: CircularProgressIndicator(color: colorMainTheme),
                    ),
                  )
                : _searchQuery.trim().isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(Icons.search_rounded,
                                size: 60, color: colorGrey),
                            const SizedBox(height: 16),
                            Text(
                              'Start typing to search locations',
                              style: textStyleBody.copyWith(color: colorGrey),
                            ),
                          ],
                        ),
                      )
                    : _errorMessage != null
                        ? Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              children: [
                                Icon(Icons.error_outline_rounded,
                                    size: 60, color: Colors.red.shade300),
                                const SizedBox(height: 16),
                                Text(
                                  _errorMessage!,
                                  style: textStyleBody.copyWith(
                                      color: Colors.red.shade400),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                TextButton(
                                  onPressed: _loadSearchResults,
                                  child: Text(
                                    'Retry',
                                    style: textStyleBody.copyWith(
                                        color: colorMainTheme),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _searchResults.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(40),
                                child: Column(
                                  children: [
                                    Icon(Icons.location_off_rounded,
                                        size: 60, color: colorGrey),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No locations found',
                                      style:
                                          textStyleBody.copyWith(color: colorGrey),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: _searchResults.length,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemBuilder: (context, index) {
                                  final result = _searchResults[index];
                                  return _buildSearchResultItem(result);
                                },
                              ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildSearchResultItem(NominatimSearchResult result) {
    final mainText = result.mainText;
    final secondaryText = result.secondaryText;

    return InkWell(
      onTap: () {
        // Directly pass the latitude and longitude from the search result
        // No need for additional API call since Nominatim already provides coordinates
        widget.onLocationSelected(
          result.uniqueId,
          result.displayName,
          result.latitude,
          result.longitude,
        );
        Get.back();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorMainTheme.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.location_on_rounded,
                color: colorMainTheme,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mainText,
                    style: textStyleSubHeading.copyWith(fontSize: 16),
                  ),
                  if (secondaryText.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      secondaryText,
                      style: textStyleBody.copyWith(
                        color: colorGrey,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: colorGrey),
          ],
        ),
      ),
    );
  }
}

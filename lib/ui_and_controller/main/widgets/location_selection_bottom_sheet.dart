import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/response/google_places_prediction_model.dart';
import '../../../services/google_places_api_service.dart';
import '../../../utils/theme_manager.dart';

class LocationSelectionBottomSheet extends StatefulWidget {
  final Function(String placeId, String description) onLocationSelected;

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
  final GooglePlacesApiService _googlePlacesApiService =
      GooglePlacesApiService();
  final TextEditingController _searchController = TextEditingController();
  List<GooglePlacesPredictionModel> _predictions = [];
  bool _isLoading = false;
  String _searchQuery = '';
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
    });

    // Cancel previous debounce timer
    _searchDebounceTimer?.cancel();

    // If search is empty, clear predictions
    if (newQuery.trim().isEmpty) {
      setState(() {
        _predictions = [];
      });
      return;
    }

    // Debounce search API call (wait 400ms after user stops typing)
    _searchDebounceTimer = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        _loadAutocompleteSuggestions();
      }
    });
  }

  Future<void> _loadAutocompleteSuggestions() async {
    if (!mounted) return;

    final query = _searchQuery.trim();
    if (query.isEmpty) {
      setState(() {
        _predictions = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _googlePlacesApiService.getAutocompleteSuggestions(
        input: query,
      );

      if (mounted) {
        if (response.status == 'OK' && response.predictions.isNotEmpty) {
          setState(() {
            _predictions = response.predictions;
          });
        } else {
          // Show error state or empty list
          setState(() {
            _predictions = [];
          });
        }
      }
    } catch (e) {
      print('LocationSelectionBottomSheet: Error loading suggestions: $e');
      if (mounted) {
        setState(() {
          _predictions = [];
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
                              _predictions = [];
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
          // Predictions List
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
                    : _predictions.isEmpty
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
                            itemCount: _predictions.length,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemBuilder: (context, index) {
                              final prediction = _predictions[index];
                              return _buildPredictionItem(prediction);
                            },
                          ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildPredictionItem(GooglePlacesPredictionModel prediction) {
    final mainText = prediction.structuredFormatting?.mainText ??
        prediction.description.split(',').first;
    final secondaryText = prediction.structuredFormatting?.secondaryText ??
        prediction.description.substring(mainText.length).trim();

    return InkWell(
      onTap: () {
        widget.onLocationSelected(prediction.placeId, prediction.description);
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



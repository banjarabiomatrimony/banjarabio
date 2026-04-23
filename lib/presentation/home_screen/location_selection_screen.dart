import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/l10n/app_localizations.dart';

import 'package:banjarabio/core/data/location_data.dart';
import 'package:banjarabio/widgets/glassmorphism_container.dart';
import 'package:banjarabio/widgets/app_logo_image.dart';

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({super.key});

  @override
  State<LocationSelectionScreen> createState() =>
      _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<String> _recentLocations = [];
  final bool _isLocating = false;

  // Manual selection state
  String? _selectedState;
  String? _selectedDistrict;
  String? _selectedTaluka;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadRecentLocations();
  }

  Future<void> _loadRecentLocations() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentLocations = prefs.getStringList('recent_locations') ?? [];
    });
  }

  Future<void> _saveRecentLocation(String location) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> current = prefs.getStringList('recent_locations') ?? [];
    if (current.contains(location)) {
      current.remove(location);
    }
    current.insert(0, location);
    if (current.length > 5) {
      current = current.sublist(0, 5);
    }
    await prefs.setStringList('recent_locations', current);
  }

  // Future<void> _useCurrentLocation() async {
    // TODO: Future Usage - Exact location not required for now
    /*
    setState(() => _isLocating = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied';
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        // Map to Taluka, District
        final taluka = place.subLocality ?? place.locality ?? '';
        final district = place.subAdministrativeArea ?? '';
        final state = place.administrativeArea ?? '';

        if (taluka.isNotEmpty && district.isNotEmpty) {
          _onLocationSelected(taluka: taluka, district: district, state: state);
        } else {
          throw 'Could not determine taluka/district';
        }
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString();
        final isPermissionError =
            errorMessage.toLowerCase().contains('permission') ||
            errorMessage.toLowerCase().contains('denied');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isPermissionError
                  ? 'Location permission denied. Please enable it in Settings.'
                  : 'Error: $errorMessage',
            ),
            backgroundColor: Colors.red,
            action: isPermissionError
                ? SnackBarAction(
                    label: AppLocalizations.of(context)?.openSettings ?? 'Open Settings',
                    textColor: Colors.white,
                    onPressed: () => Geolocator.openAppSettings(),
                  )
                : null,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
    */
  // }

  void _onLocationSelected({String? taluka, String? district, String? state}) {
    final Map<String, String?> result = {
      'taluka': taluka,
      'district': district,
      'state': state,
    };

    String displayString;
    final locTaluka = LocationData.getLocalizedName(taluka, context);
    final locDistrict = LocationData.getLocalizedName(district, context);
    final locState = LocationData.getLocalizedName(state, context);

    if (locTaluka.isNotEmpty && locDistrict.isNotEmpty) {
      displayString = '$locTaluka, $locDistrict';
    } else if (locDistrict.isNotEmpty) {
      displayString = locDistrict;
    } else if (locState.isNotEmpty) {
      displayString = locState;
    } else {
      displayString = AppLocalizations.of(context)?.allIndia ?? 'All India';
    }

    if (displayString != (AppLocalizations.of(context)?.allIndia ?? 'All India')) {
      _saveRecentLocation(displayString);
    }

    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // SliverAppBar with Search
          SliverAppBar(
            floating: true,
            snap: true,
            automaticallyImplyLeading: false,
            backgroundColor: theme.appBarTheme.backgroundColor,
            toolbarHeight: 125,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: GlassmorphismContainer(
                color: theme.colorScheme.primary,
                opacity: 0.85,
                blur: 20,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                padding: EdgeInsets.fromLTRB(2.w, 0, 4.w, 1.h),
                child: SafeArea(
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        // Title row with Back Button
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                            Padding(
                              padding: EdgeInsets.all(0.5.h),
                              child: AppLogoImage(height: 3.5.h),
                            ),
                            SizedBox(width: 2.w),
                            Text(AppLocalizations.of(context)?.selectLocation ?? 'Select Location',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        // Search Bar
                        Padding(
                          padding: EdgeInsets.only(left: 4.w, right: 2.w, top: 1.h),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value.toLowerCase();
                              });
                            },
                            style: theme.textTheme.bodyLarge,
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)?.searchStateDistrictOrTaluka ?? 'Search State, District or Taluka',
                              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                              ),
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.close_rounded,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _searchQuery = '');
                                      },
                                    )
                                  : null,
                              filled: true,
                              fillColor: theme.colorScheme.surface,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 1.2.h,
                                horizontal: 4.w,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: theme.colorScheme.secondary,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // List Content
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Quick Action Cards
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  child: Row(
                    children: [
                      // Current Location Card
                      Expanded(
                        child: Opacity(
                          opacity: 0.5,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              height: 12.h,
                            padding: EdgeInsets.all(1.5.h),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.primary.withValues(alpha: 0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _isLocating
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.my_location_rounded,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                SizedBox(height: 1.h),
                                Text(
                                  AppLocalizations.of(context)?.currentLocation ?? 'Current Location',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                      SizedBox(width: 4.w),
                      // All India Card
                      Expanded(
                        child: InkWell(
                          onTap: () => _onLocationSelected(),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            height: 12.h,
                            padding: EdgeInsets.all(1.5.h),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: theme.colorScheme.outline.withValues(alpha: 0.1),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.public_rounded,
                                  color: theme.colorScheme.primary,
                                  size: 28,
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  AppLocalizations.of(context)?.allIndia ?? 'All India',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Recently Used (Hide if searching)
                if (_searchQuery.isEmpty && _recentLocations.isNotEmpty) ...[
                  SizedBox(height: 1.h),
                  Text(AppLocalizations.of(context)?.recentlyUsed ?? 'RECENTLY USED',
                    style: theme.textTheme.labelSmall?.copyWith(
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  SizedBox(
                    height: 5.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _recentLocations.length,
                      separatorBuilder: (context, index) => SizedBox(width: 2.w),
                      itemBuilder: (context, index) {
                        final loc = _recentLocations[index];
                        return ActionChip(
                          label: Text(LocationData.getLocalizedFullLocation(loc, context)),
                          avatar: Icon(Icons.history_rounded, size: 16, color: theme.colorScheme.primary),
                          onPressed: () {
                            final parts = loc.split(', ');
                            if (parts.length == 2) {
                              _onLocationSelected(
                                taluka: parts[0],
                                district: parts[1],
                              );
                            } else {
                              _onLocationSelected(district: loc);
                            }
                          },
                          backgroundColor: theme.colorScheme.surface,
                          side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        );
                      },
                    ),
                  ),
                ],

                if (_searchQuery.isEmpty) ...[
                  SizedBox(height: 3.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocalizations.of(context)?.manualSelection ?? 'MANUAL SELECTION',
                        style: theme.textTheme.labelSmall?.copyWith(
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      if (_selectedState != null)
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: () => setState(() {
                                if (_selectedTaluka != null) {
                                  _selectedTaluka = null;
                                } else if (_selectedDistrict != null) {
                                  _selectedDistrict = null;
                                } else {
                                  _selectedState = null;
                                }
                              }),
                              icon: const Icon(Icons.arrow_back_rounded, size: 16),
                              label: Text(AppLocalizations.of(context)?.back ?? 'Back', style: TextStyle(fontSize: 12.sp)),
                            ),
                            SizedBox(width: 2.w),
                            TextButton.icon(
                              onPressed: () => setState(() {
                                _selectedState = null;
                                _selectedDistrict = null;
                                _selectedTaluka = null;
                              }),
                              icon: const Icon(Icons.restart_alt_rounded, size: 16),
                              label: Text(AppLocalizations.of(context)?.reset ?? 'Reset', style: TextStyle(fontSize: 12.sp)),
                            ),
                          ],
                        ),
                    ],
                  ),
                  SizedBox(height: 1.h),

                  // Breadcrumb / Context header
                  if (_selectedState != null)
                    Container(
                      margin: EdgeInsets.only(bottom: 2.h),
                      padding: EdgeInsets.all(1.5.h),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.location_on_rounded, color: theme.colorScheme.primary, size: 20),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: theme.textTheme.bodyMedium,
                                children: [
                                  TextSpan(text: LocationData.getLocalizedName(_selectedState, context), style: const TextStyle(fontWeight: FontWeight.bold)),
                                  if (_selectedDistrict != null) ...[
                                    const TextSpan(text: '  >  '),
                                    TextSpan(text: LocationData.getLocalizedName(_selectedDistrict, context), style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                  if (_selectedTaluka != null) ...[
                                    const TextSpan(text: '  >  '),
                                    TextSpan(text: LocationData.getLocalizedName(_selectedTaluka, context), style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // State Selection (if none selected)
                  if (_selectedState == null)
                    ...LocationData.states.map(
                      (state) => Card(
                        margin: EdgeInsets.only(bottom: 1.h),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
                        ),
                        child: ListTile(
                          title: Text(LocationData.getLocalizedName(state, context), style: const TextStyle(fontWeight: FontWeight.w600)),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () {
                            setState(() {
                              _selectedState = state;
                              _selectedDistrict = null;
                            });
                          },
                        ),
                      ),
                    )
                  else if (_selectedDistrict == null) ...[
                    // Selection Options for State
                    Card(
                      margin: EdgeInsets.only(bottom: 1.h),
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: const Icon(Icons.public_rounded),
                        title: Text(AppLocalizations.of(context)?.allInState(_selectedState!) ?? 'All in $_selectedState',
                          style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                        ),
                        onTap: () => _onLocationSelected(state: _selectedState),
                      ),
                    ),
                    ...LocationData.getDistricts(_selectedState!).map(
                      (dist) => Card(
                        margin: EdgeInsets.only(bottom: 1.h),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
                        ),
                        child: ListTile(
                          title: Text(LocationData.getLocalizedName(dist, context)),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () {
                            setState(() {
                              _selectedDistrict = dist;
                            });
                          },
                        ),
                      ),
                    ),
                  ] else if (_selectedTaluka == null) ...[
                    // Selection Options for District
                    Card(
                      margin: EdgeInsets.only(bottom: 1.h),
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: const Icon(Icons.location_city_rounded),
                        title: Text(AppLocalizations.of(context)?.allInDistrict(_selectedDistrict!) ?? 'All in $_selectedDistrict',
                          style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                        ),
                        onTap: () => _onLocationSelected(
                          district: _selectedDistrict,
                          state: _selectedState,
                        ),
                      ),
                    ),
                    ...LocationData.getTalukas(_selectedDistrict!).map(
                      (tal) => Card(
                        margin: EdgeInsets.only(bottom: 1.h),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
                        ),
                        child: ListTile(
                          title: Text(LocationData.getLocalizedName(tal, context)),
                          trailing: const Icon(Icons.chevron_right_rounded, size: 18),
                          onTap: () {
                            setState(() {
                              _selectedTaluka = tal;
                            });
                          },
                        ),
                      ),
                    ),
                    // If no talukas or want to add village
                    Card(
                      margin: EdgeInsets.only(top: 1.h),
                      elevation: 0,
                      color: theme.colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.add_location_alt_rounded, color: theme.colorScheme.primary),
                        title: Text(AppLocalizations.of(context)?.enterVillageManually ?? 'Enter Village/Other Name',
                          style: TextStyle(color: theme.colorScheme.primary),
                        ),
                        onTap: () {
                          setState(() {
                            _selectedTaluka = 'Custom'; 
                          });
                        },
                      ),
                    ),
                  ] else ...[
                    // Final Selection / Village Entry
                    Text(
                      '${AppLocalizations.of(context)?.specificLocation ?? 'SPECIFIC LOCATION'} (${AppLocalizations.of(context)?.optional ?? 'OPTIONAL'})',
                      style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 1.h),
                    TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: '${AppLocalizations.of(context)?.enterVillageHint ?? 'Enter Village or Tanda name...'} (${AppLocalizations.of(context)?.optional ?? 'Optional'})',
                        prefixIcon: const Icon(Icons.holiday_village_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.check_circle_rounded, size: 28),
                          color: theme.colorScheme.primary,
                          onPressed: () {
                             // Will be handled by a controller or just skip for now if empty
                             _onLocationSelected(
                               taluka: _selectedTaluka == 'Custom' ? null : _selectedTaluka,
                               district: _selectedDistrict,
                               state: _selectedState,
                             );
                          },
                        ),
                      ),
                      onSubmitted: (val) {
                         _onLocationSelected(
                           taluka: _selectedTaluka == 'Custom' ? val : _selectedTaluka,
                           district: _selectedDistrict,
                           state: _selectedState,
                         );
                      },
                    ),
                    SizedBox(height: 2.h),
                    ElevatedButton(
                      onPressed: () => _onLocationSelected(
                        taluka: _selectedTaluka == 'Custom' ? null : _selectedTaluka,
                        district: _selectedDistrict,
                        state: _selectedState,
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(AppLocalizations.of(context)?.skipAndSelectLevel ?? 'Skip & Select Taluka/District'),
                    ),
                  ],
                ] else ...[
                  // Combined Search Results
                  () {
                    final stateResults = LocationData.states
                        .where((s) => s.toLowerCase().contains(_searchQuery))
                        .map(
                          (s) => Card(
                            margin: EdgeInsets.only(bottom: 1.h),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
                            ),
                            child: ListTile(
                              title: Text(LocationData.getLocalizedName(s, context), style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text(AppLocalizations.of(context)?.state ?? 'State'),
                              trailing: const Icon(Icons.chevron_right_rounded, size: 18),
                              onTap: () => _onLocationSelected(state: s),
                            ),
                          ),
                        );

                    final districtResults = LocationData.districts.entries
                        .expand((entry) {
                          final stateName = entry.key;
                          return entry.value
                              .where(
                                (d) => d.toLowerCase().contains(_searchQuery),
                              )
                              .map(
                                (d) => Card(
                                  margin: EdgeInsets.only(bottom: 1.h),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
                                  ),
                                  child: ListTile(
                                    title: Text(LocationData.getLocalizedName(d, context), style: const TextStyle(fontWeight: FontWeight.w600)),
                                    subtitle: Text(AppLocalizations.of(context)?.districtInState(stateName) ?? 'District in $stateName'),
                                    trailing: const Icon(Icons.chevron_right_rounded, size: 18),
                                    onTap: () => _onLocationSelected(
                                      district: d,
                                      state: stateName,
                                    ),
                                  ),
                                ),
                              );
                        });

                    final talukaResults = LocationData.talukas.entries.expand((
                      entry,
                    ) {
                      final districtName = entry.key;
                      final stateName = LocationData.districts.entries
                          .firstWhere(
                            (e) => e.value.contains(districtName),
                            orElse: () => const MapEntry('Unknown', []),
                          )
                          .key;
                      return entry.value
                          .where((t) => t.toLowerCase().contains(_searchQuery))
                          .map(
                            (t) => Card(
                              margin: EdgeInsets.only(bottom: 1.h),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
                              ),
                              child: ListTile(
                                title: Text(LocationData.getLocalizedName(t, context), style: const TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: Text(
                                  AppLocalizations.of(context)?.talukaInDistrictState(districtName, stateName) ?? 'Taluka in $districtName, $stateName',
                                ),
                                onTap: () => _onLocationSelected(
                                  taluka: t,
                                  district: districtName,
                                  state: stateName,
                                ),
                              ),
                            ),
                          );
                    });

                    final allResults = [
                      ...stateResults,
                      ...districtResults,
                      ...talukaResults,
                    ];

                    if (allResults.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
                        child: Center(
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(3.h),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.05),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.search_off_rounded,
                                  size: 48.sp,
                                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                                ),
                              ),
                              SizedBox(height: 3.h),
                              Text(
                                AppLocalizations.of(context)?.noLocationsFoundForQuery(_searchQuery) ?? 'No locations found for "$_searchQuery"',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                AppLocalizations.of(context)?.trySearchingForADifferentCity ?? 'Try searching for a different city or state.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 2.h),
                        Text(AppLocalizations.of(context)?.searchResults ?? 'SEARCH RESULTS',
                          style: theme.textTheme.labelSmall?.copyWith(
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        ...allResults,
                      ],
                    );
                  }(),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/services/analytics_service.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/widgets/custom_app_bar.dart';
import 'package:banjarabio/widgets/tactile/tactile_back_button.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';
import 'package:flutter/services.dart';


class MelavaEvent {
  final String id;
  final String title;
  final String organizer;
  final String date;
  final String time;
  final String venue;
  final String contact;
  final String description;
  final String partnerType;
  final String focus;
  final String registration;
  final String expectedProfiles;

  const MelavaEvent({
    required this.id,
    required this.title,
    required this.organizer,
    required this.date,
    required this.time,
    required this.venue,
    required this.contact,
    required this.description,
    required this.partnerType,
    required this.focus,
    required this.registration,
    required this.expectedProfiles,
  });
}

class MelavaScreen extends ConsumerStatefulWidget {
  const MelavaScreen({super.key});

  @override
  ConsumerState<MelavaScreen> createState() => _MelavaScreenState();
}

class _MelavaScreenState extends ConsumerState<MelavaScreen> {
  // Static mock data for Phase 0
  final List<MelavaEvent> _events = const [
    MelavaEvent(
      id: 'pune_2026',
      title: 'Pune Banjara Vadhu-Var Melava',
      organizer: 'Banjara Seva Sangh, Pune',
      date: 'Sunday, November 8, 2026',
      time: '10:00 AM - 5:00 PM',
      venue: 'Banjara Bhavan, Near Shivaji Nagar Metro Station, Pune, Maharashtra 411005',
      contact: '+919876543210',
      description: 'Annual Parichay Melava organized in collaboration with Banjara Seva Sangh, Pune. Dedicated to bridging the gap for urban, IT, and multi-field professionals in Western Maharashtra. Includes live matchmaking and family networking slots.',
      partnerType: 'Verified Trust Partner',
      focus: 'IT & Urban Professionals',
      registration: 'Free Entry (Booklet Inc.)',
      expectedProfiles: '800+ Candidates',
    ),
    MelavaEvent(
      id: 'washim_2026',
      title: 'Washim Banjara Parichay Melava',
      organizer: 'Vasantrao Naik Smruti Trust',
      date: 'Saturday, November 21, 2026',
      time: '9:00 AM - 6:00 PM',
      venue: 'Naik Ground, Pusad Road, Washim, Maharashtra 444505',
      contact: '+919876543211',
      description: 'One of Central India\'s largest regional Melavas hosted by Vasantrao Naik Smruti Trust. A prestigious annual gathering focusing on rural-urban matchmaking, uniting families from across Vidarbha with verified profile exchanges.',
      partnerType: 'Verified Trust Partner',
      focus: 'Vidarbha Region Families',
      registration: 'Nominal Trust Fee',
      expectedProfiles: '1500+ Candidates',
    ),
    MelavaEvent(
      id: 'bengaluru_2026',
      title: 'Bengaluru Banjara Matrimony Meet',
      organizer: 'Karnataka Banjara Vikas Sabha',
      date: 'Sunday, December 6, 2026',
      time: '11:00 AM - 4:00 PM',
      venue: 'Banjara Community Hall, Hebbal, Bengaluru, Karnataka 560024',
      contact: '+919876543212',
      description: 'Organized by Karnataka Banjara Vikas Sabha. Tailored for Lambani/Banjara families in South India. Offers multilingual profile listings and focused coordination for candidates from Karnataka and border regions.',
      partnerType: 'Official Digital Partner',
      focus: 'South Indian Families',
      registration: 'Free Spot Registry',
      expectedProfiles: '600+ Profiles',
    ),
    MelavaEvent(
      id: 'hyderabad_2026',
      title: 'Hyderabad Lambada Parichay Melava',
      organizer: 'All India Banjara Seva Sangh, Telangana',
      date: 'Sunday, December 20, 2026',
      time: '10:00 AM - 5:00 PM',
      venue: 'Banjara Bhavan, Road No. 10, Banjara Hills, Hyderabad, Telangana 500034',
      contact: '+919876543213',
      description: 'Organized by All India Banjara Seva Sangh, Telangana. Focuses on high-educated individuals, government employees, and IT/corporate professionals from Telangana and Andhra Pradesh.',
      partnerType: 'Official Digital Partner',
      focus: 'High-Ed & Corporate Pros',
      registration: 'Pre-Registration RSVP',
      expectedProfiles: '1200+ Candidates',
    ),
    MelavaEvent(
      id: 'nanded_2026',
      title: 'Nanded Gor Banjara Mahamelava',
      organizer: 'Nanded Gor Sena & Banjara Seva Samiti',
      date: 'Sunday, December 13, 2026',
      time: '10:00 AM - 6:00 PM',
      venue: 'Vasantrao Naik Sabhagruh, VIP Road, Nanded, Maharashtra 431602',
      contact: '+919876543214',
      description: 'Grand matrimonial gathering by Nanded Gor Sena & Banjara Seva Samiti. Highlights profiles of graduates, engineers, doctors, and professionals from Nanded, Latur, and Hingoli districts.',
      partnerType: 'Verified Trust Partner',
      focus: 'Graduates & Professionals',
      registration: 'On-Spot Profile Registry',
      expectedProfiles: '1000+ Profiles',
    ),
    MelavaEvent(
      id: 'yavatmal_2027',
      title: 'Yavatmal Banjara Vadhu-Var Melava',
      organizer: 'Yavatmal Gor Banjara Parishad',
      date: 'Sunday, January 10, 2027',
      time: '9:30 AM - 5:30 PM',
      venue: 'Sevalal Mangal Karyalaya, Darwha Road, Yavatmal, Maharashtra 445001',
      contact: '+919876543215',
      description: 'Hosted by Yavatmal Gor Banjara Parishad. A traditional event focused on strengthening community ties, offering personalized matchmaking tables and verified offline profile directory booklets.',
      partnerType: 'Verified Trust Partner',
      focus: 'Traditional Family Ties',
      registration: 'Free Entry for Families',
      expectedProfiles: '900+ Candidates',
    ),
    MelavaEvent(
      id: 'mumbai_2027',
      title: 'Mumbai Banjara Vadhu-Var Melava',
      organizer: 'Gor Banjara Social Foundation, Mumbai',
      date: 'Sunday, January 24, 2027',
      time: '10:00 AM - 5:00 PM',
      venue: 'Banjara Samaj Hall, Sector 3, Ghansoli, Navi Mumbai, Maharashtra 400701',
      contact: '+919876543216',
      description: 'Organized by Gor Banjara Social Foundation, Mumbai. Specifically serves families residing in Mumbai, Thane, Navi Mumbai, and surrounding cities. Ideal for finding urban and well-settled matches.',
      partnerType: 'Official Digital Partner',
      focus: 'Metropolitan Graduates',
      registration: 'Online Pre-RSVP',
      expectedProfiles: '700+ Profiles',
    ),
    MelavaEvent(
      id: 'sambhajinagar_2027',
      title: 'Chhatrapati Sambhajinagar Banjara Parichay Meet',
      organizer: 'Marathwada Banjara Vikas Manch',
      date: 'Saturday, February 6, 2027',
      time: '10:00 AM - 5:00 PM',
      venue: 'Naik Sabhagruh, Garkheda Area, Chhatrapati Sambhajinagar (Aurangabad), Maharashtra 431005',
      contact: '+919876543217',
      description: 'A premier Marathwada region matrimonial meet organized by Marathwada Banjara Vikas Manch. Designed to support parents in direct face-to-face talks and verified biodata exchange.',
      partnerType: 'Verified Trust Partner',
      focus: 'Marathwada Regional Special',
      registration: 'Free Entry (Pre-register)',
      expectedProfiles: '850+ Candidates',
    ),
    MelavaEvent(
      id: 'jalgaon_2027',
      title: 'Jalgaon Banjara Matrimony Melava',
      organizer: 'Khandesh Gor Banjara Sangh',
      date: 'Sunday, February 21, 2027',
      time: '10:00 AM - 4:00 PM',
      venue: 'Banjara Bhavan, Near Railway Station, Jalgaon, Maharashtra 425001',
      contact: '+919876543218',
      description: 'Hosted by Khandesh Gor Banjara Sangh. Connecting families across Jalgaon, Dhule, and Nandurbar. Provides a printed directory of community profiles to all attending parents.',
      partnerType: 'Verified Trust Partner',
      focus: 'Khandesh Region Special',
      registration: 'Booklet Included (Free)',
      expectedProfiles: '650+ Profiles',
    ),
    MelavaEvent(
      id: 'warangal_2027',
      title: 'Warangal Gor-Banjara Matrimonial Meet',
      organizer: 'Kakatiya Banjara Welfare Association',
      date: 'Sunday, March 7, 2027',
      time: '10:00 AM - 4:30 PM',
      venue: 'Banjara Community Hall, Hunter Road, Hanamkonda, Warangal, Telangana 506001',
      contact: '+919876543219',
      description: 'Organized by Kakatiya Banjara Welfare Association. Serves the Lambada community in Northern Telangana, with a strong focus on candidates in government services, education, and professional sectors.',
      partnerType: 'Official Digital Partner',
      focus: 'Public Sector & Grads',
      registration: 'Nominal Registration Fee',
      expectedProfiles: '500+ Candidates',
    ),
    MelavaEvent(
      id: 'kalaburagi_2027',
      title: 'Kalaburagi Lambani Matrimony Sangama',
      organizer: 'Kalaburagi Banjara Seva Sangha',
      date: 'Sunday, March 21, 2027',
      time: '10:00 AM - 5:00 PM',
      venue: 'Sevalal Kalyana Mantapa, Jewargi Road, Kalaburagi, Karnataka 585102',
      contact: '+919876543220',
      description: 'Organized by Kalaburagi Banjara Seva Sangha. Facilitates matrimonial alliances across the North Karnataka-Maharashtra border region, with native Lambani and Kannada speaking assistance.',
      partnerType: 'Official Digital Partner',
      focus: 'Karnataka Border Region',
      registration: 'Free Spot Matching',
      expectedProfiles: '750+ Profiles',
    ),
    MelavaEvent(
      id: 'vijayapura_2027',
      title: 'Vijayapura Gor-Banjara Vadhu-Var Melava',
      organizer: 'Vijayapura Lambani Welfare Trust',
      date: 'Sunday, April 4, 2027',
      time: '9:30 AM - 4:30 PM',
      venue: 'Banjara Bhavan, Sholapur Road, Vijayapura, Karnataka 586103',
      contact: '+919876543221',
      description: 'Hosted by Vijayapura Lambani Welfare Trust. Connects families across Vijayapura and Bagalkot. Promotes preserving community heritage while matching modern, educated brides and grooms.',
      partnerType: 'Verified Trust Partner',
      focus: 'Preserving Heritage Matches',
      registration: 'Free Entry for All',
      expectedProfiles: '600+ Candidates',
    ),
    MelavaEvent(
      id: 'jaipur_2027',
      title: 'Jaipur Banjara Matrimonial Sammelan',
      organizer: 'Rajasthan Banjara Mahasabha',
      date: 'Sunday, April 18, 2027',
      time: '10:00 AM - 5:00 PM',
      venue: 'Banjara Kalyan Board Community Hall, Malviya Nagar, Jaipur, Rajasthan 302017',
      contact: '+919876543222',
      description: 'Organized by Rajasthan Banjara Mahasabha. Provides an opportunity for North-Western Banjara families (Rajasthan, Haryana, Delhi NCR) to interact and find regional matches.',
      partnerType: 'Verified Trust Partner',
      focus: 'North-Western Alliances',
      registration: 'Pre-Registration Required',
      expectedProfiles: '400+ Candidates',
    ),
    MelavaEvent(
      id: 'indore_2027',
      title: 'Indore Gor-Banjara Parichay Sammelan',
      organizer: 'MP Banjara Seva Trust',
      date: 'Sunday, May 2, 2027',
      time: '10:00 AM - 5:00 PM',
      venue: 'Banjara Dharamshala, Near Sevalal Temple, Indore, Madhya Pradesh 452001',
      contact: '+919876543223',
      description: 'MP Banjara Seva Trust\'s leading event for the community in Madhya Pradesh. Focuses on profile sharing, on-stage self-introductions, and parent interaction sessions.',
      partnerType: 'Verified Trust Partner',
      focus: 'Central India Matrimony',
      registration: 'Nominal Registration Fee',
      expectedProfiles: '550+ Profiles',
    ),
    MelavaEvent(
      id: 'global_virtual_2027',
      title: 'Global Gor-Banjara Matrimony Meet (Virtual)',
      organizer: 'Global Gor Banjara Diaspora',
      date: 'Sunday, May 16, 2027',
      time: '4:00 PM - 7:00 PM IST',
      venue: 'Online Zoom Meeting (Global Virtual Event)',
      contact: '+919876543224',
      description: 'BanjaraBio\'s flagship virtual matrimonial event for the global diaspora. Connects highly-educated professionals and NRIs working across the USA, UK, Canada, Australia, Europe, and Middle East. Conducted entirely online via Zoom.',
      partnerType: 'BanjaraBio Exclusive',
      focus: 'NRI & Global Professionals',
      registration: 'Free Zoom RSVP Required',
      expectedProfiles: '300+ NRI Profiles',
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  String _selectedState = 'All';
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    // Telemetry: log screen view on initial build
    AnalyticsService.logScreenView('melava_directory');
    _searchFocusNode.addListener(_onSearchFocusChange);
  }

  void _onSearchFocusChange() {
    if (mounted) {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    }
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_onSearchFocusChange);
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<MelavaEvent> get _filteredEvents {
    return _events.where((event) {
      if (_selectedState != 'All') {
        if (_selectedState == 'Exclusive') {
          if (event.partnerType != 'BanjaraBio Exclusive') return false;
        } else if (_selectedState == 'Maharashtra') {
          if (!event.venue.toLowerCase().contains('maharashtra')) return false;
        } else if (_selectedState == 'Karnataka') {
          if (!event.venue.toLowerCase().contains('karnataka')) return false;
        } else if (_selectedState == 'Telangana') {
          if (!event.venue.toLowerCase().contains('telangana')) return false;
        } else if (_selectedState == 'Others') {
          final venueLower = event.venue.toLowerCase();
          final isMH = venueLower.contains('maharashtra');
          final isKA = venueLower.contains('karnataka');
          final isTS = venueLower.contains('telangana');
          final isExcl = event.partnerType == 'BanjaraBio Exclusive';
          if (isMH || isKA || isTS || isExcl) return false;
        }
      }

      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final titleMatch = event.title.toLowerCase().contains(query);
        final organizerMatch = event.organizer.toLowerCase().contains(query);
        final venueMatch = event.venue.toLowerCase().contains(query);
        final focusMatch = event.focus.toLowerCase().contains(query);
        return titleMatch || organizerMatch || venueMatch || focusMatch;
      }

      return true;
    }).toList();
  }

  Future<void> _callOrganizer(String phoneNumber, String eventId, String eventTitle) async {
    // Log telemetry event
    await AnalyticsService.logEvent('melava_call_organizer_tap', parameters: {
      'melava_id': eventId,
      'melava_title': eventTitle,
    });

    final Uri phoneUri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.couldNotLaunchDialer ?? 'Could not launch phone dialer',
            ),
          ),
        );
      }
    }
  }

  Future<void> _whatsappInquiry(MelavaEvent event) async {
    await AnalyticsService.logEvent('melava_whatsapp_inquiry', parameters: {
      'melava_id': event.id,
      'melava_title': event.title,
    });
    HapticFeedback.lightImpact();
    final String cleanContact = event.contact.replaceAll('+', '').replaceAll(' ', '');
    final String message =
        'Hello! I saw "${event.title}" on BanjaraBio Matrimony and would like to get registration/attendance details.';
    final Uri uri = Uri.parse(
      'https://wa.me/$cleanContact?text=${Uri.encodeComponent(message)}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.couldNotLaunchWhatsApp ??
                  'Could not launch WhatsApp',
            ),
          ),
        );
      }
    }
  }

  int _getCountForState(String state) {
    if (state == 'All') return _events.length;
    if (state == 'Exclusive') {
      return _events.where((e) => e.partnerType == 'BanjaraBio Exclusive').length;
    } else if (state == 'Maharashtra') {
      return _events.where((e) => e.venue.toLowerCase().contains('maharashtra')).length;
    } else if (state == 'Karnataka') {
      return _events.where((e) => e.venue.toLowerCase().contains('karnataka')).length;
    } else if (state == 'Telangana') {
      return _events.where((e) => e.venue.toLowerCase().contains('telangana')).length;
    } else {
      bool isOthers(MelavaEvent e) {
        final v = e.venue.toLowerCase();
        return !v.contains('maharashtra') &&
            !v.contains('karnataka') &&
            !v.contains('telangana') &&
            e.partnerType != 'BanjaraBio Exclusive';
      }
      return _events.where(isOthers).length;
    }
  }

  Future<void> _shareEvent(MelavaEvent event) async {
    // Log telemetry event
    await AnalyticsService.logEvent('melava_share_tap', parameters: {
      'melava_id': event.id,
      'melava_title': event.title,
    });

    final String message = 
        '🌸 *Banjara Parichay Melava Invitation* 🌸\n\n'
        '• *Event:* ${event.title}\n'
        '• *Organizer:* ${event.organizer}\n'
        '• *Date:* ${event.date}\n'
        '• *Time:* ${event.time}\n'
        '• *Venue:* ${event.venue}\n'
        '• *Focus:* ${event.focus}\n'
        '• *Profiles Expected:* ${event.expectedProfiles}\n'
        '• *Registration:* ${event.registration}\n'
        '• *Contact Info:* ${event.contact}\n\n'
        'Find more regional matrimonial melavas and connect with community trusts on *BanjaraBio Matrimony* App!';

    try {
      await Share.share(message);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.couldNotTriggerSharing ?? 'Could not trigger sharing',
            ),
          ),
        );
      }
    }
  }

  Widget _buildTicketDivider(ThemeData theme) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 1.8.h),
      child: Row(
        children: [
          Icon(
            Icons.lens,
            size: 8,
            color: theme.colorScheme.secondary.withValues(alpha: 0.7),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: Row(
                children: List.generate(
                  30,
                  (index) => Expanded(
                    child: Container(
                      color: index % 2 == 0 
                          ? theme.colorScheme.outlineVariant.withValues(alpha: 0.6) 
                          : Colors.transparent,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Icon(
            Icons.lens,
            size: 8,
            color: theme.colorScheme.secondary.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheetDetailRow(ThemeData theme, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.primary.withValues(alpha: 0.8),
        ),
        SizedBox(width: 2.5.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: AppTypography.semiBold,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
              SizedBox(height: 0.2.h),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: AppTypography.semiBold,
                  color: theme.colorScheme.onSurface,
                  height: 1.25,
                  fontSize: AppTypography.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _viewEventDetails(MelavaEvent event) {
    // Log telemetry event
    AnalyticsService.logEvent('melava_view_details_tap', parameters: {
      'melava_id': event.id,
      'melava_title': event.title,
    });

    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 25,
                spreadRadius: 2,
              )
            ],
          ),
          padding: EdgeInsets.fromLTRB(6.w, 2.h, 6.w, MediaQuery.of(context).padding.bottom + 2.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bottom Sheet handle
              Center(
                child: Container(
                  width: 12.w,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 2.5.h),
              
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Trust badge & Share/Close button row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildTrustBadge(theme, event.partnerType),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.share_outlined,
                                  size: 20,
                                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => _shareEvent(event),
                              ),
                              SizedBox(width: 4.w),
                              IconButton(
                                icon: Icon(
                                  Icons.close_rounded,
                                  key: const Key('melava_details_close_btn'),
                                  size: 20,
                                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 1.5.h),

                      // Event title
                      Text(
                        event.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: AppTypography.bold,
                          color: theme.colorScheme.onSurface,
                          fontFamily: AppTypography.headingFontFamily,
                          fontSize: AppTypography.headingLarge,
                        ),
                      ),
                      SizedBox(height: 0.8.h),
                      Text(
                        'by ${event.organizer}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                          fontWeight: AppTypography.semiBold,
                        ),
                      ),

                      // Ticket Divider
                      _buildTicketDivider(theme),

                      // Grid of event quick metadata
                      Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.02),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildBottomSheetDetailRow(
                              theme,
                              Icons.calendar_today_outlined,
                              'Date & Time',
                              '${event.date} (${event.time})',
                            ),
                            const Divider(height: 20),
                            _buildBottomSheetDetailRow(
                              theme,
                              Icons.place_outlined,
                              'Venue Location',
                              event.venue,
                            ),
                            const Divider(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildBottomSheetDetailRow(
                                    theme,
                                    Icons.my_location_rounded,
                                    'Candidate Focus',
                                    event.focus,
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                                ),
                                Expanded(
                                  child: _buildBottomSheetDetailRow(
                                    theme,
                                    Icons.people_rounded,
                                    'Expected Profiles',
                                    event.expectedProfiles,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildBottomSheetDetailRow(
                                    theme,
                                    Icons.how_to_reg_rounded,
                                    'Registration Info',
                                    event.registration,
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                                ),
                                Expanded(
                                  child: _buildBottomSheetDetailRow(
                                    theme,
                                    Icons.verified_user_rounded,
                                    'Verification Status',
                                    event.partnerType,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 2.5.h),

                      // Description Section
                      Text(
                        localizations?.eventDetails ?? 'Event Details',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: AppTypography.bold,
                          color: theme.colorScheme.primary,
                          fontFamily: AppTypography.headingFontFamily,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        event.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                          fontSize: AppTypography.bodyLarge,
                        ),
                      ),
                      SizedBox(height: 2.5.h),

                      // Partnership Vision Callout Card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.secondary.withValues(alpha: 0.12),
                              theme.colorScheme.primary.withValues(alpha: 0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.secondary.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.handshake_outlined,
                                  size: 20,
                                  color: theme.colorScheme.secondary,
                                ),
                                SizedBox(width: 2.w),
                                Expanded(
                                  child: Text(
                                    'BanjaraBio Platform Partnership',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: AppTypography.bold,
                                      color: theme.colorScheme.onSurface,
                                      fontFamily: AppTypography.headingFontFamily,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'This event is organized by a verified community trust. BanjaraBio acts as a digital discovery partner to help you find and connect with local matrimonial events. Together, we are building a stronger, digital Banjara community.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 2.5.h),

              // Action buttons in bottom sheet
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _shareEvent(event),
                      icon: Icon(Icons.share_rounded, size: 16, color: theme.colorScheme.primary),
                      label: Text(
                        'Share Invitation',
                        style: TextStyle(
                          fontSize: AppTypography.bodyLarge,
                          fontWeight: AppTypography.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 1.6.h),
                        side: BorderSide(color: theme.colorScheme.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _callOrganizer(event.contact, event.id, event.title);
                      },
                      icon: const Icon(Icons.call_rounded, size: 16, color: Colors.white),
                      label: Text(
                        localizations?.callOrganizer ?? 'Call Organizer',
                        style: TextStyle(
                          fontSize: AppTypography.bodyLarge,
                          fontWeight: AppTypography.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        padding: EdgeInsets.symmetric(vertical: 1.6.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrustBadge(ThemeData theme, String partnerType) {
    final Color baseColor;
    final IconData icon;
    if (partnerType == 'BanjaraBio Exclusive') {
      baseColor = theme.colorScheme.secondary;
      icon = Icons.star_rounded;
    } else if (partnerType == 'Verified Trust Partner') {
      baseColor = theme.colorScheme.primary;
      icon = Icons.verified_rounded;
    } else {
      baseColor = Colors.teal;
      icon = Icons.handshake_rounded;
    }
    final Color bgColor = baseColor.withValues(alpha: 0.08);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: baseColor.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: baseColor,
          ),
          SizedBox(width: 1.w),
          Text(
            partnerType.toUpperCase(),
            style: TextStyle(
              fontSize: AppTypography.bodySmall,
              fontWeight: AppTypography.bold,
              letterSpacing: 0.5,
              color: baseColor,
            ),
          ),
        ],
      ),
    );
  }

  Gradient _getAccentStripGradient(ThemeData theme, String partnerType) {
    if (partnerType == 'BanjaraBio Exclusive') {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          theme.colorScheme.secondary,
          theme.colorScheme.secondary.withValues(alpha: 0.6),
        ],
      );
    } else if (partnerType == 'Verified Trust Partner') {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          theme.colorScheme.primary,
          theme.colorScheme.primary.withValues(alpha: 0.6),
        ],
      );
    } else {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.teal,
          Colors.teal.withValues(alpha: 0.6),
        ],
      );
    }
  }



  Widget _buildSearchBar(ThemeData theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isSearchFocused
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: _isSearchFocused ? 1.5 : 1.0,
        ),
        boxShadow: [
          if (_isSearchFocused)
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 2),
            )
          else
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface,
          fontFamily: AppTypography.headingFontFamily,
        ),
        decoration: InputDecoration(
          hintText: 'Search by location, trust, or keywords...',
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            fontFamily: AppTypography.headingFontFamily,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: theme.colorScheme.primary,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 4.w),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildStateChips(ThemeData theme) {
    final states = ['All', 'Maharashtra', 'Karnataka', 'Telangana', 'Exclusive', 'Others'];
    return SizedBox(
      height: 5.0.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: states.length,
        itemBuilder: (context, index) {
          final state = states[index];
          final isSelected = _selectedState == state;
          final count = _getCountForState(state);
          return Padding(
            padding: EdgeInsets.only(right: 2.w, bottom: 0.5.h),
            child: TactilePressable(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedState = state;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 0.8.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.secondary
                        : theme.colorScheme.secondary.withValues(alpha: 0.25),
                    width: isSelected ? 1.5 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(alpha: 0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: isSelected
                            ? theme.colorScheme.secondary
                            : theme.colorScheme.onSurface,
                        fontWeight: isSelected ? AppTypography.bold : AppTypography.medium,
                        fontFamily: AppTypography.headingFontFamily,
                      ),
                    ),
                    if (count > 0) ...[
                      SizedBox(width: 1.5.w),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.secondary.withValues(alpha: 0.25)
                              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: AppTypography.labelTiny,
                            fontWeight: AppTypography.extraBold,
                            color: isSelected
                                ? theme.colorScheme.secondary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'No Parichay Melavas Found',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: AppTypography.bold,
                fontFamily: AppTypography.headingFontFamily,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              "We couldn't find any events matching your search or filters. Don't see an event in your region?",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 3.h),
            TactilePressable(
              onTap: () {
                HapticFeedback.lightImpact();
                _suggestEvent();
              },
              pressedScale: 0.95,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_comment_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 2.w),
                    Text(
                      'Suggest an Event',
                      style: AppTypography.headingStyle(
                        fontWeight: AppTypography.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _suggestEvent() async {
    // Log telemetry event
    await AnalyticsService.logEvent('melava_suggest_event_tap');

    final String whatsappUrl = 'https://wa.me/+919876543210?text=${Uri.encodeComponent("Hello BanjaraBio, I would like to suggest a Parichay Melava event for my region...")}';
    final Uri uri = Uri.parse(whatsappUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.couldNotLaunchWhatsApp ?? 'Could not launch WhatsApp',
            ),
          ),
        );
      }
    }
  }

  Widget _buildMetadataChip(ThemeData theme, IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.4.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
          ),
          SizedBox(width: 1.w),
          Text(
            text,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: AppTypography.semiBold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        leading: const TactileBackButton(),
        title: localizations?.upcomingMelavas ?? 'Upcoming Melavas',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 12.h), // Spacing for bottom floating bar
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Prominent cultural greeting card explaining the feature (Phase 0 validation)
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CustomPaint(
                painter: BanjaraPatternPainter(
                  primaryColor: theme.colorScheme.primary,
                  secondaryColor: theme.colorScheme.secondary,
                ),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(5.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.05), // translucent background
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.secondary.withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ✦ TRUST ALLIANCE Badge
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.5.h),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.colorScheme.secondary.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.stars_rounded,
                                    size: 11,
                                    color: theme.colorScheme.secondary,
                                  ),
                                  SizedBox(width: 1.w),
                                  Text(
                                    localizations?.trustAllianceBadge ?? '✦ TRUST ALLIANCE',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.secondary,
                                      fontWeight: AppTypography.extraBold,
                                      letterSpacing: 1.0,
                                      fontSize: AppTypography.labelMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 1.5.h),
                            Text(
                              localizations?.melavaBannerTitle ?? 'Banjara Parichay Melavas',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: AppTypography.bold,
                                color: theme.colorScheme.primary,
                                fontFamily: AppTypography.headingFontFamily,
                              ),
                            ),
                            SizedBox(height: 0.8.h),
                            Text(
                              localizations?.melavaBannerSubtitle ??
                                  'Discover regional matrimonial get-togethers. Partner trusts list these events. Reach organizers directly to register.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Icon(
                        Icons.event_available_rounded,
                        size: 40,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 3.h),

            // Search Bar & Filter Chips
            _buildSearchBar(theme),
            SizedBox(height: 1.5.h),
            _buildStateChips(theme),
            SizedBox(height: 3.h),

            // Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  localizations?.upcomingMelavas ?? 'Upcoming Events',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: AppTypography.bold,
                    color: theme.colorScheme.onSurface,
                    fontFamily: AppTypography.headingFontFamily,
                  ),
                ),
                Text(
                  localizations?.melavaEventCount(_filteredEvents.length) ??
                      '${_filteredEvents.length} events',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontFamily: AppTypography.headingFontFamily,
                    fontWeight: AppTypography.medium,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),

            // Melava events list
            _filteredEvents.isEmpty
                ? _buildEmptyState(theme)
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredEvents.length,
                    itemBuilder: (context, index) {
                      final event = _filteredEvents[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 2.h),
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(3.0),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(
                                color: theme.colorScheme.secondary.withValues(alpha: 0.25),
                              ),
                            ),
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Gradient Left Accent Strip for aesthetic pop
                                  Container(
                                    width: 6,
                                    decoration: BoxDecoration(
                                      gradient: _getAccentStripGradient(theme, event.partnerType),
                                      borderRadius: const BorderRadius.horizontal(
                                        left: Radius.circular(10),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.all(4.w),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Partner Trust Badge & Share Row
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              _buildTrustBadge(theme, event.partnerType),
                                              IconButton(
                                                key: Key('share_btn_${event.id}'),
                                                icon: Icon(
                                                  Icons.share_outlined,
                                                  size: 18,
                                                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                                ),
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                                onPressed: () => _shareEvent(event),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 1.h),
                                          // Event Title
                                          Text(
                                            event.title,
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: AppTypography.bold,
                                              color: theme.colorScheme.onSurface,
                                              fontFamily: AppTypography.headingFontFamily,
                                            ),
                                          ),
                                          SizedBox(height: 1.2.h),
                                          // Dynamic Metadata Chips
                                          Wrap(
                                            spacing: 1.5.w,
                                            runSpacing: 0.8.h,
                                            children: [
                                              _buildMetadataChip(theme, Icons.my_location_rounded, event.focus),
                                              _buildMetadataChip(theme, Icons.people_rounded, event.expectedProfiles),
                                              _buildMetadataChip(theme, Icons.how_to_reg_rounded, event.registration),
                                            ],
                                          ),
                                          SizedBox(height: 2.h),

                                          // Timeline layout for Date & Venue
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 1.w),
                                            child: Column(
                                              children: [
                                                // Date row
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Column(
                                                      children: [
                                                        Container(
                                                          width: 14,
                                                          height: 14,
                                                          decoration: BoxDecoration(
                                                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                                            shape: BoxShape.circle,
                                                            border: Border.all(
                                                              color: theme.colorScheme.primary,
                                                              width: 1.5,
                                                            ),
                                                          ),
                                                          child: Center(
                                                            child: Container(
                                                              width: 5,
                                                              height: 5,
                                                              decoration: BoxDecoration(
                                                                color: theme.colorScheme.primary,
                                                                shape: BoxShape.circle,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          width: 1.5,
                                                          height: 20,
                                                          color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(width: 3.w),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            'DATE & TIME',
                                                            style: TextStyle(
                                                              fontSize: AppTypography.labelMedium,
                                                              fontWeight: AppTypography.extraBold,
                                                              letterSpacing: 0.5,
                                                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                                                            ),
                                                          ),
                                                          SizedBox(height: 0.2.h),
                                                          Text(
                                                            '${event.date} • ${event.time}',
                                                            style: theme.textTheme.bodyMedium?.copyWith(
                                                              color: theme.colorScheme.onSurface,
                                                              fontWeight: AppTypography.semiBold,
                                                              fontSize: AppTypography.bodyMedium,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 0.5.h),
                                                // Venue row
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Column(
                                                      children: [
                                                        Container(
                                                          width: 14,
                                                          height: 14,
                                                          decoration: BoxDecoration(
                                                            color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                                                            shape: BoxShape.circle,
                                                            border: Border.all(
                                                              color: theme.colorScheme.secondary,
                                                              width: 1.5,
                                                            ),
                                                          ),
                                                          child: Center(
                                                            child: Container(
                                                              width: 5,
                                                              height: 5,
                                                              decoration: BoxDecoration(
                                                                color: theme.colorScheme.secondary,
                                                                shape: BoxShape.circle,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(width: 3.w),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            'VENUE LOCATION',
                                                            style: TextStyle(
                                                              fontSize: AppTypography.labelMedium,
                                                              fontWeight: AppTypography.extraBold,
                                                              letterSpacing: 0.5,
                                                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                                                            ),
                                                          ),
                                                          SizedBox(height: 0.2.h),
                                                          Text(
                                                            event.venue,
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: theme.textTheme.bodyMedium?.copyWith(
                                                              color: theme.colorScheme.onSurface,
                                                              fontWeight: AppTypography.medium,
                                                              fontSize: AppTypography.bodyMedium,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 2.5.h),

                                           // Action Buttons:
                                           // 1. Prominent WhatsApp Inquiry / RSVP Button
                                           TactilePressable(
                                             onTap: () => _whatsappInquiry(event),
                                             pressedScale: 0.97,
                                             child: Container(
                                               width: double.infinity,
                                               padding: EdgeInsets.symmetric(vertical: 1.2.h),
                                               decoration: BoxDecoration(
                                                 gradient: const LinearGradient(
                                                   colors: [Color(0xFF25D366), Color(0xFF128C7E)],
                                                 ),
                                                 borderRadius: BorderRadius.circular(12),
                                                 boxShadow: [
                                                   BoxShadow(
                                                     color: const Color(0xFF25D366).withValues(alpha: 0.25),
                                                     blurRadius: 8,
                                                     offset: const Offset(0, 3),
                                                   ),
                                                 ],
                                               ),
                                               child: Center(
                                                 child: Row(
                                                   mainAxisAlignment: MainAxisAlignment.center,
                                                   children: [
                                                     const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 16),
                                                     const SizedBox(width: 6),
                                                     Text(
                                                       'WhatsApp Inquiry / RSVP',
                                                       style: AppTypography.headingStyle(
                                                         fontSize: AppTypography.bodyMedium,
                                                         fontWeight: AppTypography.bold,
                                                         color: Colors.white,
                                                       ),
                                                     ),
                                                   ],
                                                 ),
                                               ),
                                             ),
                                           ),
                                           SizedBox(height: 1.2.h),

                                           // 2. Row of 2 Action Buttons: View Details & Call Organizer
                                           Row(
                                             children: [
                                               // View Details Button
                                               Expanded(
                                                 child: TactilePressable(
                                                   onTap: () {
                                                     HapticFeedback.lightImpact();
                                                     _viewEventDetails(event);
                                                   },
                                                   pressedScale: 0.96,
                                                   child: Container(
                                                     padding: EdgeInsets.symmetric(vertical: 1.1.h),
                                                     decoration: BoxDecoration(
                                                       borderRadius: BorderRadius.circular(12),
                                                       border: Border.all(
                                                         color: theme.colorScheme.primary.withValues(alpha: 0.5),
                                                         width: 1.2,
                                                       ),
                                                     ),
                                                     child: Center(
                                                       child: Row(
                                                         mainAxisAlignment: MainAxisAlignment.center,
                                                         children: [
                                                           Icon(
                                                             Icons.visibility_outlined,
                                                             size: 15,
                                                             color: theme.colorScheme.primary,
                                                           ),
                                                           const SizedBox(width: 4),
                                                           Flexible(
                                                             child: Text(
                                                               localizations?.viewVenue ?? 'View Details',
                                                               maxLines: 1,
                                                               overflow: TextOverflow.ellipsis,
                                                               style: AppTypography.headingStyle(
                                                                 fontSize: AppTypography.bodySmall,
                                                                 fontWeight: AppTypography.bold,
                                                                 color: theme.colorScheme.primary,
                                                               ),
                                                             ),
                                                           ),
                                                         ],
                                                       ),
                                                     ),
                                                   ),
                                                 ),
                                               ),
                                               SizedBox(width: 2.5.w),

                                               // Direct Phone Call Button
                                               Expanded(
                                                 child: TactilePressable(
                                                   onTap: () {
                                                     HapticFeedback.mediumImpact();
                                                     _callOrganizer(
                                                       event.contact,
                                                       event.id,
                                                       event.title,
                                                     );
                                                   },
                                                   pressedScale: 0.96,
                                                   child: Container(
                                                     padding: EdgeInsets.symmetric(vertical: 1.1.h),
                                                     decoration: BoxDecoration(
                                                       color: theme.colorScheme.primary,
                                                       borderRadius: BorderRadius.circular(12),
                                                       boxShadow: [
                                                         BoxShadow(
                                                           color: theme.colorScheme.primary.withValues(alpha: 0.25),
                                                           blurRadius: 8,
                                                           offset: const Offset(0, 3),
                                                         ),
                                                       ],
                                                     ),
                                                     child: Center(
                                                       child: Row(
                                                         mainAxisAlignment: MainAxisAlignment.center,
                                                         children: [
                                                           const Icon(Icons.phone_rounded, color: Colors.white, size: 14),
                                                           const SizedBox(width: 4),
                                                           Flexible(
                                                             child: Text(
                                                               localizations?.callOrganizer ?? 'Call Organizer',
                                                               maxLines: 1,
                                                               overflow: TextOverflow.ellipsis,
                                                               style: AppTypography.headingStyle(
                                                                 fontSize: AppTypography.bodySmall,
                                                                 fontWeight: AppTypography.bold,
                                                                 color: Colors.white,
                                                               ),
                                                             ),
                                                           ),
                                                         ],
                                                       ),
                                                     ),
                                                   ),
                                                 ),
                                               ),
                                             ],
                                           ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
            SizedBox(height: 2.h),

            // 🏢 Organizer Partnership Callout Card
            _buildOrganizerPartnerBanner(theme, localizations),
          ],
        ),
      ),
    );
  }

  Widget _buildOrganizerPartnerBanner(ThemeData theme, AppLocalizations? l10n) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.5.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F1F2B) : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFD97706).withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD97706).withValues(alpha: isDark ? 0.15 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.campaign_rounded, color: Color(0xFFD97706), size: 22),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Are you a Melava Organizer? 📢',
                      style: TextStyle(
                        fontSize: AppTypography.headingSmall,
                        fontWeight: AppTypography.black,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'List your community Vadhu-Var Melava on BanjaraBio for Free & connect with 50,000+ candidates.',
                      style: TextStyle(
                        fontSize: AppTypography.labelSmall,
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          TactilePressable(
            onTap: _suggestEvent,
            pressedScale: 0.96,
            child: Container(
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF880E4F), Color(0xFF961B33)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF961B33).withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Submit Melava on WhatsApp',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: AppTypography.bold,
                        fontSize: AppTypography.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BanjaraPatternPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  const BanjaraPatternPainter({
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintPrimary = Paint()
      ..color = primaryColor.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final paintSecondary = Paint()
      ..color = secondaryColor.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const double step = 24.0;
    
    // Draw diagonal grid (representing cross-stitches)
    for (double i = -size.height; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), paintPrimary);
    }
    for (double i = 0; i < size.width + size.height; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i - size.height, size.height), paintPrimary);
    }

    // Draw circular mirror shapes and surrounding star bursts representing embroidery details
    final fillPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;
    
    final borderPaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (double x = step * 2; x < size.width; x += step * 4) {
      for (double y = step * 2; y < size.height; y += step * 4) {
        // Mirror circles (traditionally key to Banjara embroidery)
        canvas.drawCircle(Offset(x, y), 5.0, fillPaint);
        canvas.drawCircle(Offset(x, y), 5.0, borderPaint);

        // Petal lines radiating from the mirrors (creating tiny stars/mandalas)
        for (int angle = 0; angle < 360; angle += 45) {
          final radians = angle * 3.1415926535 / 180.0;
          final double startX = x + 5.0 * cos(radians);
          final double startY = y + 5.0 * sin(radians);
          final double endX = x + 8.0 * cos(radians);
          final double endY = y + 8.0 * sin(radians);
          canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paintSecondary);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


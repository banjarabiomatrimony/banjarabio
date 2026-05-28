import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:banjarabio/core/services/persistent_cache_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:banjarabio/core/models/banner_model.dart';
import 'package:banjarabio/core/repositories/banner_repository.dart';
import 'package:banjarabio/widgets/shimmer_widget.dart';

class OfferBannerWidget extends StatefulWidget {
  final String? gender;
  final String? currentPlan;
  final BannerRepository? repository;

  const OfferBannerWidget({
    super.key,
    this.gender,
    this.currentPlan,
    this.repository,
  });

  @override
  State<OfferBannerWidget> createState() => _OfferBannerWidgetState();
}

class _OfferBannerWidgetState extends State<OfferBannerWidget> {
  late final BannerRepository _bannerRepository;
  List<BannerModel> _banners = [];
  bool _isLoading = true;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _bannerRepository = widget.repository ?? BannerRepository();
    _loadBanners();
  }

  Future<void> _loadBanners() async {
    final response = await _bannerRepository.getActiveBanners(
      gender: widget.gender,
      currentPlan: widget.currentPlan,
    );

    if (mounted) {
      response.fold(
        onSuccess: (banners) {
          setState(() {
            _banners = banners;
            _isLoading = false;
          });
        },
        onFailure: (_) {
          setState(() => _isLoading = false);
        },
      );
    }
  }

  void _onBannerTap(BannerModel banner) async {
    if (banner.actionUrl != null && banner.actionUrl!.isNotEmpty) {
      final url = Uri.parse(banner.actionUrl!);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: ShimmerWidget.rectangular(
          height: 18.h,
          shapeBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    }

    if (_banners.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 18.h,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _banners.length,
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return GestureDetector(
                onTap: () => _onBannerTap(banner),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: banner.imageUrl,
                      fit: BoxFit.cover,
                      cacheManager: PersistentCacheManager.instance,
                      placeholder: (context, url) => ShimmerWidget.rectangular(height: 18.h),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (_banners.length > 1) ...[
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _banners.length,
              (index) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[300],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

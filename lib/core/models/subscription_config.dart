import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:meta/meta.dart';
import 'package:banjarabio/core/models/subscription_model.dart';
import 'package:banjarabio/core/models/trust_score_config.dart';

/// Plan features configuration with MRP-based 3-layer discount system.
///
/// Pricing Layers:
///   Layer 1 (MRP → Offer): Bulk discount for longer durations.
///   Layer 2 (Offer → Trust): Trust Score discount (5-30%).
///   Layer 3 (Trust → Final): Coupon code discount.
@immutable
class PlanFeatures {
  // ── Core Pricing ──────────────────────────────────────────────────────────
  final int mrp; // Full MRP (anchor price) in rupees
  final int price; // Offer price after bulk discount, in rupees
  final int duration; // in months (999 = Till U Marry / Lifetime)
  final int bulkDiscountPercent; // 0, 20, 30, 40, 50, 60

  // ── Self-Service Features ─────────────────────────────────────────────────
  final int profileViewsPerDay;
  final int photosLimit;
  final int sharesPerMonth;
  final int bookmarksLimit;
  final bool messaging;
  final bool advancedFilters;
  final int profileBoostPerMonth;
  final bool verificationBadge;
  final bool adFree;
  final bool prioritySupport;
  final bool matchmakerSupport;
  final bool allowFirstMessage;
  final int newChatsPerWeek; // 0 = no initiation, 999 = unlimited

  // ── VIP-Exclusive Features ────────────────────────────────────────────────
  final bool isVip;
  final int contactUnlocksPerMonth; // Direct number/email unlocks
  final int handpickedMatchesPerWeek; // Curated matches via WhatsApp
  final bool hasPersonalManager; // Dedicated relationship manager
  final bool hasProfileMakeover; // Professional profile editing
  final bool hasFeaturedBadge; // "Elite Verified" gold badge
  final bool hasIncognitoMode; // Private profile browsing
  final bool hasBiodataPremium; // Biodata Premium included free

  const PlanFeatures({
    required this.mrp,
    required this.price,
    required this.duration,
    this.bulkDiscountPercent = 0,
    required this.profileViewsPerDay,
    required this.photosLimit,
    required this.sharesPerMonth,
    required this.bookmarksLimit,
    this.messaging = false,
    this.advancedFilters = false,
    this.profileBoostPerMonth = 0,
    this.verificationBadge = false,
    this.adFree = false,
    this.prioritySupport = false,
    this.matchmakerSupport = false,
    this.allowFirstMessage = false,
    this.newChatsPerWeek = 0,
    this.isVip = false,
    this.contactUnlocksPerMonth = 0,
    this.handpickedMatchesPerWeek = 0,
    this.hasPersonalManager = false,
    this.hasProfileMakeover = false,
    this.hasFeaturedBadge = false,
    this.hasIncognitoMode = false,
    this.hasBiodataPremium = false,
  });

  /// Get offer price in paise for Razorpay (uses offer price, not MRP)
  int get priceInPaise => price * 100;

  /// Get display price with rupee symbol
  String displayPrice([AppLocalizations? l10n]) {
    if (price == 0) return l10n?.notAvailable ?? 'Free';
    final symbol = l10n?.rupeeSymbol ?? '₹';
    return '$symbol$price';
  }

  /// Get MRP display with rupee symbol
  String displayMrp([AppLocalizations? l10n]) {
    final symbol = l10n?.rupeeSymbol ?? '₹';
    return '$symbol$mrp';
  }

  /// Get per month price for comparison (based on offer price)
  double get pricePerMonth {
    if (duration == 0 || duration >= 999) return 0;
    return price / duration;
  }

  /// Savings amount (MRP - Offer Price)
  int get bulkSavings => mrp - price;

  /// Get discounted price based on Trust Score (applied to offer price)
  int getDiscountedPrice(int trustScore) {
    if (price == 0) return 0;
    return TrustScoreConfig.getDiscountedPrice(price, trustScore);
  }

  /// Get final price after Trust Score + Coupon discount
  int getFinalPrice(int trustScore, {int couponPercent = 0}) {
    final afterTrust = getDiscountedPrice(trustScore);
    if (couponPercent <= 0) return afterTrust;
    final couponDiscount = (afterTrust * couponPercent / 100).round();
    return afterTrust - couponDiscount;
  }

  /// Total savings from MRP to final price (all 3 layers)
  int getTotalSavings(int trustScore, {int couponPercent = 0}) {
    return mrp - getFinalPrice(trustScore, couponPercent: couponPercent);
  }

  /// Whether this is a "Till U Marry" / Lifetime plan
  bool get isLifetime => duration >= 999;
}

// =============================================================================
// Subscription Configuration for All Plans
// =============================================================================

@immutable
class SubscriptionConfig {
  // ─────────────────────────────────────────────────────────────────────────
  // PLAN VISIBILITY TOGGLE
  // Add or remove PlanType entries to show/hide them in the app UI.
  // All plan definitions remain intact for existing subscribers.
  // ─────────────────────────────────────────────────────────────────────────
  static const Set<PlanType> enabledPlans = {
    PlanType.free,
    PlanType.mass_market,
    PlanType.mass_market_annual,
    PlanType.standard,
    PlanType.silver,
    PlanType.gold,
    PlanType.platinum,
    PlanType.eternal,
    PlanType.elite,
    PlanType.royal,
    PlanType.eternal_elite,
  };

  /// Check if a plan is currently enabled for display
  static bool isPlanEnabled(PlanType planType) =>
      enabledPlans.contains(planType);

  /// Check if any VIP plans are currently enabled
  static bool get hasEnabledVipPlans => enabledPlans.any((p) => p.isVipPlan);

  // ─────────────────────────────────────────────────────────────────────────
  // FREE PLAN
  // ─────────────────────────────────────────────────────────────────────────
  static const free = PlanFeatures(
    mrp: 0,
    price: 0,
    duration: 0,
    profileViewsPerDay: 5,
    photosLimit: 1,
    sharesPerMonth: 3,
    bookmarksLimit: 3,
    allowFirstMessage: true,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // MASS-MARKET PLANS (₹50/month or ₹200/year)
  // Ultra-low-barrier communication upgrade for mass adoption.
  // Active until 100,000 downloads milestone.
  // ─────────────────────────────────────────────────────────────────────────

  /// Mass-Market Monthly – ₹20 for 1 month
  static const massMarketMonthly = PlanFeatures(
    mrp: 50,
    price: 20,
    duration: 1,
    bulkDiscountPercent: 60,
    profileViewsPerDay: 10,
    photosLimit: 2,
    sharesPerMonth: 5,
    bookmarksLimit: 10,
    messaging: true,
    newChatsPerWeek: 2,
  );

  /// Mass-Market Annual – ₹200 for 12 months
  static const massMarketAnnual = PlanFeatures(
    mrp: 240,
    price: 200,
    duration: 12,
    bulkDiscountPercent: 17,
    profileViewsPerDay: 10,
    photosLimit: 2,
    sharesPerMonth: 5,
    bookmarksLimit: 10,
    messaging: true,
    newChatsPerWeek: 2,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // SELF-SERVICE PLANS (Tab 1)
  // MRP base: ₹1,500/month → bulk discounts for longer durations
  // ─────────────────────────────────────────────────────────────────────────

  /// Standard plan – ₹1,500 for 1 month (0% discount)
  static const standard = PlanFeatures(
    mrp: 1500,
    price: 1500,
    duration: 1,
    profileViewsPerDay: 100,
    photosLimit: 5,
    sharesPerMonth: 999, // unlimited
    bookmarksLimit: 999, // unlimited
    messaging: true,
    newChatsPerWeek: 999, // unlimited
    advancedFilters: true,
    profileBoostPerMonth: 1,
    adFree: true,
    contactUnlocksPerMonth: 5,
  );

  /// Silver plan – MRP ₹4,500, Offer ₹3,600 (20% OFF) for 3 months
  static const silver = PlanFeatures(
    mrp: 4500,
    price: 3600,
    duration: 3,
    bulkDiscountPercent: 20,
    profileViewsPerDay: 150,
    photosLimit: 7,
    sharesPerMonth: 999,
    bookmarksLimit: 999,
    messaging: true,
    newChatsPerWeek: 999,
    advancedFilters: true,
    profileBoostPerMonth: 2,
    verificationBadge: true,
    adFree: true,
    contactUnlocksPerMonth: 10,
  );

  /// Gold plan – MRP ₹9,000, Offer ₹6,300 (30% OFF) for 6 months (MOST POPULAR)
  static const gold = PlanFeatures(
    mrp: 9000,
    price: 6300,
    duration: 6,
    bulkDiscountPercent: 30,
    profileViewsPerDay: 999, // unlimited
    photosLimit: 10,
    sharesPerMonth: 999,
    bookmarksLimit: 999,
    messaging: true,
    newChatsPerWeek: 999,
    advancedFilters: true,
    profileBoostPerMonth: 3,
    verificationBadge: true,
    adFree: true,
    prioritySupport: true,
    contactUnlocksPerMonth: 25,
  );

  /// Platinum plan – MRP ₹18,000, Offer ₹10,800 (40% OFF) for 1 year (BEST VALUE)
  static const platinum = PlanFeatures(
    mrp: 18000,
    price: 10800,
    duration: 12,
    bulkDiscountPercent: 40,
    profileViewsPerDay: 999,
    photosLimit: 15,
    sharesPerMonth: 999,
    bookmarksLimit: 999,
    messaging: true,
    newChatsPerWeek: 999,
    advancedFilters: true,
    profileBoostPerMonth: 5,
    verificationBadge: true,
    adFree: true,
    prioritySupport: true,
    matchmakerSupport: true,
    contactUnlocksPerMonth: 50,
  );

  /// Eternal plan – MRP ₹30,000, Offer ₹15,000 (50% OFF) – Till U Marry
  static const eternal = PlanFeatures(
    mrp: 30000,
    price: 15000,
    duration: 999, // Lifetime / Till U Marry
    bulkDiscountPercent: 50,
    profileViewsPerDay: 999,
    photosLimit: 15,
    sharesPerMonth: 999,
    bookmarksLimit: 999,
    messaging: true,
    newChatsPerWeek: 999,
    advancedFilters: true,
    profileBoostPerMonth: 5,
    verificationBadge: true,
    adFree: true,
    prioritySupport: true,
    matchmakerSupport: true,
    hasBiodataPremium: true,
    contactUnlocksPerMonth: 75,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // VIP MATCHMAKER PLANS (Tab 2)
  // Personal Concierge / Dedicated Matchmaker service
  // ─────────────────────────────────────────────────────────────────────────

  /// Elite – MRP ₹24,999, Offer ₹12,499 for 6 months
  static const elite = PlanFeatures(
    mrp: 24999,
    price: 12499,
    duration: 6,
    bulkDiscountPercent: 50,
    isVip: true,
    profileViewsPerDay: 999,
    photosLimit: 15,
    sharesPerMonth: 999,
    bookmarksLimit: 999,
    messaging: true,
    newChatsPerWeek: 999,
    advancedFilters: true,
    profileBoostPerMonth: 10,
    verificationBadge: true,
    adFree: true,
    prioritySupport: true,
    matchmakerSupport: true,
    contactUnlocksPerMonth: 100,
    handpickedMatchesPerWeek: 1,
    hasProfileMakeover: true,
    hasFeaturedBadge: true,
    hasIncognitoMode: true,
    hasBiodataPremium: true,
  );

  /// Royal – MRP ₹49,999, Offer ₹24,999 for 1 year
  static const royal = PlanFeatures(
    mrp: 49999,
    price: 24999,
    duration: 12,
    bulkDiscountPercent: 50,
    isVip: true,
    profileViewsPerDay: 999,
    photosLimit: 15,
    sharesPerMonth: 999,
    bookmarksLimit: 999,
    messaging: true,
    newChatsPerWeek: 999,
    advancedFilters: true,
    profileBoostPerMonth: 10,
    verificationBadge: true,
    adFree: true,
    prioritySupport: true,
    matchmakerSupport: true,
    contactUnlocksPerMonth: 250,
    handpickedMatchesPerWeek: 3,
    hasPersonalManager: true,
    hasProfileMakeover: true,
    hasFeaturedBadge: true,
    hasIncognitoMode: true,
    hasBiodataPremium: true,
  );

  /// Eternal Elite – MRP ₹99,999, Offer ₹49,999 – Lifetime
  static const eternalElite = PlanFeatures(
    mrp: 99999,
    price: 49999,
    duration: 999, // Lifetime
    bulkDiscountPercent: 50,
    isVip: true,
    profileViewsPerDay: 999,
    photosLimit: 999, // unlimited
    sharesPerMonth: 999,
    bookmarksLimit: 999,
    messaging: true,
    newChatsPerWeek: 999,
    advancedFilters: true,
    profileBoostPerMonth: 999, // unlimited
    verificationBadge: true,
    adFree: true,
    prioritySupport: true,
    matchmakerSupport: true,
    contactUnlocksPerMonth: 999, // unlimited
    handpickedMatchesPerWeek: 999, // daily / on-demand
    hasPersonalManager: true,
    hasProfileMakeover: true,
    hasFeaturedBadge: true,
    hasIncognitoMode: true,
    hasBiodataPremium: true,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // BIODATA UNLOCK (One-time Add-on)
  // ─────────────────────────────────────────────────────────────────────────

  static const biodataUnlock = PlanFeatures(
    mrp: 199,
    price: 199,
    duration: 99, // permanent for this user's profile
    profileViewsPerDay: 0,
    photosLimit: 0,
    sharesPerMonth: 0,
    bookmarksLimit: 0,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Plan Lookups
  // ─────────────────────────────────────────────────────────────────────────

  /// Get features for a specific plan type
  static PlanFeatures getFeatures(PlanType planType) {
    switch (planType) {
      case PlanType.mass_market:
        return massMarketMonthly;
      case PlanType.mass_market_annual:
        return massMarketAnnual;
      case PlanType.standard:
        return standard;
      case PlanType.silver:
        return silver;
      case PlanType.gold:
        return gold;
      case PlanType.platinum:
        return platinum;
      case PlanType.eternal:
        return eternal;
      case PlanType.elite:
        return elite;
      case PlanType.royal:
        return royal;
      case PlanType.eternal_elite:
        return eternalElite;
      case PlanType.biodata_unlock:
        return biodataUnlock;
      case PlanType.free:
      case PlanType.basic:
      case PlanType.premium:
      case PlanType.vip:
      case PlanType.unknown:
        return free;
    }
  }

  /// Get Self-Service paid plans for Tab 1
  /// - If isBvsVerified is true: returns exclusive ₹200/yr and ₹50/mo subsidized plans.
  /// - If isBvsVerified is false: returns full standard tiers (Standard, Silver, Gold, Platinum, Eternal).
  static List<MapEntry<PlanType, PlanFeatures>> getSelfServicePlans({bool isBvsVerified = false}) {
    if (isBvsVerified) {
      return const [
        MapEntry(PlanType.mass_market_annual, massMarketAnnual),
        MapEntry(PlanType.mass_market, massMarketMonthly),
      ];
    }
    return const [
      MapEntry(PlanType.standard, standard),
      MapEntry(PlanType.silver, silver),
      MapEntry(PlanType.gold, gold),
      MapEntry(PlanType.platinum, platinum),
      MapEntry(PlanType.eternal, eternal),
    ].where((entry) => enabledPlans.contains(entry.key)).toList();
  }

  /// Get VIP Matchmaker plans for Tab 2
  /// Filtered by [enabledPlans] toggle.
  static List<MapEntry<PlanType, PlanFeatures>> getVipPlans() {
    return const [
      MapEntry(PlanType.elite, elite),
      MapEntry(PlanType.royal, royal),
      MapEntry(PlanType.eternal_elite, eternalElite),
    ].where((entry) => enabledPlans.contains(entry.key)).toList();
  }

  /// Backward-compatible: returns Self-Service plans (was getAllPaidPlans)
  static List<MapEntry<PlanType, PlanFeatures>> getAllPaidPlans({bool isBvsVerified = false}) {
    return getSelfServicePlans(isBvsVerified: isBvsVerified);
  }

  /// Calculate savings vs monthly pricing
  static int calculateSavings(PlanType planType) {
    final features = getFeatures(planType);
    if (planType == PlanType.free) return 0;

    // Savings = MRP - Offer Price
    return features.bulkSavings;
  }

  /// Get plan display name with duration
  static String getDisplayName(PlanType planType, [AppLocalizations? l10n]) {
    final features = getFeatures(planType);
    if (planType == PlanType.free) return l10n?.notAvailable ?? 'Free';

    final monthsLabel = l10n?.months ?? 'Months';
    final yearLabel = l10n?.year ?? 'Year';
    final oneTimeLabel = l10n?.oneTime ?? 'One Time';

    switch (planType) {
      case PlanType.mass_market:
        return 'BVS Member - 1 $monthsLabel (₹20)';
      case PlanType.mass_market_annual:
        return l10n?.bvsVerifiedSpecialPlan != null
            ? '${l10n!.bvsVerifiedSpecialPlan} - 1 $yearLabel (₹200)'
            : 'BVS Member Special - 1 $yearLabel (₹200)';
      case PlanType.standard:
        final name = l10n?.standardPlanName ?? 'Standard';
        return '$name - 1 $monthsLabel';
      case PlanType.silver:
        final name = l10n?.silverPlanName ?? 'Silver';
        return '$name - ${features.duration} $monthsLabel';
      case PlanType.gold:
        final name = l10n?.goldPlanName ?? 'Gold';
        return '$name - ${features.duration} $monthsLabel';
      case PlanType.platinum:
        final name = l10n?.platinumPlanName ?? 'Platinum';
        return '$name - 1 $yearLabel';
      case PlanType.eternal:
        return l10n?.eternalPlanName ?? 'Eternal - Till U Marry';
      case PlanType.elite:
        return l10n?.elitePlanName ?? 'Elite - 6 $monthsLabel';
      case PlanType.royal:
        return l10n?.royalPlanName ?? 'Royal - 1 $yearLabel';
      case PlanType.eternal_elite:
        return l10n?.eternalElitePlanName ?? 'Eternal Elite - Lifetime';
      case PlanType.biodata_unlock:
        final name = l10n?.biodataUnlockPlanName ?? 'Biodata Premium';
        return '$name - $oneTimeLabel';
      case PlanType.basic:
        return l10n?.basicPlanName ?? 'Basic';
      case PlanType.premium:
        return l10n?.premiumPlanName ?? 'Premium';
      case PlanType.vip:
        return l10n?.vipPlanName ?? 'VIP';
      default:
        return l10n?.notAvailable ?? 'Free';
    }
  }

  /// Get plan description
  static String getDescription(PlanType planType, [AppLocalizations? l10n]) {
    switch (planType) {
      case PlanType.mass_market:
        return 'Start conversations with matches';
      case PlanType.mass_market_annual:
        return 'Save more with annual plan';
      case PlanType.standard:
        return l10n?.standardPlanDesc ?? 'Try premium features for a month';
      case PlanType.silver:
        return l10n?.silverPlanDesc ?? 'Perfect for getting started';
      case PlanType.gold:
        return l10n?.goldPlanDesc ?? 'Most popular - Best value';
      case PlanType.platinum:
        return l10n?.platinumPlanDesc ?? 'Ultimate experience with all features';
      case PlanType.eternal:
        return l10n?.eternalPlanDesc ?? 'Never worry about expiry again';
      case PlanType.elite:
        return l10n?.elitePlanDesc ?? 'Handpicked matches with VIP access';
      case PlanType.royal:
        return l10n?.royalPlanDesc ?? 'Dedicated manager finds your match';
      case PlanType.eternal_elite:
        return l10n?.eternalElitePlanDesc ?? 'Focus on your career, we find your partner';
      case PlanType.biodata_unlock:
        return l10n?.biodataUnlockPlanDesc ?? 'Unlock professional premium templates';
      case PlanType.free:
      case PlanType.basic:
      case PlanType.premium:
      case PlanType.vip:
      case PlanType.unknown:
        return l10n?.freePlanDesc ?? 'Try basic features';
    }
  }

  /// Check if user has unlimited feature
  static bool hasUnlimitedFeature(PlanType planType, String feature) {
    final features = getFeatures(planType);

    switch (feature) {
      case 'profileViews':
        return features.profileViewsPerDay >= 999;
      case 'shares':
        return features.sharesPerMonth >= 999;
      case 'bookmarks':
        return features.bookmarksLimit >= 999;
      case 'contactUnlocks':
        return features.contactUnlocksPerMonth >= 999;
      default:
        return false;
    }
  }

  /// Check if a plan is better than or equal to another plan.
  /// Used to prevent downgrades and duplicate purchases.
  static bool isPlanBetterOrEqual(PlanType current, PlanType target) {
    if (current == target) return true;
    if (target == PlanType.free) return true;

    // Tier order: Eternal Elite > Royal > Elite > Eternal > Platinum > Gold > Silver > Standard > Mass Market Annual > Mass Market > Free
    const tierOrder = {
      PlanType.eternal_elite: 10,
      PlanType.royal: 9,
      PlanType.elite: 8,
      PlanType.eternal: 7,
      PlanType.platinum: 6,
      PlanType.gold: 5,
      PlanType.silver: 4,
      PlanType.standard: 3,
      PlanType.mass_market_annual: 2,
      PlanType.mass_market: 1,
      PlanType.vip: 10,
      PlanType.premium: 6,
      PlanType.basic: 1,
      PlanType.free: 0,
      PlanType.unknown: 0,
    };

    final currentRank = tierOrder[current] ?? 0;
    final targetRank = tierOrder[target] ?? 0;

    return currentRank >= targetRank;
  }
}

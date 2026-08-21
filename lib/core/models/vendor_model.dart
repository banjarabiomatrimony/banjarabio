/// 🏢 Vendor Model for Banjara Wedding Marketplace (Network Effect)
class VendorModel {
  final String id;
  final String businessName;
  final String ownerName;
  final String phone;
  final String whatsapp;
  final String category; // 'dj_sound', 'mandap_decor', 'catering', 'photography', 'makeup_mehndi', 'guruji', 'banquet_hall', 'other'
  final String categoryLabel;
  final String state;
  final String district;
  final String city;
  final String address;
  final int experienceYears;
  final int startingPrice;
  final int? averagePrice;
  final String? aboutBusiness;
  final String? instagramUrl;
  final String? youtubeUrl;
  final String? websiteUrl;
  final Map<String, dynamic> specificAttributes; // Dynamic category-specific key-values
  final String verificationStatus; // 'pending', 'verified', 'rejected'
  final double rating;
  final int reviewCount;
  final DateTime createdAt;

  const VendorModel({
    required this.id,
    required this.businessName,
    required this.ownerName,
    required this.phone,
    required this.whatsapp,
    required this.category,
    required this.categoryLabel,
    required this.state,
    required this.district,
    required this.city,
    required this.address,
    required this.experienceYears,
    required this.startingPrice,
    this.averagePrice,
    this.aboutBusiness,
    this.instagramUrl,
    this.youtubeUrl,
    this.websiteUrl,
    this.specificAttributes = const {},
    this.verificationStatus = 'pending',
    this.rating = 5.0,
    this.reviewCount = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_name': businessName,
      'owner_name': ownerName,
      'phone': phone,
      'whatsapp': whatsapp,
      'category': category,
      'category_label': categoryLabel,
      'state': state,
      'district': district,
      'city': city,
      'address': address,
      'experience_years': experienceYears,
      'starting_price': startingPrice,
      'average_price': averagePrice,
      'about_business': aboutBusiness,
      'instagram_url': instagramUrl,
      'youtube_url': youtubeUrl,
      'website_url': websiteUrl,
      'specific_attributes': specificAttributes,
      'verification_status': verificationStatus,
      'rating': rating,
      'review_count': reviewCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    return VendorModel(
      id: json['id'] as String? ?? '',
      businessName: json['business_name'] as String? ?? '',
      ownerName: json['owner_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      whatsapp: json['whatsapp'] as String? ?? '',
      category: json['category'] as String? ?? 'other',
      categoryLabel: json['category_label'] as String? ?? 'Service',
      state: json['state'] as String? ?? '',
      district: json['district'] as String? ?? '',
      city: json['city'] as String? ?? '',
      address: json['address'] as String? ?? '',
      experienceYears: (json['experience_years'] as num?)?.toInt() ?? 1,
      startingPrice: (json['starting_price'] as num?)?.toInt() ?? 0,
      averagePrice: (json['average_price'] as num?)?.toInt(),
      aboutBusiness: json['about_business'] as String?,
      instagramUrl: json['instagram_url'] as String?,
      youtubeUrl: json['youtube_url'] as String?,
      websiteUrl: json['website_url'] as String?,
      specificAttributes: json['specific_attributes'] is Map
          ? Map<String, dynamic>.from(json['specific_attributes'] as Map)
          : {},
      verificationStatus: json['verification_status'] as String? ?? 'pending',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

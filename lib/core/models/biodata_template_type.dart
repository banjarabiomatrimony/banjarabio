enum BiodataTemplateType {
  modern,
  classic,
  minimal,
  traditional,
  premium,
  simple,
}

extension BiodataTemplateTypeExtension on BiodataTemplateType {
  String get displayName {
    switch (this) {
      case BiodataTemplateType.modern:
        return 'Modern';
      case BiodataTemplateType.classic:
        return 'Classic';
      case BiodataTemplateType.minimal:
        return 'Minimal';
      case BiodataTemplateType.traditional:
        return 'Traditional';
      case BiodataTemplateType.premium:
        return 'Premium';
      case BiodataTemplateType.simple:
        return 'Simple';
    }
  }

  bool get isPremium {
    // All of these are premium marriage templates now
    return true;
  }
}

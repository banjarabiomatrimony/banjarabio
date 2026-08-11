enum BiodataTemplateType {
  royalGold,
  sacredMaroon,
  lotusGreen,
  peacockBlue,
  mandalaRose,
  saffronDiya,
  paisleyPurple,
  divineTeal,
  burgundyLattice,
  ivoryClassic,
}

extension BiodataTemplateTypeExtension on BiodataTemplateType {
  String get displayName {
    switch (this) {
      case BiodataTemplateType.royalGold:
        return 'Royal Gold';
      case BiodataTemplateType.sacredMaroon:
        return 'Sacred Maroon';
      case BiodataTemplateType.lotusGreen:
        return 'Lotus Green';
      case BiodataTemplateType.peacockBlue:
        return 'Peacock Blue';
      case BiodataTemplateType.mandalaRose:
        return 'Mandala Rose';
      case BiodataTemplateType.saffronDiya:
        return 'Saffron Diya';
      case BiodataTemplateType.paisleyPurple:
        return 'Paisley Purple';
      case BiodataTemplateType.divineTeal:
        return 'Divine Teal';
      case BiodataTemplateType.burgundyLattice:
        return 'Burgundy Lattice';
      case BiodataTemplateType.ivoryClassic:
        return 'Ivory Classic';
    }
  }

  bool get isPremium {
    // Temp bypass for growth campaign: return false for all templates.
    // In future, change this back to true to re-monetize.
    return false;
  }
}

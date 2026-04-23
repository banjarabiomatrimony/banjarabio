import 'package:flutter/material.dart';
import 'package:banjarabio/core/models/biodata_template_type.dart';

class BiodataTemplate {
  final BiodataTemplateType type;
  final String name;
  final String assetPath;
  final Color accentColor;

  const BiodataTemplate({
    required this.type,
    required this.name,
    required this.assetPath,
    required this.accentColor,
  });
}

const List<BiodataTemplate> kBiodataTemplates = [
  BiodataTemplate(
    type: BiodataTemplateType.modern,
    name: 'Modern',
    assetPath: 'assets/images/biodata_templates/template_1.png',
    accentColor: Color(0xFF8B1A1A),
  ),
  BiodataTemplate(
    type: BiodataTemplateType.classic,
    name: 'Classic',
    assetPath: 'assets/images/biodata_templates/template_2.png',
    accentColor: Color(0xFFD4860B),
  ),
  BiodataTemplate(
    type: BiodataTemplateType.minimal,
    name: 'Minimal',
    assetPath: 'assets/images/biodata_templates/template_3.png',
    accentColor: Color(0xFF2E7D32),
  ),
  BiodataTemplate(
    type: BiodataTemplateType.traditional,
    name: 'Traditional',
    assetPath: 'assets/images/biodata_templates/template_4.png',
    accentColor: Color(0xFF6A1B9A),
  ),
  BiodataTemplate(
    type: BiodataTemplateType.premium,
    name: 'Premium',
    assetPath: 'assets/images/biodata_templates/template_5.png',
    accentColor: Color(0xFFB8860B),
  ),
  BiodataTemplate(
    type: BiodataTemplateType.simple,
    name: 'Simple',
    assetPath: 'assets/images/biodata_templates/template_6.png',
    accentColor: Color(0xFFC62828),
  ),
];

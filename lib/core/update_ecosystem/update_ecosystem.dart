/// 📦 Universal In-App Update Ecosystem
///
/// Enterprise-grade, plug-and-play in-app update and version management system
/// for Flutter applications.
library;

// Layer 1: Models
export 'layer1_models/app_version.dart';
export 'layer1_models/update_type.dart';
export 'layer1_models/update_info.dart';
export 'layer1_models/update_config.dart';

// Layer 2: Contracts
export 'layer2_contracts/update_config_source.dart';
export 'layer2_contracts/update_engine.dart';

// Layer 3: Sources
export 'layer3_sources/supabase_update_source.dart';
export 'layer3_sources/mock_update_source.dart';

// Layer 4: Engines
export 'layer4_engines/store_redirect_engine.dart';
export 'layer4_engines/composite_update_engine.dart';

// Layer 5: Storage
export 'layer5_storage/update_cooldown_manager.dart';

// Layer 6: UI
export 'layer6_ui/update_modal_theme.dart';
export 'layer6_ui/force_update_dialog.dart';
export 'layer6_ui/soft_update_sheet.dart';

// Layer 7: Orchestrator
export 'layer7_orchestrator/app_update_manager.dart';

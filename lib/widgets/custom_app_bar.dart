import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/theme/app_colors.dart';

/// Custom app bar for Banjara matrimonial app
/// Implements cultural minimalism with clean typography and respectful design
/// Supports various configurations for different screen contexts
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Title text to display
  final String? title;

  /// Custom title widget (takes precedence over title if provided)
  final Widget? titleWidget;

  /// Optional subtitle for additional context
  final String? subtitle;

  /// Leading widget (typically back button or menu icon)
  final Widget? leading;

  /// Custom leading width
  final double? leadingWidth;

  /// Action widgets displayed on the right side
  final List<Widget>? actions;

  /// Whether to show back button automatically
  final bool automaticallyImplyLeading;

  /// Whether to center the title
  final bool centerTitle;

  /// Custom title spacing
  final double? titleSpacing;

  /// Custom background color (defaults to theme color)
  final Color? backgroundColor;

  /// Custom foreground color (defaults to theme color)
  final Color? foregroundColor;

  /// Elevation of the app bar
  final double elevation;

  /// Bottom widget (typically TabBar)
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.leading,
    this.leadingWidth,
    this.titleSpacing,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 1.0,
    this.bottom,
  }) : assert(title != null || titleWidget != null, 'Either title or titleWidget must be provided');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appBarTheme = theme.appBarTheme;

    return AppBar(
      titleSpacing: titleSpacing,
      title: titleWidget ??
          (subtitle != null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: centerTitle
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.start,
                  children: [
                    Text(title ?? '', style: appBarTheme.titleTextStyle),
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: foregroundColor ?? appBarTheme.foregroundColor,
                      ),
                    ),
                  ],
                )
              : Text(
                  title ?? '',
                  style: appBarTheme.titleTextStyle?.copyWith(
                    color: foregroundColor ?? appBarTheme.foregroundColor,
                  ),
                )),
      leading: leading,
      leadingWidth: leadingWidth,
      actions: actions,
      automaticallyImplyLeading: automaticallyImplyLeading,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? appBarTheme.backgroundColor,
      foregroundColor: foregroundColor ?? appBarTheme.foregroundColor,
      elevation: elevation,
      bottom: bottom,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarIconBrightness: theme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
        statusBarBrightness: theme.brightness,
      ),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));
}

/// Specialized app bar variant for profile screens with large title
class CustomProfileAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  /// Profile name or title
  final String title;

  /// Optional verification badge
  final bool isVerified;

  /// Action widgets
  final List<Widget>? actions;

  /// Background color
  final Color? backgroundColor;

  const CustomProfileAppBar({
    super.key,
    required this.title,
    this.isVerified = false,
    this.actions,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              title,
              style: theme.appBarTheme.titleTextStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isVerified) ...[
            const SizedBox(width: 6),
            Icon(Icons.verified, size: 20, color: theme.colorScheme.secondary),
          ],
        ],
      ),
      actions: actions,
      centerTitle: true,
      backgroundColor: backgroundColor ?? theme.appBarTheme.backgroundColor,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarIconBrightness: theme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
        statusBarBrightness: theme.brightness,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Specialized app bar variant for search screens
class CustomSearchAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  /// Search query text
  final String query;

  /// Callback when search text changes
  final ValueChanged<String>? onQueryChanged;

  /// Callback when search is submitted
  final ValueChanged<String>? onQuerySubmitted;

  /// Hint text for search field
  final String hintText;

  /// Whether to show filter action
  final bool showFilterAction;

  /// Callback when filter is tapped
  final VoidCallback? onFilterTap;

  const CustomSearchAppBar({
    super.key,
    required this.query,
    this.onQueryChanged,
    this.onQuerySubmitted,
    this.hintText = 'Search profiles...',
    this.showFilterAction = true,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      title: TextField(
        controller: TextEditingController(text: query)
          ..selection = TextSelection.collapsed(offset: query.length),
        onChanged: onQueryChanged,
        onSubmitted: onQuerySubmitted,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onPrimary.withValues(alpha: AppColors.opacity70),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          prefixIcon: const Icon(Icons.search, size: 24),
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () => onQueryChanged?.call(''),
                  tooltip: AppLocalizations.of(context)?.clearSearch ?? 'Clear search',
                )
              : null,
        ),
      ),
      actions: showFilterAction
          ? [
              IconButton(
                icon: const Icon(Icons.filter_list, size: 24),
                onPressed: onFilterTap,
                tooltip: AppLocalizations.of(context)?.filterProfiles ?? 'Filter profiles',
              ),
            ]
          : null,
      backgroundColor: theme.appBarTheme.backgroundColor,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarIconBrightness: theme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
        statusBarBrightness: theme.brightness,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

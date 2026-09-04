import 'package:flutter/material.dart';

import 'package:patch_bro/core/theme/app_colors.dart';

class AppBottomNavDestination {
  const AppBottomNavDestination({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class AppBottomNavBar extends StatefulWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.destinations,
    required this.onDestinationSelected,
  }) : assert(destinations.length == 5, 'AppBottomNavBar requires exactly 5 destinations.');

  final int currentIndex;
  final List<AppBottomNavDestination> destinations;
  final ValueChanged<int> onDestinationSelected;

  @override
  State<AppBottomNavBar> createState() => _AppBottomNavBarState();
}

class _AppBottomNavBarState extends State<AppBottomNavBar> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late int _previousIndex;

  static const _animationDuration = Duration(milliseconds: 350);

  // static const _animationCurve = Curves.easeInOutCubic;

  @override
  void initState() {
    super.initState();

    _previousIndex = widget.currentIndex;

    _controller = AnimationController(vsync: this, duration: _animationDuration, value: 1.0);
  }

  @override
  void didUpdateWidget(covariant AppBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.currentIndex != widget.currentIndex) {
      _previousIndex = oldWidget.currentIndex;

      _controller
        ..stop()
        ..value = 0.0
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;

          final horizontalPadding = availableWidth < 360 ? 4.0 : 8.0;

          final innerWidth = availableWidth - (horizontalPadding * 2);

          return Container(
            height: 66,
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(34),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final animationValue = Curves.easeInOutCubic.transform(_controller.value);

                return _buildNavigationContent(
                  context: context,
                  innerWidth: innerWidth,
                  primaryColor: primaryColor,
                  animationValue: animationValue,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavigationContent({
    required BuildContext context,
    required double innerWidth,
    required Color primaryColor,
    required double animationValue,
  }) {
    final previousLayout = _calculateLayout(
      context: context,
      selectedIndex: _previousIndex,
      totalWidth: innerWidth,
    );

    final currentLayout = _calculateLayout(
      context: context,
      selectedIndex: widget.currentIndex,
      totalWidth: innerWidth,
    );

    final widths = <double>[];

    for (int index = 0; index < widget.destinations.length; index++) {
      widths.add(_lerp(previousLayout.widths[index], currentLayout.widths[index], animationValue));
    }

    final indicatorLeft = _lerp(
      previousLayout.indicatorLeft,
      currentLayout.indicatorLeft,
      animationValue,
    );

    final indicatorWidth = _lerp(
      previousLayout.indicatorWidth,
      currentLayout.indicatorWidth,
      animationValue,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        children: [
          // Animated orange selection pill

          Positioned(
            left: indicatorLeft,
            top: 0,
            width: indicatorWidth,
            height: 52,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),

          // Navigation items
          Row(
            children: [
              for (int index = 0; index < widget.destinations.length; index++)
                SizedBox(
                  width: widths[index],
                  height: 52,
                  child: _BottomNavItem(
                    destination: widget.destinations[index],
                    isSelected: index == widget.currentIndex,
                    onTap: () {
                      if (index != widget.currentIndex) {
                        widget.onDestinationSelected(index);
                      }
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Calculate the complete layout for a selected item.

  _NavigationLayout _calculateLayout({
    required BuildContext context,
    required int selectedIndex,
    required double totalWidth,
  }) {
    final selectedWidth = _calculateSelectedWidth(
      context: context,
      index: selectedIndex,
      totalWidth: totalWidth,
    );

    const itemCount = 5;

    final inactiveWidth = (totalWidth - selectedWidth) / (itemCount - 1);

    final widths = <double>[];

    for (int index = 0; index < itemCount; index++) {
      widths.add(index == selectedIndex ? selectedWidth : inactiveWidth);
    }

    double indicatorLeft = 0;

    for (int index = 0; index < selectedIndex; index++) {
      indicatorLeft += widths[index];
    }

    return _NavigationLayout(
      widths: widths,
      indicatorLeft: indicatorLeft,
      indicatorWidth: selectedWidth,
    );
  }

  // Calculate the natural width required by the selected item.

  double _calculateSelectedWidth({
    required BuildContext context,
    required int index,
    required double totalWidth,
  }) {
    final destination = widget.destinations[index];

    final textStyle =
        Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500) ??
        const TextStyle(fontSize: 14, fontWeight: FontWeight.w500);

    final textPainter = TextPainter(
      text: TextSpan(text: destination.label, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    const iconWidth = 21.0;
    const iconLabelGap = 6.0;
    const horizontalPadding = 20.0;

    final naturalWidth = iconWidth + iconLabelGap + textPainter.width + horizontalPadding;

    // Four inactive items need enough space to display their icons.
    const minimumInactiveWidth = 46.0;

    final maximumSelectedWidth = totalWidth - (minimumInactiveWidth * 4);

    return naturalWidth.clamp(76.0, maximumSelectedWidth);
  }

  // Linear interpolation helper.

  double _lerp(double begin, double end, double t) {
    return begin + ((end - begin) * t);
  }
}

// Navigation layout data

class _NavigationLayout {
  const _NavigationLayout({
    required this.widths,
    required this.indicatorLeft,
    required this.indicatorWidth,
  });

  final List<double> widths;
  final double indicatorLeft;
  final double indicatorWidth;
}

// Individual navigation item

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({required this.destination, required this.isSelected, required this.onTap});

  final AppBottomNavDestination destination;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final inactiveColor = theme.colorScheme.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        child: Center(
          child: isSelected
              ? FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(destination.icon, size: 21, color: AppColors.white),
                      const SizedBox(width: 6),
                      Text(
                        destination.label,
                        maxLines: 1,
                        softWrap: false,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : Icon(destination.icon, size: 21, color: inactiveColor),
        ),
      ),
    );
  }
}

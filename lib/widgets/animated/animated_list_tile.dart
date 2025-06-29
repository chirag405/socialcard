import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/app_theme.dart';

class AnimatedListTile extends StatefulWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;
  final bool showChevron;
  final EdgeInsetsGeometry? contentPadding;
  final Color? backgroundColor;
  final Duration animationDuration;

  const AnimatedListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.enabled = true,
    this.showChevron = false,
    this.contentPadding,
    this.backgroundColor,
    this.animationDuration = const Duration(milliseconds: 150),
  });

  @override
  State<AnimatedListTile> createState() => _AnimatedListTileState();
}

class _AnimatedListTileState extends State<AnimatedListTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(parent: _controller, curve: AppTheme.easeOut));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final theme = Theme.of(context);

    _backgroundAnimation = ColorTween(
      begin: widget.backgroundColor ?? theme.colorScheme.surface,
      end: (widget.backgroundColor ?? theme.colorScheme.surface).withOpacity(
        0.7,
      ),
    ).animate(CurvedAnimation(parent: _controller, curve: AppTheme.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.enabled && widget.onTap != null) {
      _controller.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.enabled && widget.onTap != null) {
      _controller.reverse();
      widget.onTap?.call();
    }
  }

  void _onTapCancel() {
    if (widget.enabled && widget.onTap != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final opacity = widget.enabled ? 1.0 : 0.5;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            decoration: BoxDecoration(
              color: _backgroundAnimation.value,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTapDown: _onTapDown,
                onTapUp: _onTapUp,
                onTapCancel: _onTapCancel,
                child: Container(
                  padding:
                      widget.contentPadding ??
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      // Leading widget
                      if (widget.leading != null) ...[
                        Opacity(opacity: opacity, child: widget.leading!),
                        const SizedBox(width: 16),
                      ],

                      // Title and subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.title != null)
                              DefaultTextStyle(
                                style: theme.textTheme.titleMedium!.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(opacity),
                                ),
                                child: widget.title!,
                              ),
                            if (widget.subtitle != null) ...[
                              const SizedBox(height: 2),
                              DefaultTextStyle(
                                style: theme.textTheme.bodySmall!.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(opacity * 0.7),
                                ),
                                child: widget.subtitle!,
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Trailing widget or chevron
                      if (widget.trailing != null) ...[
                        const SizedBox(width: 12),
                        Opacity(opacity: opacity, child: widget.trailing!),
                      ] else if (widget.showChevron &&
                          widget.onTap != null) ...[
                        const SizedBox(width: 12),
                        Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: theme.colorScheme.onSurface.withOpacity(
                            opacity * 0.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

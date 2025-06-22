import 'package:flutter/material.dart';
import 'dart:async';
import '../models/qr_link_config.dart';

class QrConfigCard extends StatefulWidget {
  final QrLinkConfig config;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;

  const QrConfigCard({
    super.key,
    required this.config,
    this.onTap,
    this.onDelete,
    this.onShare,
  });

  @override
  State<QrConfigCard> createState() => _QrConfigCardState();
}

class _QrConfigCardState extends State<QrConfigCard>
    with TickerProviderStateMixin {
  late AnimationController _expiredAnimationController;
  late Animation<double> _expiredOpacityAnimation;
  Timer? _autoRemoveTimer;
  bool _isMarkedForRemoval = false;

  @override
  void initState() {
    super.initState();

    _expiredAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _expiredOpacityAnimation = Tween<double>(begin: 1.0, end: 0.3).animate(
      CurvedAnimation(
        parent: _expiredAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _checkExpiryStatus();
  }

  @override
  void dispose() {
    _expiredAnimationController.dispose();
    _autoRemoveTimer?.cancel();
    super.dispose();
  }

  void _checkExpiryStatus() {
    if (widget.config.isExpired && !_isMarkedForRemoval) {
      // Mark as expired with visual indication
      _expiredAnimationController.forward();

      // Start 10-minute countdown for auto-removal
      _autoRemoveTimer = Timer(const Duration(minutes: 10), () {
        if (mounted && widget.onDelete != null) {
          widget.onDelete!();
        }
      });

      setState(() => _isMarkedForRemoval = true);
    }
  }

  String _getExpiryText() {
    if (!widget.config.isExpired) {
      if (widget.config.expirySettings.expiryDate != null) {
        final timeLeft = widget.config.expirySettings.expiryDate!.difference(
          DateTime.now(),
        );
        if (timeLeft.inDays > 0) {
          return 'Expires in ${timeLeft.inDays} days';
        } else if (timeLeft.inHours > 0) {
          return 'Expires in ${timeLeft.inHours} hours';
        } else if (timeLeft.inMinutes > 0) {
          return 'Expires in ${timeLeft.inMinutes} minutes';
        }
      }

      if (widget.config.expirySettings.maxScans != null) {
        final scansLeft =
            widget.config.expirySettings.maxScans! - widget.config.scanCount;
        return '$scansLeft scans left';
      }

      return 'No expiry';
    } else {
      if (_isMarkedForRemoval) {
        return 'Expired - Auto-removing in 10 min';
      }
      return 'Expired';
    }
  }

  Color _getExpiryColor() {
    if (widget.config.isExpired) {
      return Colors.red;
    }

    if (widget.config.expirySettings.expiryDate != null) {
      final timeLeft = widget.config.expirySettings.expiryDate!.difference(
        DateTime.now(),
      );
      if (timeLeft.inHours < 24) {
        return Colors.orange;
      }
    }

    if (widget.config.expirySettings.maxScans != null) {
      final scansLeft =
          widget.config.expirySettings.maxScans! - widget.config.scanCount;
      if (scansLeft <= 1) {
        return Colors.orange;
      }
    }

    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _expiredOpacityAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _expiredOpacityAnimation.value,
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side:
                  widget.config.isExpired
                      ? BorderSide(color: Colors.red.withOpacity(0.5), width: 2)
                      : BorderSide.none,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: widget.config.isExpired ? null : widget.onTap,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row
                    Row(
                      children: [
                        // QR Icon with status
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: widget.config.qrCustomization.foregroundColor
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: widget
                                  .config
                                  .qrCustomization
                                  .foregroundColor
                                  .withOpacity(0.3),
                            ),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Icon(
                                  Icons.qr_code,
                                  color:
                                      widget
                                          .config
                                          .qrCustomization
                                          .foregroundColor,
                                  size: 24,
                                ),
                              ),
                              if (widget.config.isExpired)
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: Container(
                                    width: 16,
                                    height: 16,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        // QR Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.config.linkSlug.isEmpty
                                    ? 'Auto-generated QR'
                                    : widget.config.linkSlug,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  decoration:
                                      widget.config.isExpired
                                          ? TextDecoration.lineThrough
                                          : null,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              if (widget.config.description.isNotEmpty) ...[
                                Text(
                                  widget.config.description,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.7),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                              ],
                              Row(
                                children: [
                                  Icon(
                                    Icons.link,
                                    size: 14,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.5),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${widget.config.selectedLinkIds.length} links',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(
                                    Icons.visibility,
                                    size: 14,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.5),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${widget.config.scanCount} scans',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Actions
                        if (!widget.config.isExpired) ...[
                          if (widget.onShare != null)
                            IconButton(
                              onPressed: widget.onShare,
                              icon: const Icon(Icons.share),
                              tooltip: 'Share QR',
                            ),
                        ],

                        PopupMenuButton<String>(
                          onSelected: (value) {
                            switch (value) {
                              case 'delete':
                                if (widget.onDelete != null) {
                                  widget.onDelete!();
                                }
                                break;
                            }
                          },
                          itemBuilder:
                              (context) => [
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete,
                                        color:
                                            widget.config.isExpired
                                                ? Colors.orange
                                                : Colors.red,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        widget.config.isExpired
                                            ? 'Remove Now'
                                            : 'Delete',
                                        style: TextStyle(
                                          color:
                                              widget.config.isExpired
                                                  ? Colors.orange
                                                  : Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Status Bar
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getExpiryColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _getExpiryColor().withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.config.isExpired
                                ? Icons.error_outline
                                : Icons.schedule,
                            size: 14,
                            color: _getExpiryColor(),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _getExpiryText(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _getExpiryColor(),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:cribe/core/constants/spacing.dart';
import 'package:cribe/main.dart';
import 'package:cribe/ui/dev_helper/widgets/dev_settings_modal.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DevHelperWrapper extends StatefulWidget {
  final Widget child;
  const DevHelperWrapper({super.key, required this.child});

  @override
  State<DevHelperWrapper> createState() => _DevHelperWrapperState();
}

class _DevHelperWrapperState extends State<DevHelperWrapper> {
  Offset? position;
  static const double buttonSize = Spacing.extraLarge;
  bool _isModalOpen = false;

  void _toggleDevModal() {
    final context = MyApp.navigatorKey.currentContext;
    if (context == null) return;

    if (_isModalOpen) {
      // Close the modal if it's already open
      Navigator.of(context).pop();
      setState(() {
        _isModalOpen = false;
      });
    } else {
      // Open the modal
      setState(() {
        _isModalOpen = true;
      });
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        builder: (_) => const DevSettingsModal(),
      ).then((_) {
        // Reset the flag when modal is closed by any means
        setState(() {
          _isModalOpen = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only show in debug mode
    if (kDebugMode) {
      // Calculate initial position if not set
      if (position == null) {
        final mediaQuery = MediaQuery.of(context);
        final screenSize = mediaQuery.size;
        final safeAreaInsets = mediaQuery.padding;

        // Position on the right side, 2/3 down the screen
        final rightX = screenSize.width - safeAreaInsets.right - buttonSize;
        final downY = (screenSize.height * 2 / 3) -
            (buttonSize / 2); // 2/3 down, centered on button

        position = Offset(rightX, downY);
      }

      final theme = Theme.of(context);

      return Stack(
        alignment: Alignment.bottomRight,
        children: [
          widget.child,
          Positioned(
            left: position?.dx,
            top: position?.dy,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    if (position == null) return;

                    // Get screen size and safe area insets
                    final mediaQuery = MediaQuery.of(context);
                    final screenSize = mediaQuery.size;
                    final safeAreaInsets = mediaQuery.padding;

                    final newPosition = position! + details.delta;

                    // Define safe draggable area (avoiding notch and navigation)
                    final safeLeft = safeAreaInsets.left;
                    final safeRight =
                        screenSize.width - safeAreaInsets.right - buttonSize;
                    final safeTop = safeAreaInsets.top;
                    final safeBottom =
                        screenSize.height - safeAreaInsets.bottom - buttonSize;

                    // Constrain the position to safe draggable area
                    final constrainedX =
                        newPosition.dx.clamp(safeLeft, safeRight);
                    final constrainedY =
                        newPosition.dy.clamp(safeTop, safeBottom);

                    position = Offset(constrainedX, constrainedY);
                  });
                },
                onTap: _toggleDevModal,
                child: Container(
                  width: buttonSize,
                  height: buttonSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary,
                  ),
                  child: Icon(
                    Icons.build,
                    color: theme.colorScheme.onPrimary,
                    size: Spacing.large,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
    return widget.child;
  }
}

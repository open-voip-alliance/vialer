import 'package:flutter/material.dart';

import '../../resources/theme.dart';

class StylizedButton extends StatelessWidget {
  const StylizedButton({
    required this.type,
    required this.child,
    this.colored = false,
    this.margin,
    this.onPressed,
    this.borderRadius,
    this.isLoading = false,
    super.key,
  });

  factory StylizedButton.raised({
    required Widget child,
    Key? key,
    bool colored = false,
    EdgeInsets? margin,
    VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return StylizedButton(
      type: StylizedButtonType.raised,
      key: key,
      colored: colored,
      margin: margin,
      onPressed: onPressed,
      child: child,
      borderRadius: BorderRadius.circular(8),
      isLoading: isLoading,
    );
  }

  factory StylizedButton.outline({
    required Widget child,
    Key? key,
    bool colored = false,
    EdgeInsets? margin,
    VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return StylizedButton(
      type: StylizedButtonType.outline,
      key: key,
      colored: colored,
      margin: margin,
      onPressed: onPressed,
      child: child,
      borderRadius: BorderRadius.circular(8),
      isLoading: isLoading,
    );
  }

  static const _duration = Duration(milliseconds: 300);
  static const _curve = Curves.decelerate;

  static const _borderWidth = 1.0;

  final StylizedButtonType type;
  final bool colored;
  final VoidCallback? onPressed;
  final EdgeInsets? margin;
  final Widget child;
  final BorderRadius? borderRadius;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final borderRadius = this.borderRadius ?? BorderRadius.circular(2);
    final color = context.brand.theme.colors.buttonBackground;

    final disabled = onPressed == null;
    const disabledForegroundColor = Color(0xFF555555);

    Color textColor;
    if (disabled) {
      textColor = disabledForegroundColor;
    } else if (type == StylizedButtonType.raised) {
      textColor = colored
          ? context.brand.theme.colors.raisedColoredButtonText
          : Theme.of(context).primaryColorDark;
    } else {
      textColor = colored ? Theme.of(context).primaryColor : Colors.white;
    }

    final shape = RoundedRectangleBorder(
      borderRadius: borderRadius,
    );

    final isRaised = type == StylizedButtonType.raised;
    final isOutline = type == StylizedButtonType.outline;

    return Padding(
      padding: margin ?? const EdgeInsets.symmetric(horizontal: 24),
      child: AnimatedContainer(
        duration: _duration,
        curve: _curve,
        decoration: BoxDecoration(
          boxShadow: [
            if (!disabled && isRaised)
              BoxShadow(
                color: Colors.black.withOpacity(0.16),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: AnimatedContainer(
            duration: _duration,
            curve: _curve,
            decoration: BoxDecoration(
              // Always draw a border to avoid size differences between other
              // types
              border: isOutline
                  ? Border.all(
                      color: disabled
                          ? disabledForegroundColor
                          : colored
                              ? color
                              : Colors.white,
                      // Kept, in case the border width changes.
                      // ignore: avoid_redundant_argument_values
                      width: _borderWidth,
                    )
                  : null,
              borderRadius: shape.borderRadius,
              color: disabled
                  ? const Color(0xFFF5F5F5)
                  : isRaised
                      ? (colored ? color : Colors.white)
                      : Colors.transparent,
            ),
            child: Material(
              color: Colors.transparent,
              shape: shape,
              child: InkWell(
                customBorder: shape,
                onTap: onPressed,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 12 + (!isOutline ? 1.0 : 0.0),
                    horizontal: 16 + (!isOutline ? 1.0 : 0.0),
                  ),
                  child: Center(
                    child: AnimatedTheme(
                      duration: _duration,
                      curve: _curve,
                      data: Theme.of(context).copyWith(
                        iconTheme: IconThemeData(color: textColor),
                      ),
                      child: AnimatedDefaultTextStyle(
                        duration: _duration,
                        curve: _curve,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                        child: isLoading
                            ? _loadingIndicatorButton(
                                textColor: textColor,
                                child: child,
                              )
                            : child,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _loadingIndicatorButton extends StatelessWidget {
  const _loadingIndicatorButton({
    required this.textColor,
    required this.child,
  });

  final Color textColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      switchInCurve: Curves.decelerate,
      switchOutCurve: Curves.decelerate.flipped,
      duration: const Duration(milliseconds: 200),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation(
                textColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(child: child),
        ],
      ),
    );
  }
}

enum StylizedButtonType {
  raised,
  outline,
  flat,
}

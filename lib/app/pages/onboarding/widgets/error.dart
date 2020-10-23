import 'package:flutter/material.dart';

import '../../../resources/theme.dart';

class ErrorAlert extends StatefulWidget {
  /// Whether the error box is visible.
  final bool visible;
  final EdgeInsets padding;
  final Widget child;

  const ErrorAlert({
    Key key,
    @required this.visible,
    this.padding = const EdgeInsets.only(bottom: 16),
    @required this.child,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ErrorAlertState();
}

class _ErrorAlertState extends State<ErrorAlert> with TickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 200);
  static const _curve = Curves.decelerate;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      curve: _curve,
      duration: _duration,
      vsync: this,
      child: AnimatedOpacity(
        curve: _curve,
        duration: _duration,
        opacity: widget.visible ? 1 : 0,
        child: Visibility(
          visible: widget.visible,
          child: Padding(
            padding: widget.padding,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.brandTheme.errorBorderColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.brandTheme.errorBorderColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        VialerSans.exclamationMark,
                        color: context.brandTheme.errorContentColor,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: DefaultTextStyle.merge(
                          child: widget.child,
                          style: TextStyle(
                            color: context.brandTheme.errorContentColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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

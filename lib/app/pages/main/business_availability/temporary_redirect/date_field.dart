import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';
import 'field.dart';

class DateField extends StatefulWidget {
  final ValueNotifier<DateTime?> notifier;

  const DateField({required this.notifier});

  @override
  State<DateField> createState() => _DateFieldState();
}

class _DateFieldState extends State<DateField> {
  late final _dateFormat = DateFormat(
    'E. dd-MM-yyyy',
    context.msg.languageCode,
  );
  late final _timeFormat = DateFormat.Hm(context.msg.languageCode);

  late DateTime _date = DateTime.now().add(const Duration(hours: 1));

  bool _firstEdit = true;
  bool _hasError = false;

  DateTime get _minDate => DateTime.now();
  late final _maxDate = DateTime.now().add(const Duration(days: 365));

  @override
  void initState() {
    super.initState();

    // This has to be done post-frame because the temporary redirect picker
    // updates its state if the value changes. Changing state not allowed
    // when the widget is still setting up.
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget.notifier.value = _date;
    });
  }

  void _updateNotifierAndError() {
    _hasError = _date.isBefore(DateTime.now());
    widget.notifier.value = !_hasError ? _date : null;
  }

  void _updateTime(TimeOfDay time) {
    setState(() {
      _date = _date.copyWith(
        hour: time.hour,
        minute: time.minute,
      );
      _updateNotifierAndError();
    });
  }

  void _updateDate(DateTime date, {bool withTime = false}) {
    setState(() {
      _date = withTime
          ? date
          : _date.copyWith(
              year: date.year,
              month: date.month,
              day: date.day,
            );
      _updateNotifierAndError();
    });
  }

  Future<void> _showMaterialDatePicker() async {
    final newDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: _minDate,
      lastDate: _maxDate,
      builder: (context, child) => _Themed(child: child!),
    );

    if (newDate == null) return;

    _updateDate(newDate);
  }

  Future<void> _showMaterialTimePicker() async {
    final newTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_date),
      builder: (context, child) => _Themed(child: child!),
    );

    if (newTime == null) return;

    _updateTime(newTime);
  }

  Future<void> _showMaterialDateTimePicker() async {
    await _showMaterialDatePicker();
    await _showMaterialTimePicker();
  }

  Future<void> _showCupertinoPicker({
    required CupertinoDatePickerMode mode,
  }) async {
    await showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (context) {
        return Container(
          height: 216,
          padding: const EdgeInsets.only(top: 6.0),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: SafeArea(
            top: false,
            child: CupertinoDatePicker(
              use24hFormat: true,
              mode: mode,
              initialDateTime: _date,
              minimumDate: _minDate,
              maximumDate: _maxDate,
              minimumYear: _minDate.year,
              maximumYear: _maxDate.year,
              onDateTimeChanged: (newDate) {
                setState(() {
                  if (newDate.isBefore(_minDate) || newDate.isAfter(_maxDate)) {
                    return;
                  }

                  switch (mode) {
                    case CupertinoDatePickerMode.time:
                      _updateTime(TimeOfDay.fromDateTime(newDate));
                      break;
                    case CupertinoDatePickerMode.date:
                      _updateDate(newDate);
                      break;
                    case CupertinoDatePickerMode.dateAndTime:
                      _updateDate(newDate, withTime: true);
                      break;
                  }
                });
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _showPicker({required bool time}) async {
    final mode = _firstEdit && !time
        ? CupertinoDatePickerMode.dateAndTime
        : time
            ? CupertinoDatePickerMode.time
            : CupertinoDatePickerMode.date;

    if (context.isIOS) {
      await _showCupertinoPicker(mode: mode);
    } else {
      switch (mode) {
        case CupertinoDatePickerMode.time:
          _showMaterialTimePicker();
          break;
        case CupertinoDatePickerMode.date:
          _showMaterialDatePicker();
          break;
        case CupertinoDatePickerMode.dateAndTime:
          _showMaterialDateTimePicker();
          break;
      }
    }

    _firstEdit = false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              flex: 2,
              child: Field(
                icon: FontAwesomeIcons.calendar,
                text: _dateFormat.format(_date),
                hasError: _hasError,
                onTap: () => _showPicker(time: false),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Field(
                icon: FontAwesomeIcons.clock,
                text: _timeFormat.format(_date),
                hasError: _hasError,
                onTap: () => _showPicker(time: true),
              ),
            ),
          ],
        ),
        if (_hasError) ...[
          const SizedBox(height: 8),
          Text(
            context.msg.main.temporaryRedirect.until.error.timeInPast,
            style: TextStyle(
              color: context.brand.theme.colors.red1,
            ),
          ),
        ],
      ],
    );
  }
}

enum DatePickerMode {
  date,
  time,
  dateTime,
}

/// Ideally we'd use ColorScheme app-wide, but because we don't currently
/// and the pickers use those colors, we have to do it like this until we use
/// it app-wide.
class _Themed extends StatelessWidget {
  final Widget child;

  const _Themed({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          primary: context.brand.theme.colors.primary,
        ),
      ),
      child: child,
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../domain/entities/audio_codec.dart';
import '../../../../../domain/entities/setting.dart';

/// Value for use in [_SettingValueTile] specifically for [AudioCodecSetting].
// Might be generalized into a MultipleChoiceSettingValue widget later on.
// However, although it would use that widget, this specific widget will stay
// even then, because in the future this widget will have a bloc, to receive
// the codec choices from the PIL.
class AudioCodecSettingValue extends StatelessWidget {
  final AudioCodecSetting setting;
  final ValueChanged<AudioCodecSetting> onChanged;

  const AudioCodecSettingValue(this.setting, this.onChanged, {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: DropdownButton<AudioCodec>(
        value: setting.value,
        isExpanded: true,
        items: [
          // TODO: Get values from PIL.
          DropdownMenuItem(
            value: AudioCodec.opus,
            child: Text(AudioCodec.opus.value.toUpperCase()),
          ),
        ],
        onChanged: (codec) => onChanged(
          setting.copyWith(value: codec),
        ),
      ),
    );
  }
}

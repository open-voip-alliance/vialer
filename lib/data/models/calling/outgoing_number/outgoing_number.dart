import 'package:dartx/dartx.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'outgoing_number.freezed.dart';

part 'outgoing_number.g.dart';

@Freezed(equal: false)
sealed class OutgoingNumber with _$OutgoingNumber {
  const OutgoingNumber._();
  const factory OutgoingNumber() = _OutgoingNumber;
  const factory OutgoingNumber.unsuppressed(
    String number, {
    String? description,
  }) = UnsuppressedOutgoingNumber;
  const factory OutgoingNumber.suppressed() = SuppressedOutgoingNumber;
  const factory OutgoingNumber.section() = OutgoingNumberSection;

  bool get isSuppressed => this is SuppressedOutgoingNumber;

  bool get hasDescription {
    final self = this;

    return self is UnsuppressedOutgoingNumber &&
        self.description.isNotNullOrBlank;
  }

  String get descriptionOrEmpty {
    final self = this;

    return self is UnsuppressedOutgoingNumber ? self.description ?? '' : '';
  }

  String get valueOrEmpty {
    final self = this;

    return self is UnsuppressedOutgoingNumber ? self.number : '';
  }

  factory OutgoingNumber.fromNumber(String number) => number == _suppressed
      ? OutgoingNumber.suppressed()
      : OutgoingNumber.unsuppressed(number);

  factory OutgoingNumber.fromJson(dynamic json) => json is String
      ? OutgoingNumber.fromNumber(json)
      : _$OutgoingNumberFromJson(json as Map<String, dynamic>);

  static Map<String, dynamic> serializeToJson(OutgoingNumber outgoingNumber) =>
      outgoingNumber.toJson();

  @override
  bool operator ==(Object other) {
    if (other is! OutgoingNumber) return false;

    if (other is SuppressedOutgoingNumber && this is SuppressedOutgoingNumber) {
      return true;
    }

    final self = this;

    if (other is UnsuppressedOutgoingNumber &&
        self is UnsuppressedOutgoingNumber) {
      return other.number == self.number;
    }

    return false;
  }

  int get hashCode => valueOrEmpty.hashCode;
}

const _suppressed = 'suppressed';

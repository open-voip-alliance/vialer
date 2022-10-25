import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import '../business_availability/temporary_redirect/temporary_redirect.dart';
import '../voicemail/voicemail_account.dart';
import 'settings/call_setting.dart';

part 'client.g.dart';

@immutable
@JsonSerializable()
class Client extends Equatable {
  final int id;
  final String uuid;
  final String name;
  final Uri url;

  /// This represents the business numbers that are available to the client
  /// the logged-in user belongs to.
  @JsonKey(toJson: _outgoingNumbersToJson)
  final Iterable<OutgoingNumber> outgoingNumbers;

  final Iterable<VoicemailAccount> voicemailAccounts;

  final TemporaryRedirect? currentTemporaryRedirect;

  const Client({
    required this.id,
    required this.uuid,
    required this.name,
    required this.url,
    this.outgoingNumbers = const [],
    this.voicemailAccounts = const [],
    this.currentTemporaryRedirect,
  });

  @override
  List<Object?> get props => [id, uuid, name, url, outgoingNumbers];

  Client copyWith({
    int? id,
    String? uuid,
    String? name,
    Uri? url,
    Iterable<OutgoingNumber>? outgoingNumbers,
    Iterable<VoicemailAccount>? voicemailAccounts,
    TemporaryRedirect? currentTemporaryRedirect,
  }) {
    return Client(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      url: url ?? this.url,
      outgoingNumbers: outgoingNumbers ?? this.outgoingNumbers,
      voicemailAccounts: voicemailAccounts ?? this.voicemailAccounts,
      currentTemporaryRedirect:
          currentTemporaryRedirect ?? this.currentTemporaryRedirect,
    );
  }

  static Map<String, dynamic>? toJson(Client? value) =>
      value != null ? _$ClientToJson(value) : null;

  static Client? fromJson(Map<String, dynamic>? json) =>
      json != null ? _$ClientFromJson(json) : null;
}

List<String> _outgoingNumbersToJson(Iterable<OutgoingNumber> numbers) =>
    numbers.map(OutgoingNumber.toJson).toList();

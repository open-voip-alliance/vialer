import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import '../voicemail/voicemail_account.dart';

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
  final Iterable<String> outgoingNumbers;

  final Iterable<VoicemailAccount> voicemailAccounts;

  const Client({
    required this.id,
    required this.uuid,
    required this.name,
    required this.url,
    this.outgoingNumbers = const [],
    this.voicemailAccounts = const [],
  });

  @override
  List<Object?> get props => [id, uuid, name, url, outgoingNumbers];

  Client copyWith({
    int? id,
    String? uuid,
    String? name,
    Uri? url,
    Iterable<String>? outgoingNumbers,
    Iterable<VoicemailAccount>? voicemailAccounts,
  }) {
    return Client(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      url: url ?? this.url,
      outgoingNumbers: outgoingNumbers ?? this.outgoingNumbers,
      voicemailAccounts: voicemailAccounts ?? this.voicemailAccounts,
    );
  }

  static Map<String, dynamic>? toJson(Client? value) =>
      value != null ? _$ClientToJson(value) : null;

  static Client? fromJson(Map<String, dynamic>? json) =>
      json != null ? _$ClientFromJson(json) : null;
}

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../presentation/util/nullable_copy_with_argument.dart';
import '../business_availability/temporary_redirect/temporary_redirect.dart';
import '../calling/outgoing_number/outgoing_number.dart';
import '../opening_hours_basic/opening_hours.dart';
import '../voicemail/voicemail_account.dart';
import '../voipgrid/client_voip_config.dart';

part 'client.freezed.dart';
part 'client.g.dart';

@Freezed(copyWith: false)
class Client with _$Client {
  const Client._();

  const factory Client({
    required int id,
    required String uuid,
    required String name,
    required Uri url,
    @JsonKey(
      toJson: ClientVoipConfig.serializeToJson,
      fromJson: _clientVoipConfigFromJson,
    )
    required ClientVoipConfig voip,

    /// This represents the business numbers that are available to the client
    /// the logged-in user belongs to.
    @JsonKey(toJson: _outgoingNumbersToJson)
    @Default([])
    Iterable<OutgoingNumber> outgoingNumbers,
    @Default([]) Iterable<VoicemailAccount> voicemailAccounts,
    TemporaryRedirect? currentTemporaryRedirect,
    @Default([])
    @JsonKey(name: 'openingHours')
    Iterable<OpeningHoursModule> openingHoursModules,
  }) = _Client;

  Client copyWith({
    int? id,
    String? uuid,
    String? name,
    Uri? url,
    ClientVoipConfig? voip,
    NullableCopyWithArgument<Iterable<OutgoingNumber>> outgoingNumbers,
    NullableCopyWithArgument<Iterable<VoicemailAccount>> voicemailAccounts,
    NullableCopyWithArgument<TemporaryRedirect> currentTemporaryRedirect,
    NullableCopyWithArgument<Iterable<OpeningHoursModule>> openingHoursModules,
  }) {
    return Client(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      url: url ?? this.url,
      voip: voip ?? this.voip,
      outgoingNumbers: outgoingNumbers.valueOrFallback(
        unmodified: this.outgoingNumbers,
        fallback: [],
      ),
      voicemailAccounts: voicemailAccounts.valueOrFallback(
        unmodified: this.voicemailAccounts,
        fallback: [],
      ),
      currentTemporaryRedirect: currentTemporaryRedirect.valueOrNull(
        unmodified: this.currentTemporaryRedirect,
      ),
      openingHoursModules: openingHoursModules.valueOrFallback(
        unmodified: this.openingHoursModules,
        fallback: [],
      ),
    );
  }

  factory Client.fromJson(Map<String, dynamic> json) => _$ClientFromJson(json);

  static Map<String, dynamic>? serializeToJson(Client value) => value.toJson();
}

List<Map<String, dynamic>> _outgoingNumbersToJson(
  Iterable<OutgoingNumber> numbers,
) =>
    numbers.map(OutgoingNumber.serializeToJson).toList();

ClientVoipConfig _clientVoipConfigFromJson(Map<String, dynamic>? json) {
  if (json == null) return ClientVoipConfig.fallback();

  return ClientVoipConfig.fromJson(json);
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'messaging_survey_response.freezed.dart';

@freezed
class MessagingSurveyResponse with _$MessagingSurveyResponse {
  const factory MessagingSurveyResponse({
    @Default([]) List<String> installedApps,
    int? questionPersonalWhatsapp,
    int? questionBusinessWhatsapp,
    bool? joinResearchPool,
  }) = _MessagingSurveyResponse;
}

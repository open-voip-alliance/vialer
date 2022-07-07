import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../domain/entities/setting.dart';
import '../../../../../domain/entities/survey/survey.dart';
import '../../../../../domain/entities/survey/survey_trigger.dart';
import '../../../../../domain/usecases/get_app_rating_survey_action_count.dart';
import '../../../../../domain/usecases/get_app_rating_survey_last_shown_time.dart';
import '../../../../../domain/usecases/get_setting.dart';
import '../../../../../domain/usecases/mark_now_as_app_rating_survey_shown.dart';
import '../../../../../domain/usecases/reset_app_rating_survey_action_count.dart';
import '../../../../util/loggable.dart';
import '../caller/cubit.dart';
import 'state.dart';

export 'state.dart';

class SurveyTriggererCubit extends Cubit<SurveyTriggererState> with Loggable {
  final _getShowSurveysSetting = GetSettingUseCase<ShowSurveysSetting>();
  final _getAppRatingLastShownTime = GetAppRatingSurveyLastShownTimeUseCase();
  final _getAppRatingActionCount = GetAppRatingSurveyActionCountUseCase();
  final _markNowAsAppRatingSurveyShown = MarkNowAsAppRatingSurveyShownUseCase();
  final _resetAppRatingActionCount = ResetAppRatingSurveyActionCountUseCase();

  final CallerCubit caller;

  SurveyTriggererCubit(this.caller) : super(const SurveyNotTriggered());

  Future<void> check() async {
    if (caller.state.isInCall) return;

    logger.info('Checking app rating survey trigger conditions..');

    final appRatingLastShown = _getAppRatingLastShownTime();

    final timePassed = appRatingLastShown != null
        ? DateTime.now().difference(appRatingLastShown)
        : null;

    final isTriggered = AfterAnAmountOfActionsOnAppLaunchTrigger.isTriggered(
      await _getShowSurveysSetting(),
      actionsCount: _getAppRatingActionCount(),
      timeSinceLastSurvey: timePassed,
    );

    if (isTriggered) {
      emit(
        const SurveyTriggered(
          SurveyId.appRating,
          AfterAnAmountOfActionsOnAppLaunchTrigger(),
        ),
      );
      _markNowAsAppRatingSurveyShown();
      _resetAppRatingActionCount();
      logger.info('App rating survey triggered');
    }
  }
}

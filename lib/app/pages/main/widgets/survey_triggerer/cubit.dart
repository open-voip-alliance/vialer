import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vialer/domain/user/user.dart';

import '../../../../../domain/feedback/mark_now_as_app_rating_survey_shown.dart';
import '../../../../../domain/feedback/reset_app_rating_survey_action_count.dart';
import '../../../../../domain/feedback/survey/get_app_rating_survey_action_count.dart';
import '../../../../../domain/feedback/survey/get_app_rating_survey_last_shown_time.dart';
import '../../../../../domain/feedback/survey/survey.dart';
import '../../../../../domain/feedback/survey/survey_trigger.dart';
import '../../../../../domain/user/get_logged_in_user.dart';
import '../../../../util/loggable.dart';
import '../caller/cubit.dart';
import 'state.dart';

export 'state.dart';

class SurveyTriggererCubit extends Cubit<SurveyTriggererState> with Loggable {
  SurveyTriggererCubit(this.caller) : super(const SurveyNotTriggered());

  final _getUser = GetLoggedInUserUseCase();
  final _getAppRatingLastShownTime = GetAppRatingSurveyLastShownTimeUseCase();
  final _getAppRatingActionCount = GetAppRatingSurveyActionCountUseCase();
  final _markNowAsAppRatingSurveyShown = MarkNowAsAppRatingSurveyShownUseCase();
  final _resetAppRatingActionCount = ResetAppRatingSurveyActionCountUseCase();

  final CallerCubit caller;

  Future<void> check() async {
    if (caller.state.isInCall) return;

    logger.info('Checking app rating survey trigger conditions..');

    final appRatingLastShown = _getAppRatingLastShownTime();

    final timePassed = appRatingLastShown != null
        ? DateTime.now().difference(appRatingLastShown)
        : null;

    final user = _getUser();

    final isTriggered = AfterAnAmountOfActionsOnAppLaunchTrigger.isTriggered(
      settings: user.settings,
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

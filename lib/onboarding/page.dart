import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:vialer_lite/onboarding/permission/call/form.dart';

import '../routes.dart';
import 'bloc.dart';
import 'initial/form.dart';
import 'login/form.dart';
import 'widgets/background.dart';

class OnboardingPage extends StatefulWidget {
  OnboardingPage._();

  static Widget create() {
    return BlocProvider<OnboardingBloc>(
      create: (context) => OnboardingBloc()..add(CheckWhichStepsAreNeeded()),
      child: OnboardingPage._(),
    );
  }

  @override
  State<StatefulWidget> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static const _duration = Duration(milliseconds: 400);
  static const _curve = Curves.decelerate;

  final _controller = PageController();

  Map<Type, WidgetBuilder> _mappedForms;
  List<Widget> _forms;

  void _initForms(List<Type> stepTypes) => setState(() {
        _forms = stepTypes.map((type) => _mappedForms[type](context)).toList();
      });

  void _requestForward() {
    context.bloc<OnboardingBloc>().add(Forward());
  }

  Future<bool> _requestBackward() async {
    // ignore: close_sinks
    final bloc = context.bloc<OnboardingBloc>();
    bloc.add(Backward());

    bool first = true;
    await for (final state in bloc) {
      // Skip first received state because the bloc's controller
      // always immediately yields the current state on listen,
      // but we want the next one
      if (first) {
        first = false;
        continue;
      }

      if (state.end == Direction.backward) {
        return true;
      } else {
        await _goTo(state);
        return false;
      }
    }

    return false;
  }

  Future<void> _goTo(OnboardingState state) async {
    if (state.end == Direction.forward) {
      Navigator.pushNamedAndRemoveUntil(context, Routes.main, (_) => false);
    }

    _controller.animateToPage(
      _mappedForms.keys.toList().indexOf(state.runtimeType),
      duration: _duration,
      curve: _curve,
    );
  }

  @override
  void initState() {
    super.initState();

    _mappedForms = {
      InitialStep: (_) => InitialForm(forward: _requestForward),
      LoginStep: (_) => LoginForm.create(forward: _requestForward),
      CallPermissionStep: (_) =>
          CallPermissionForm.create(forward: _requestForward),
    };
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_forms == null) {
      // Always add initial form
      _forms = [_mappedForms[InitialStep](context)];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Background(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        body: WillPopScope(
          onWillPop: _requestBackward,
          child: BlocListener<OnboardingBloc, OnboardingState>(
            listener: (context, state) {
              if (state is InitialStep && state.steps != null) {
                _initForms(state.steps);
              } else {
                _goTo(state);
              }
            },
            child: DefaultTextStyle(
              style: TextStyle(color: Colors.white),
              child: IconTheme(
                data: IconThemeData(color: Colors.white),
                child: PageView(
                  controller: _controller,
                  children: _forms.map((form) {
                    return SafeArea(
                      child: Provider<EdgeInsets>(
                        create: (_) => EdgeInsets.all(48).copyWith(
                          top: 128,
                          bottom: 32,
                        ),
                        child: form,
                      ),
                    );
                  }).toList(),
                  physics: NeverScrollableScrollPhysics(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

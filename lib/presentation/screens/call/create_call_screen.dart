/*
 * Author     : Mochamad Firgia
 * Website    : https://www.firgia.com
 * Repository : https://github.com/firgia/soca
 * 
 * Created on Fri Mar 31 2023
 * Copyright (c) 2023 Mochamad Firgia
 */

import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/config.dart';
import '../../../core/core.dart';
import '../../../data/data.dart';
import '../../../injection.dart';
import '../../../logic/logic.dart';
import '../../widgets/widgets.dart';

part 'create_call_screen.component.dart';

class CreateCallScreen extends StatefulWidget {
  const CreateCallScreen({
    required this.user,
    super.key,
  });

  final User user;

  @override
  State<CreateCallScreen> createState() => _CreateCallScreenState();
}

class _CreateCallScreenState extends State<CreateCallScreen> {
  AppNavigator appNavigator = sl<AppNavigator>();
  CallActionBloc callActionBloc = sl<CallActionBloc>();
  DeviceFeedback deviceFeedback = sl<DeviceFeedback>();
  CallKit callKit = sl<CallKit>();
  bool hasPlayPageInfo = false;
  bool hasPlayStartVideoCall = false;
  bool _canPop = false; // private variable to store the value

  // Getter
  bool get canPop => _canPop;

  // Setter
  set canPop(bool value) {
    _canPop = value;
  }



  @override
  void initState() {
    super.initState();

    callActionBloc.add(const CallActionCreated());

    deviceFeedback.playCallVibration();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    playPageInfo();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => callActionBloc,
      child: BlocListener<CallActionBloc, CallActionState>(
        listener: (context, state) {
          if (state is CallActionCreatedSuccessfully) {
            CallingSetup data = state.data;
            playStartVideoCall().then(
              (_) {
                if (mounted) {
                  callKit.startCall(
                    CallKitArgument(
                      id: data.id,
                      nameCaller: data.remoteUser.name,
                      handle: LocaleKeys.volunteer.tr(),
                      type: 1,
                    ),
                  );
                  appNavigator.goToVideoCall(context, setup: state.data);
                }
              },
            );
          } else if (state is CallActionEndedSuccessfully) {
            appNavigator.back(context);
            AppSnackbar(context)
                .showMessage(LocaleKeys.end_call_successfully.tr());
          } else if (state is CallActionCreatedUnanswered) {
            appNavigator.back(context);
            AppSnackbar(context)
                .showMessage(LocaleKeys.fail_to_call_no_volunteers.tr());
          } else if (state is CallActionError) {
            appNavigator.back(context);
            AppSnackbar(context).showMessage(
              LocaleKeys.error_something_wrong.tr(),
              style: SnacbarStyle.danger,
            );
          }
        },
        child: PopScope(
          //onWillPop: () async => false,
          canPop: canPop, // Make it  false to Work
/*          onPopInvoked: (bool value) {
            setState(() {
              canPop = !value; //Logic and manage State
            });
            if (canPop) {
              AppSnackbar(context).showMessage(
                LocaleKeys.back.tr(),
              );
            }
          },*/
          child: Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                _BackgroundImage(widget.user.avatar?.large),
                Center(
                  child: Column(
                    children: [
                      const Spacer(),
                      _NameText(widget.user.name ?? ""),
                      const _CallingVolunteerText(),
                      const Spacer(flex: 3),
                      const _CancelButton(),
                      const Spacer(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void playPageInfo() {
    if (mounted && !hasPlayPageInfo) {
      hasPlayPageInfo = true;

      deviceFeedback.playVoiceAssistant(
        [
          LocaleKeys.va_async_calling_volunteer.tr(),
        ],
        context,
        immediately: true,
      );
    }
  }

  Future<void> playStartVideoCall() async {
    deviceFeedback.stopCallVibration();

    if (mounted && !hasPlayStartVideoCall) {
      hasPlayStartVideoCall = true;

      deviceFeedback.playVoiceAssistant(
        [
          LocaleKeys.va_starting_video_call.tr(),
        ],
        context,
        immediately: true,
      );

      if (deviceFeedback.isVoiceAssistantEnable) {
        // Add delay to make sure user hear the 'starting video call' voice
        await Future.delayed(const Duration(seconds: 2));
      }
    }
  }

  @override
  void dispose() {
    super.dispose();

    deviceFeedback.stopCallVibration();
  }
}

/*
 * Author     : Mochamad Firgia
 * Website    : https://www.firgia.com
 * Repository : https://github.com/firgia/soca
 * 
 * Created on Wed Jan 25 2023
 * Copyright (c) 2023 Mochamad Firgia
 */

import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:swipe_refresh/swipe_refresh.dart';
import '../../../core/core.dart';
import '../../../config/config.dart';
import '../../../data/data.dart';
import '../../../injection.dart';
import '../../../logic/logic.dart';
import '../../widgets/widgets.dart';

part 'home_screen.component.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AppNavigator appNavigator = sl<AppNavigator>();
  final AssistantCommandBloc assistantCommandBloc = sl<AssistantCommandBloc>();
  final CallStatisticBloc callStatisticBloc = sl<CallStatisticBloc>();
  final DeviceInfo deviceInfo = sl<DeviceInfo>();
  final DeviceFeedback deviceFeedback = sl<DeviceFeedback>();
  final IncomingCallBloc incomingCallBloc = sl<IncomingCallBloc>();
  final RouteCubit routeCubit = sl<RouteCubit>();
  final UserBloc userBloc = sl<UserBloc>();
  final UserRepository userRepository = sl<UserRepository>();

  late final StreamController<SwipeRefreshState> swipeRefreshController;
  late final StreamSubscription onUserDeviceUpdatedSubscribtion;
  late final StreamSubscription volumeListenerSubscribtion;

  User? user;
  bool hasPlayPageInfo = false;

  @override
  void initState() {
    super.initState();

    swipeRefreshController = StreamController<SwipeRefreshState>.broadcast();
    onUserDeviceUpdatedSubscribtion = userRepository.onUserDeviceUpdated.listen(
      (userDevice) => routeCubit.getTargetRoute(
        checkDifferentDevice: true,
        userDevice: userDevice,
      ),
    );

    assistantCommandBloc.add(const AssistantCommandFetched());
    userBloc.add(const UserFetched());
    incomingCallBloc.add(const IncomingCallFetched());

    bool volumeButtonActive = false;
    Future.delayed(const Duration(seconds: 2)).then((value) {
      volumeButtonActive = true;
    });

    // Create call when volume up and down is pressed and user type is blind
    volumeListenerSubscribtion = deviceInfo.onVolumeUpAndDown.listen((volume) {
      if (user?.type == UserType.blind && volumeButtonActive) {
        appNavigator.goToCreateCall(context, user: user!);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    callStatisticBloc.add(CallStatisticFetched(context.locale.languageCode));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => callStatisticBloc),
        BlocProvider(create: (context) => routeCubit),
        BlocProvider(create: (context) => userBloc),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<AssistantCommandBloc, AssistantCommandState?>(
            bloc: assistantCommandBloc,
            listener: (context, state) {
              if (state is AssistantCommandCallVolunteerLoaded) {
                appNavigator.goToCreateCall(context, user: state.data);
                assistantCommandBloc.add(const AssistantCommandEventRemoved());
              }
            },
          ),
          BlocListener<IncomingCallBloc, IncomingCallState>(
            bloc: incomingCallBloc,
            listener: (context, state) {
              if (state is IncomingCallLoaded) {
                appNavigator.goToAnswerCall(
                  context,
                  callID: state.id,
                  blindID: state.blindID,
                  name: state.name,
                  urlImage: state.urlImage,
                );
                incomingCallBloc.add(const IncomingCallEventRemoved());
              }
            },
          ),
          BlocListener<RouteCubit, RouteState>(
            listener: (context, state) {
              if (state is RouteTarget) {
                if (state.name == AppPages.unknownDevice) {
                  appNavigator.goToUnknownDevice(context);
                }
              }
            },
          ),
          BlocListener<UserBloc, UserState>(
            listener: (context, state) {
              if (state is UserLoaded) {
                user = state.data;
                playPageInfo(state.data);
              }
            },
          ),
        ],
        child: Scaffold(
          body: _LoadingWrapper(
            child: SafeArea(
              bottom: false,
              child: SwipeRefresh.adaptive(
                stateStream: swipeRefreshController.stream,
                onRefresh: onRefresh,
                platform: CustomPlatformWrapper(),
                children: const [
                  SizedBox(height: kDefaultSpacing / 1.5),
                  _UserProfile(),
                  _UserAction(),
                  _PermissionCard(),
                  SizedBox(height: kDefaultSpacing * 1.5),
                  _CallStatistic(),
                  SizedBox(height: kDefaultSpacing * 1.5),
                  _CallHistoryButton(),
                  _SettingsButton(),
                  SizedBox(height: kDefaultSpacing * 2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void playPageInfo(User user) {
    if (mounted && !hasPlayPageInfo) {
      hasPlayPageInfo = true;
      UserType? userType = user.type;

      deviceFeedback.playVoiceAssistant(
        [
          LocaleKeys.va_home_page.tr(),
          if (userType == UserType.blind)
            LocaleKeys.va_home_page_blind_info.tr(),
          if (userType == UserType.volunteer)
            LocaleKeys.va_home_page_volunteer_info.tr()
        ],
        context,
      );
    }
  }

  Future<void> onRefresh() async {
    Completer completer = sl<Completer>();
    Completer completerCall = sl<Completer>();

    userBloc.add(UserFetched(completer: completer));
    callStatisticBloc.add(
      CallStatisticFetched(
        context.locale.languageCode,
        completer: completerCall,
      ),
    );

    await Future.wait([
      completer.future,
      completerCall.future,
    ]);

    if (!swipeRefreshController.isClosed) {
      swipeRefreshController.sink.add(SwipeRefreshState.hidden);
    }
  }

  @override
  void dispose() {
    super.dispose();

    onUserDeviceUpdatedSubscribtion.cancel();
    volumeListenerSubscribtion.cancel();
    swipeRefreshController.close();
  }
}

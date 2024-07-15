/*
 * Author     : Berenisse Oldright
 * Website    :
 * Repository : https://github.com/Oldbright22
 * 
 * Created on Sun Jul 14 2024
 * Copyright (c) 2024 Berenisse Oldright
 */

import 'dart:async';
import 'dart:io';

import 'package:custom_icons/custom_icons.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';


import '../../../core/core.dart';
import '../../../data/data.dart';
import '../../../logic/logic.dart';
import '../../../injection.dart';
import '../../../presentation/presentation.dart';

import '../../../config/config.dart';

part 'sign_up_screen.component.dart';
part 'sign_up_screen.page.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with UIMixin
    implements ResponsiveLayoutInterface {
  final AppNavigator _appNavigator = sl<AppNavigator>();
  final AccountCubit _accountCubit = sl<AccountCubit>();
  final DeviceFeedback _deviceFeedback = sl<DeviceFeedback>();
  final FileBloc _fileBloc = sl<FileBloc>();
  final LanguageBloc _languageBloc = sl<LanguageBloc>();
  final SignUpBloc _signUpBloc = sl<SignUpBloc>();
  final SignUpFormBloc _signUpFormBloc = sl<SignUpFormBloc>();
  final SignOutCubit _signOutCubit = sl<SignOutCubit>();

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

    _accountCubit.getAccountData();
    _languageBloc.add(const LanguageFetched());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    playPageInfo();
    DeviceLanguage deviceLanguage = context.locale.toDeviceLanguage();

    _signUpFormBloc.add(SignUpFormDeviceLanguageChanged(deviceLanguage));
    }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => _accountCubit),
        BlocProvider(create: (context) => _fileBloc),
        BlocProvider(create: (context) => _languageBloc),
        BlocProvider(create: (context) => _signUpBloc),
        BlocProvider(create: (context) => _signUpFormBloc),
        BlocProvider(create: (context) => _signOutCubit),
      ],
      child: PopScope(
        //https://stackoverflow.com/questions/78547550/willpopscope-is-deprecated-and-shouldnt-be-used
        //onWillPop: () async => false,
        canPop: canPop, // Make it  false to Work
        child: Scaffold(
          body: MultiBlocListener(
            listeners: [
              BlocListener<FileBloc, FileState>(
                listener: (context, state) {
                  if (state is FileError) {
                    AppSnackbar(context).showMessage(
                      LocaleKeys.error_failed_to_choose_image.tr(),
                    );
                  }

                  if (state is FilePicked) {
                    _signUpFormBloc.add(
                      SignUpFormProfileImageChanged(state.file),
                    );
                  }
                },
              ),
              BlocListener<SignUpBloc, SignUpState>(
                listener: (context, state) {
                  if (state is SignUpSuccessfully) {
                    playSignUpSuccessfully();
                    _appNavigator.goToHome(context);
                  }
                },
              ),
              BlocListener<SignOutCubit, SignOutState>(
                listener: (context, state) {
                  if (state is SignOutSuccessfully || state is SignOutError) {
                    playSignOutSuccessfully();
                    _appNavigator.goToSplash(context);
                  }
                },
              )
            ],
            child: BlocBuilder<SignUpBloc, SignUpState>(
              builder: (context, state) {
                return IgnorePointer(
                  ignoring: state is SignUpLoading,
                  child: ResponsiveBuilder(
                    mobileBuilder: buildMobileLayout,
                    tabletBuilder: buildTabletLayout,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget buildMobileLayout(BuildContext context, BoxConstraints constraints) {
    return const SafeArea(
      key: Key("sign_up_screen_mobile_layout"),
      child: Padding(
        padding: EdgeInsets.all(kDefaultSpacing * 1.5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: _HelloText()),
                _AuthIconButton(),
              ],
            ),
            _LetsGetStartedText(),
            SizedBox(height: kDefaultSpacing),
            _FillInFormText(),
            Spacer(flex: 1),
            Flexible(
              flex: 10,
              child: _SignUpFormPage(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget buildTabletLayout(BuildContext context, BoxConstraints constraints) {
    return SafeArea(
      key: const Key("sign_up_screen_tablet_layout"),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 600,
            maxHeight: 800,
          ),
          padding: const EdgeInsets.all(kDefaultSpacing * 1.5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _HelloText(),
              const _LetsGetStartedText(),
              const SizedBox(height: kDefaultSpacing),
              const _FillInFormText(),
              const SizedBox(height: kDefaultSpacing * 2),
              _AccountCard(),
              const Spacer(flex: 1),
              const Flexible(
                flex: 10,
                child: _SignUpFormPage(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void playPageInfo() {
    if (mounted) {
      _deviceFeedback.playVoiceAssistant(
        [
          LocaleKeys.va_sign_up_page.tr(),
          LocaleKeys.va_sign_up_required_1.tr(),
          LocaleKeys.va_sign_up_required_2.tr(),
          LocaleKeys.va_sign_up_required_3.tr(),
        ],
        context,
      );
    }
  }

  void playSignUpSuccessfully() {
    if (mounted) {
      _deviceFeedback.playVoiceAssistant(
        [
          LocaleKeys.va_sign_up_successfully.tr(),
        ],
        context,
        immediately: true,
      );
    }
  }

  void playSignOutSuccessfully() {
    if (mounted) {
      _deviceFeedback.playVoiceAssistant(
        [
          LocaleKeys.va_sign_out_successfully.tr(),
        ],
        context,
        immediately: true,
      );
    }
  }
}
